import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/comp/chat/chat.dart';
import 'package:safespace/screens/chatcreate.dart';
import 'package:safespace/screens/groupinfo.dart';
import 'package:safespace/variables.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var groupPic;
  var groupName;
  var groupBio;

  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  void getSearchResults() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF90CAF9),
              Color(0xFF1976D2),
            ]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Chats',
            style: fontStyle2(30, Colors.black, FontWeight.bold, 3),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Column(
              children: [
                Container(
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      onChanged: (text) => {},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search for chats',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4.0,
                spreadRadius: 0.0,
                offset: Offset(2.0, 2.0), // shadow direction: bottom right
              )
            ],
          ),
          child: StreamBuilder(
              stream: chatscollection
                  .where("members", arrayContains: auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return StreamBuilder<Object>(
                    stream: database.child("chats").onValue,
                    builder: (context, snapshott) {
                      if (!snapshott.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if ((snapshott.data! as Event).snapshot.value !=
                          null) {
                        Map data = (snapshott.data! as Event).snapshot.value;

                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                              child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    DocumentSnapshot doc =
                                        snapshot.data!.docs[index];

                                    List orderedList = [];

                                    data.forEach((index, data) => {
                                          if (doc.exists)
                                            {
                                              if (doc["title"] != null)
                                                {
                                                  orderedList.add({
                                                    'id': index,
                                                    'title': doc["title"],
                                                    'groupPic': doc["groupPic"],
                                                    ...data
                                                  })
                                                }
                                              else
                                                {
                                                  orderedList.add({
                                                    'id': index,
                                                    'title': doc["members"]
                                                                [0] ==
                                                            auth.currentUser!
                                                                .uid
                                                        ? doc["members"][1]
                                                            ["username"]
                                                        : doc["members"][0]
                                                            ["username"],
                                                    'groupPic': doc["members"]
                                                                    [0]
                                                                .id ==
                                                            auth.currentUser!
                                                                .uid
                                                        ? doc["members"][1]
                                                            ["profile_picture"]
                                                        : doc["members"][0]
                                                            ["profile_picture"],
                                                    ...data
                                                  })
                                                },
                                            }
                                        });

                                    orderedList.sort((a, b) {
                                      if (b["createdAt"] != null) {
                                        return b["createdAt"]
                                            .compareTo(a["createdAt"]);
                                      } else
                                        return b["lastMessage"]
                                            .compareTo(a["lastMessage"]);
                                    });

                                    return Column(
                                      children: [
                                        index == 0
                                            ? Text("Your Groups",
                                                style: fontStyle(
                                                  20,
                                                  Colors.black,
                                                  FontWeight.bold,
                                                ))
                                            : SizedBox(width: 0),
                                        InkWell(
                                          onTap: () => {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    child: Chat(
                                                        orderedList[index]
                                                            ["id"],
                                                        orderedList[index]
                                                            ["title"],
                                                        orderedList[index]
                                                            ["groupPic"]))),
                                            Chat.showGallery.value = false,
                                          },
                                          child: Container(
                                            height: 80,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Container(
                                                  width: 65.0,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            orderedList[index]
                                                                ["groupPic"])),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                6.0)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(
                                                            0.0, 1.0), //(x,y)
                                                        blurRadius: 6.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(height: 10),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              orderedList[index]
                                                                  ["title"],
                                                              style: fontStyle(
                                                                  20,
                                                                  Colors.black,
                                                                  FontWeight
                                                                      .w600,
                                                                  2),
                                                            ),
                                                            data[orderedList[index]["id"]]
                                                                        [
                                                                        "createdAt"] !=
                                                                    null
                                                                ? Text(
                                                                    DateFormat("h:mm a").format(DateFormat(
                                                                            "yyyy-mm-dd HH:mm:ss")
                                                                        .parse(data[orderedList[index]["id"]]["createdAt"]
                                                                            .toString())),
                                                                    style: fontStyle(
                                                                        15,
                                                                        Colors
                                                                            .grey,
                                                                        FontWeight
                                                                            .w300))
                                                                : Text(""),
                                                          ],
                                                        ),
                                                        Text(
                                                            "Last Message: " +
                                                                data[orderedList[
                                                                            index]
                                                                        ["id"]][
                                                                    "lastMessage"],
                                                            style: fontStyle(
                                                                15,
                                                                Colors
                                                                    .grey[600],
                                                                FontWeight
                                                                    .w300)),
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Divider(),
                                      ],
                                    );
                                  }),
                            ),
                            Positioned(
                              height: 60,
                              width: 60,
                              bottom: 30,
                              right: 50,
                              child: FloatingActionButton(
                                child: Icon(MdiIcons.pencil, size: 30),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.fade,
                                          child: NewChatPage()));
                                },
                              ),
                            )
                          ],
                        );
                      } else
                        return Center(child: CircularProgressIndicator());
                    });
              }),
        ),
      ),
    );
  }
}
