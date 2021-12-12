import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/comp/imagegallery.dart';
import 'package:safespace/variables.dart';

class ProfileEdit extends StatefulWidget {
  final String bio;
  final String profilePic;

  ProfileEdit(this.bio, this.profilePic);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class ReturnValues {
  String username;
  String bio;
  String profilePic;

  ReturnValues(this.username, this.bio, this.profilePic);
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();
  String? username, bio, profilePicture;
  UploadTask? uploadTask;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    bio = widget.bio;
    profilePicture = widget.profilePic;
  }

  updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (username != auth.currentUser!.displayName || bio != widget.bio) {
        usercollection.doc(auth.currentUser!.uid).update({
          'username': username.toString(),
          'bio': bio.toString(),
        });
      }
      if (auth.currentUser!.photoURL != profilePicture) {
        uploadTask = storage
            .child('profilePictures/' + auth.currentUser!.uid + "/profile")
            .putFile(File(profilePicture!));
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
        profilePicture = dowurl.toString();

        usercollection.doc(auth.currentUser!.uid).update({
          'profile_picture': profilePicture,
        });
      }
      return {
        auth.currentUser!.updateDisplayName(username),
        auth.currentUser!.updatePhotoURL(profilePicture),
        Navigator.pop(context, ReturnValues(username!, bio!, profilePicture!)),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Edit',
          style: fontStyle(25, Colors.black, FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Align(
            //Bottom of profile
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Container(
                  height: 500.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xfffdfbfb),
                      Color(0xffebedee),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  ),
                ),
                Container(
                  height: 500,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FlatButton(
                      minWidth: MediaQuery.of(context).size.width,
                      child: uploading == false
                          ? Text("Save")
                          : Text("Updating..."),
                      color: Colors.blue,
                      onPressed: () {
                        updateProfile();
                      },
                    ),
                  ),
                ),
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
                    height: 405.0,
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
                      height: 405,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 90),
                          Stack(children: [
                            GestureDetector(
                              onTap: () async {
                                var result = await Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: ImageGallery("Profile",
                                            bio: bio!)));
                                setState(() {
                                  profilePicture = result;
                                });
                              },
                              child: CircleAvatar(
                                backgroundImage: widget.profilePic !=
                                        auth.currentUser!.photoURL
                                    ? FileImage(File(widget.profilePic))
                                    : NetworkImage(auth.currentUser!.photoURL!)
                                        as ImageProvider,
                                radius: 55,
                              ),
                            ),
                            Container(
                                height: 105,
                                width: 105,
                                alignment: Alignment.bottomRight,
                                padding: EdgeInsets.all(0),
                                child: CircleAvatar(
                                  radius: 10,
                                  child: Icon(
                                    MdiIcons.plus,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                )),
                          ]),
                          Form(
                            key: _formKey,
                            child: Container(
                              margin: EdgeInsets.only(left: 50, right: 50),
                              child: Column(
                                children: [
                                  TextFormField(
                                    initialValue: auth.currentUser!.displayName,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        labelText: "Username",
                                        labelStyle: fontStyle(
                                            15, Colors.black, FontWeight.w500)),
                                    validator: (input) =>
                                        !(input!.length > 4) &&
                                                input.trim().isEmpty
                                            ? 'Username Invalid'
                                            : null,
                                    onSaved: (input) => username = input,
                                  ),
                                  TextFormField(
                                    initialValue: widget.bio,
                                    maxLines: 3,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        labelText: "Bio",
                                        labelStyle: fontStyle(
                                            15, Colors.black, FontWeight.w400)),
                                    onSaved: (input) => bio = input,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              )),
        ],
      ),
    );
  }
}
