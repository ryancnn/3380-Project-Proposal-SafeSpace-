import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/comp/imagegallery.dart';
import 'package:safespace/variables.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({Key? key}) : super(key: key);

  @override
  _NewChatPageState createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final gridKey = GlobalKey<FormFieldState>();
  final gridKey2 = GlobalKey<FormFieldState>();
  var groupName;
  var groupDescription;
  var groupPic;
  var visible = false;
  var users = [];
  var members = [];

  late final AnimationController _animcontroller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..forward();
  late final Animation<double> animation = CurvedAnimation(
    parent: _animcontroller,
    curve: Curves.easeOut,
  );

  late TabController controller;
  UploadTask? uploadTask;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    getData();
  }

  getData() async {
    QuerySnapshot userDoc = await usercollection.get();
    userDoc.docs.forEach((element) {
      users.add(element);
    });
  }

  void createGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var groupKey = chatscollection.doc().id;
      uploadTask = storage
          .child('groupPictures/' + groupKey + "/$groupName")
          .putFile(File(groupPic!));
      uploadTask!.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
          });
        } else {
          uploading = false;
        }
      }, onError: (Object e) {
        print(e); // FirebaseException
      });
      var dowurl = await (await uploadTask)!.ref.getDownloadURL();
      groupPic = dowurl.toString();
      var groupPlayer = [auth.currentUser!.uid];
      chatscollection.doc(groupKey).set({
        'id': groupKey,
        'creator': auth.currentUser!.uid,
        'title': groupName,
        'description': groupDescription,
        'groupPic': groupPic,
        'members': FieldValue.arrayUnion(groupPlayer),
      });
      var groupObject = [groupKey];
      usercollection.doc(auth.currentUser!.uid).update({
        'chats': FieldValue.arrayUnion(groupObject),
      });
      database
          .child("chats")
          .child(groupKey)
          .set({'lastMessage': "No messages sent"});
      Navigator.pop(context);
    }
  }

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
        appBar: AppBar(
          title: Text(
            members.length == 1
                ? "Chat with " + members[0]["username"]!
                : "New Chat",
            style: fontStyle2(25, Colors.black, FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Column(children: [
          members.length > 1
              ? InkWell(
                  child: Image(
                    image: groupPic != null
                        ? FileImage(File(groupPic))
                        : NetworkImage(auth.currentUser!.photoURL!)
                            as ImageProvider,
                    width: 150,
                    height: 150,
                  ),
                  onTap: () async {
                    var result = await Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade,
                            child: ImageGallery("Group")));
                    setState(() {
                      groupPic = result.groupPic;
                    });
                  },
                )
              : SizedBox(height: 0),
          SizedBox(height: 15),
          members.length > 1
              ? Form(
                  key: _formKey,
                  child: Container(
                    margin: EdgeInsets.only(left: 50, right: 50),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: "Group Name",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle:
                                  fontStyle(15, Colors.black, FontWeight.w500)),
                          validator: (input) =>
                              !(input!.length > 4) && input.trim().isEmpty
                                  ? 'Group Name Invalid'
                                  : null,
                          onSaved: (input) => groupName = input,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: "Group Description",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle:
                                  fontStyle(15, Colors.black, FontWeight.w400)),
                          onSaved: (input) => groupDescription = input,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(height: 0),
          SizedBox(height: 10),
          SizedBox(height: 20),
          Expanded(
            child: Stack(children: [
              Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4.0,
                        spreadRadius: 0.0,
                        offset:
                            Offset(2.0, 2.0), // shadow direction: bottom right
                      )
                    ],
                  ),
                  child: Stack(children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Text("Members",
                              style: fontStyle2(
                                  30, Colors.black, FontWeight.w600)),
                          GridView.builder(
                            key: gridKey,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: members.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, childAspectRatio: 1),
                            itemBuilder: (ctx, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        users[index]["profile_picture"]),
                                    radius: 150),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        height: 60,
                        width: 60,
                        bottom: 30,
                        right: members.length > 0 ? 280 : 50,
                        child: FloatingActionButton(
                            child: Icon(MdiIcons.plus, size: 20),
                            onPressed: () {
                              setState(() {
                                visible = true;
                              });
                            })),
                    members.length > 0
                        ? Positioned(
                            height: 60,
                            width: 60,
                            bottom: 30,
                            right: 50,
                            child: FloatingActionButton(
                                child: Icon(MdiIcons.arrowRight, size: 20),
                                onPressed: () {
                                  createGroup();
                                }))
                        : SizedBox(height: 0),
                  ])),
              visible
                  ? FadeTransition(
                      opacity: animation,
                      child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 4.0,
                                spreadRadius: 0.0,
                                offset: Offset(
                                    2.0, 2.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () => {
                                                _animcontroller
                                                    .reverse()
                                                    .whenComplete(() => {
                                                          setState(
                                                            () {
                                                              visible = false;
                                                              _animcontroller
                                                                  .reset(); // stops the animation if in progress
                                                              _animcontroller
                                                                  .forward();
                                                            },
                                                          ),
                                                        }),
                                              },
                                          icon: Icon(MdiIcons.arrowLeft)),
                                      Text("Add Members",
                                          style: fontStyle2(30, Colors.black,
                                              FontWeight.w600)),
                                    ],
                                  ),
                                  GridView.builder(
                                    key: gridKey2,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: users.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            childAspectRatio: 3 / 2,
                                            crossAxisSpacing: 30,
                                            mainAxisExtent: 300),
                                    itemBuilder: (ctx, index) {
                                      if (users[index].id !=
                                          auth.currentUser!.uid) {
                                        return Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (members
                                                    .map((item) => item.id)
                                                    .contains(
                                                        users[index].id)) {
                                                  members.removeWhere(((it) =>
                                                      it.id ==
                                                      members[index].id));
                                                } else {
                                                  members.add(users[index]);
                                                }
                                              },
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    users[index]
                                                        ["profile_picture"]),
                                                radius: 30,
                                              ),
                                            ),
                                            Text(users[index]["username"])
                                          ],
                                        );
                                      } else {
                                        return SizedBox(height: 0);
                                      }
                                    },
                                  )
                                ],
                              ),
                            ],
                          )))
                  : SizedBox(height: 0),
            ]),
          ),
        ]),
      ),
    );
  }
}
