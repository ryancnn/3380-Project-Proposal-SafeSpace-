import 'dart:convert';
import 'dart:io';

import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:safespace/comp/imagegallery.dart';
import 'package:safespace/screens/profile.dart';
import 'package:safespace/variables.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {
  final chatKey, title, pic;

  static ValueNotifier<bool> showGallery = ValueNotifier(false);

  Chat(this.chatKey, this.title, this.pic);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GlobalKey<DashChatState> _chatKey = GlobalKey<DashChatState>();
  ChatUser currentUser =
      ChatUser(uid: auth.currentUser!.uid, avatar: auth.currentUser!.photoURL);
  var stream;
  List<String?> selectedImages = [];
  List<ChatMessage> messges = [];
  bool _disabled = true;

  //Image Upload
  UploadTask? uploadTask;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    selectedImages.clear();
    stream = database
        .child("messages")
        .child(widget.chatKey)
        .orderByChild("createdAt");
  }

  Future<List<String>> loadImages(ChatMessage message) async {
    List<String> images = [];
    int index = 0;
    await Future.forEach(selectedImages, (element) async {
      uploadTask = storage
          .child('messagePictures/' +
              widget.chatKey +
              "/${message.id}" +
              "/image$index")
          .putFile(File(element.toString()));
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
      images.add(dowurl);
      index++;
    });
    return images;
  }

  Future<void> onSend(ChatMessage message) async {
    ChatMessage msg = ChatMessage(text: message.text, user: message.user);
    var url = Uri.parse(
        'https://profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com/');
    var response = await http.post(url, headers: {
      "content-type": "application/x-www-form-urlencoded",
      "x-rapidapi-host":
          "profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com",
      "x-rapidapi-key": "23ccd7ccbbmshcdf37509dcfb5d9p17627bjsn98a8be5029df"
    }, body: {
      'text': message.text
    });
    var results = jsonDecode(response.body);
    if (results["semantic_analysis"].isEmpty) {
      if (selectedImages.isNotEmpty) {
        List<String> images = [];
        ImageList? imageList;
        images = await loadImages(message);
        imageList = ImageList(images: images);
        print("ImageList" + imageList.images.toString());
        msg = ChatMessage(
            text: message.text, user: message.user, images: imageList);
        selectedImages.clear();
        print("MSG: " + msg.toJson().toString());
      }
      database.child("messages").child(widget.chatKey).push().set(msg.toJson());
      database.child("chats").child(widget.chatKey).update({
        'lastMessage': message.text,
        'createdAt': message.createdAt.toString(),
      });
    }
  }

  void callback(String? image) {
    setState(() {
      selectedImages.contains(image)
          ? selectedImages.remove(image)
          : selectedImages.add(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: fontStyle(18, Colors.black, FontWeight.w600),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF90CAF9),
                    Color(0xFF1976D2),
                  ]),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          actions: [
            TextButton(
                child: Container(
                  width: 40.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover, image: NetworkImage(widget.pic)),
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
                onPressed: () {}),
          ],
        ),
        body: StreamBuilder(
            stream: stream.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                );
              } else if ((snapshot.data! as Event).snapshot.value != null) {
                Map data = (snapshot.data! as Event).snapshot.value;
                List<ChatMessage> messages = [];

                data.forEach(
                    (index, data) => messages.add(ChatMessage.fromJson(data)));

                return Stack(children: [
                  DashChat(
                      key: _chatKey,
                      inverted: false,
                      onSend: onSend,
                      alwaysShowSend: false,
                      sendOnEnter: true,
                      textBeforeImage: false,
                      textInputAction: TextInputAction.send,
                      user: currentUser,
                      inputDecoration: InputDecoration.collapsed(
                        hintText: "Type message here...",
                      ),
                      dateFormat: DateFormat('MMM-dd-yyyy'),
                      timeFormat: DateFormat('h:mm a'),
                      messages: messages,
                      showUserAvatar: true,
                      showAvatarForEveryMessage: false,
                      scrollToBottom: true,
                      onPressAvatar: (ChatUser user) {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: Profile(user.uid!)));
                      },
                      onLongPressAvatar: (ChatUser user) {
                        print("OnLongPressAvatar: ${user.name}");
                      },
                      inputMaxLines: 5,
                      messageContainerPadding: EdgeInsets.only(right: 5.0),
                      inputTextStyle: TextStyle(fontSize: 16.0),
                      inputContainerStyle: BoxDecoration(
                        border: Border.all(width: 0.0),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      chatFooterBuilder: () {
                        return selectedImages.isNotEmpty
                            ? Container(
                                height: 100,
                                child: Expanded(
                                  child: ListView.builder(
                                      key: UniqueKey(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: selectedImages.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Image.file(
                                          File(selectedImages[index]!),
                                          width: 50,
                                          height: 50,
                                        );
                                      }),
                                ),
                              )
                            : SizedBox(height: 0);
                      },
                      messageImageBuilder: (list) {
                        final gridKey = GlobalKey<FormFieldState>();

                        return GridView.builder(
                          key: gridKey,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: 1,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, childAspectRatio: 1),
                          itemBuilder: (ctx, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: PicPreview(
                                            list!.images!.elementAt(index))));
                              },
                              child: Image.network(
                                list!.images!.elementAt(index),
                                height: 150,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        );
                      },
                      inputToolbarMargin: EdgeInsets.all(5),
                      onLoadEarlier: () {
                        print("loading...");
                      },
                      shouldShowLoadEarlier: false,
                      showTraillingBeforeSend: true,
                      leading: <Widget>[
                        InkWell(
                          child: Icon(MdiIcons.camera),
                          onTap: () => print("hi"),
                        ),
                      ],
                      trailing: _disabled == false
                          ? <Widget>[]
                          : <Widget>[
                              InkWell(
                                  child: Icon(MdiIcons.image),
                                  onTap: () {
                                    Chat.showGallery.value = true;
                                  }),
                            ]),
                  ValueListenableBuilder<bool>(
                    valueListenable: Chat.showGallery,
                    builder: (BuildContext context, bool value, Widget? child) {
                      // This builder will only get called when the _counter
                      // is updated.
                      return Chat.showGallery.value == true
                          ? ImageGallery("Message", callback: this.callback)
                          : SizedBox(height: 0);
                    },
                  )
                ]);
              } else
                return Stack(children: [
                  DashChat(
                      key: _chatKey,
                      inverted: false,
                      onSend: onSend,
                      alwaysShowSend: false,
                      sendOnEnter: true,
                      textBeforeImage: false,
                      textInputAction: TextInputAction.send,
                      user: currentUser,
                      inputDecoration: InputDecoration.collapsed(
                        hintText: "Type message here...",
                      ),
                      dateFormat: DateFormat('MMM-dd-yyyy'),
                      timeFormat: DateFormat('h:mm a'),
                      messages: messges,
                      showUserAvatar: true,
                      showAvatarForEveryMessage: false,
                      scrollToBottom: true,
                      onPressAvatar: (ChatUser user) {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: Profile(user.uid!)));
                      },
                      onLongPressAvatar: (ChatUser user) {
                        print("OnLongPressAvatar: ${user.name}");
                      },
                      inputMaxLines: 5,
                      messageContainerPadding:
                          EdgeInsets.only(left: 30.0, right: 5.0),
                      inputTextStyle: TextStyle(fontSize: 16.0),
                      inputContainerStyle: BoxDecoration(
                        border: Border.all(width: 0.0),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      chatFooterBuilder: () {
                        return selectedImages.isNotEmpty
                            ? Container(
                                height: 100,
                                child: Expanded(
                                  child: ListView.builder(
                                      key: UniqueKey(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: selectedImages.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Image.file(
                                          File(selectedImages[index]!),
                                          width: 50,
                                          height: 50,
                                        );
                                      }),
                                ),
                              )
                            : SizedBox(height: 0);
                      },
                      inputToolbarMargin: EdgeInsets.all(5),
                      onLoadEarlier: () {
                        print("loading...");
                      },
                      shouldShowLoadEarlier: false,
                      showTraillingBeforeSend: true,
                      leading: <Widget>[
                        InkWell(
                          child: Icon(MdiIcons.camera),
                          onTap: () => print("hi"),
                        ),
                      ],
                      trailing: _disabled == false
                          ? <Widget>[]
                          : <Widget>[
                              InkWell(
                                  child: Icon(MdiIcons.image),
                                  onTap: () {
                                    Chat.showGallery.value = true;
                                  }),
                            ]),
                  ValueListenableBuilder<bool>(
                    valueListenable: Chat.showGallery,
                    builder: (BuildContext context, bool value, Widget? child) {
                      // This builder will only get called when the _counter
                      // is updated.
                      return Chat.showGallery.value == true
                          ? ImageGallery("Message", callback: this.callback)
                          : SizedBox(height: 0);
                    },
                  )
                ]);
            }));
  }
}

class PicPreview extends StatelessWidget {
  final String profilePic;

  PicPreview(this.profilePic);
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
