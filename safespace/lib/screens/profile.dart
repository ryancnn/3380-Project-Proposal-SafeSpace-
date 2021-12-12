import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/screens/profileedit.dart';
import 'package:safespace/variables.dart';

class Profile extends StatefulWidget {
  final String uid;

  Profile(this.uid);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? username;
  String? bio;
  String? profilePic;
  bool dataFound = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    DocumentSnapshot userDoc = await usercollection.doc(widget.uid).get();
    username = userDoc['username'];
    bio = userDoc['bio'];
    profilePic = userDoc['profile_picture'];
    setState(() {
      dataFound = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: fontStyle(25, Colors.black, FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            child: Icon(MdiIcons.cog),
            onPressed: () {
              auth.signOut();
            },
          ),
        ],
      ),
      body: !dataFound
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Align(
                  //Bottom of profile
                  alignment: Alignment(0, -0.08),
                  child: Stack(
                    children: [
                      widget.uid == auth.currentUser!.uid
                          ? Text("Your Groups",
                              style: fontStyle(20, Colors.black))
                          : Text("Their Groups",
                              style: fontStyle(20, Colors.black))
                    ],
                  ),
                ),
                ClipShadowPath(
                    //Top of profile
                    clipper: CustomShapeClipper(),
                    shadow: Shadow(blurRadius: 5),
                    child: Stack(
                      children: [
                        Container(
                          height: 400.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xFF90CAF9),
                                  Color(0xFF1976D2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                          ),
                        ),
                        Container(
                            height: 400,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 90),
                                Stack(children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType.fade,
                                              child: ProfilePicPreview(
                                                  profilePic!)));
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          auth.currentUser!.photoURL!),
                                      radius: 65,
                                    ),
                                  ),
                                  Container(
                                      height: 125,
                                      width: 125,
                                      alignment: Alignment.bottomRight,
                                      child: SizedBox(
                                        height: 35,
                                        width: 35,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.all(0),
                                              primary: Colors.red[300],
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.0)),
                                            ),
                                            child: Icon(MdiIcons.pencil,
                                                size: 20, color: Colors.black),
                                            onPressed: () async {
                                              setState(() {
                                                profilePic =
                                                    auth.currentUser!.photoURL;
                                              });
                                              var result = await Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .fade,
                                                      child: ProfileEdit(
                                                          bio!, profilePic!)));
                                              setState(() {
                                                username = result.username;
                                                bio = result.bio;
                                                profilePic = result.profilePic;
                                              });
                                            }),
                                      )),
                                ]),
                                SizedBox(height: 20),
                                Text(username!,
                                    style: fontStyle(
                                        15, Colors.black, FontWeight.w500)),
                                SizedBox(height: 10),
                                Text(bio!,
                                    textAlign: TextAlign.center,
                                    style: fontStyle(
                                        15, Colors.black, FontWeight.w400)),
                              ],
                            )),
                      ],
                    )),
              ],
            ),
    );
  }
}

class ProfilePicPreview extends StatelessWidget {
  final String profilePic;

  ProfilePicPreview(this.profilePic);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.network(this.profilePic,
          fit: BoxFit.fitWidth,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center),
    );
  }
}
