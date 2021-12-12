import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hover_card/hover_card.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/comp/chat/chat.dart';
import 'package:safespace/screens/groupinfo.dart';

import 'package:safespace/variables.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore',
            style: fontStyle2(30, Colors.black, FontWeight.bold, 3)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 230,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 3.0,
                  ),
                ],
              ),
              child: Center(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search and Explore',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: chatscollection.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Ink(
              color: Colors.white,
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    if (!doc["members"].contains(auth.currentUser!.uid)) {
                      return Column(children: [
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: GroupInfo(
                                      doc["id"],
                                      doc["creator"],
                                      doc["title"],
                                      doc["description"],
                                      doc["groupPic"]))),
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(25),
                                    bottomLeft: Radius.circular(25),
                                    bottomRight: Radius.circular(10))),
                            child: Row(children: [
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 80.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(doc["groupPic"])),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      doc["title"],
                                      style: fontStyle(
                                          20, Colors.black, FontWeight.w600, 2),
                                    ),
                                    Text(doc["description"],
                                        style: fontStyle(15, Colors.grey[600],
                                            FontWeight.w300)),
                                  ]),
                            ]),
                          ),
                        ),
                        SizedBox(height: 5),
                        Divider(),
                      ]);
                    } else {
                      return SizedBox(height: 0);
                    }
                  }),
            );
          }),
    );
  }
}

class Dialogue extends StatefulWidget {
  final String groupKey, groupName, groupDescription, groupPic;
  Dialogue(this.groupKey, this.groupName, this.groupDescription, this.groupPic);

  @override
  _DialogueState createState() => _DialogueState();
}

class _DialogueState extends State<Dialogue> {
  void joinGroup() async {
    usercollection
        .doc(auth.currentUser!.uid)
        .collection("chats")
        .doc(widget.groupKey);

    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: Chat(widget.groupKey, widget.groupName, widget.groupPic)));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.all(10),
      children: [
        SizedBox(
          height: 400,
          width: 100,
          child: HoverCard(
            builder: (context, hovering) {
              return Container(
                color: const Color(0xFFE9E9E9),
                child: Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    child: Image(
                      fit: BoxFit.fitWidth,
                      image: NetworkImage(widget.groupPic),
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(widget.groupName,
                          style: fontStyle(30, Colors.black, FontWeight.w700)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Text(
                        widget.groupDescription,
                        textAlign: TextAlign.left,
                        style: fontStyle(15, Colors.grey, FontWeight.w400, 0),
                      ),
                    ),
                  ),
                  SizedBox(height: 55, width: 20),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(primary: Colors.blue[700]),
                      child: Text("Join Group",
                          style:
                              fontStyle(15, Colors.white, FontWeight.w500, 0)),
                      onPressed: () => print("Yes"),
                    ),
                  )
                ]),
              );
            },
            depth: 5,
            depthColor: Colors.grey[500],
            onTap: () => print('Hello, World!'),
            shadow: BoxShadow(
                color: Colors.grey,
                blurRadius: 30,
                spreadRadius: -20,
                offset: Offset(0, 20)),
          ),
        ),
      ],
    );
  }
}
