import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/comp/chat/chat.dart';
import 'package:safespace/variables.dart';

class GroupInfo extends StatefulWidget {
  final String groupKey, creatorId, groupName, groupDescription, groupPic;

  GroupInfo(this.groupKey, this.creatorId, this.groupName,
      this.groupDescription, this.groupPic);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  String? creatorName;
  String? creatorPic;

  @override
  void initState() {
    super.initState();
    usercollection.doc(widget.creatorId).get().then((value) {
      if (value.exists) {
        setState(() {
          creatorName = value["username"];
          creatorPic = value["profile_picture"];
        });
      }
    });
  }

  void joinGroup() async {
    var member = [auth.currentUser!.uid];
    var chat = [widget.groupKey];
    chatscollection
        .doc(widget.groupKey)
        .update({'members': FieldValue.arrayUnion(member)});
    usercollection
        .doc(auth.currentUser!.uid)
        .update({'chats': FieldValue.arrayUnion(chat)});
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            child: Chat(widget.groupKey, widget.groupName, widget.groupPic)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Group Info"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
          child: Image(
            fit: BoxFit.fitWidth,
            image: NetworkImage(widget.groupPic),
            width: MediaQuery.of(context).size.width,
            height: 350,
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
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            creatorPic != null ? creatorPic! : "")),
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
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
                Text(creatorName != null ? creatorName! : "Unknown",
                    style: fontStyle(15, Colors.black, FontWeight.w500)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
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
        SizedBox(height: 15),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.blue[700]),
            child: Text("Join Group",
                style: fontStyle(15, Colors.white, FontWeight.w500, 0)),
            onPressed: () => joinGroup(),
          ),
        )
      ]),
    );
  }
}
