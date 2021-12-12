import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:safespace/screens/home.dart';
import 'package:safespace/screens/profileedit.dart';
import 'package:safespace/variables.dart';

import 'chat/chat.dart';

class ImageGallery extends StatefulWidget {
  final String type, bio;
  final Function callback;

  ImageGallery(this.type, {this.bio = "", this.callback = _dummy});

  static dynamic _dummy() {}

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class ReturnValues {
  String groupPic;

  ReturnValues(this.groupPic);
}

class ReturnList {
  List<String?> selectedImages = [];

  ReturnList(this.selectedImages);
}

class _ImageGalleryState extends State<ImageGallery> {
  List<Widget> _mediaList = [];
  File? imageFile;
  List<String?> selectedImages = [];
  int currentPage = 0;
  int? lastPage;
  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  Future<void> cropImage() async {
    File? cropped = await ImageCropper.cropImage(
      sourcePath: imageFile!.path,
      cropStyle:
          widget.type == "Profile" ? CropStyle.circle : CropStyle.rectangle,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    setState(() {
      imageFile = cropped ?? imageFile;
      int count = 0;
      if (widget.type == "Profile") {
        Navigator.popUntil(context, (route) {
          return count++ == 1;
        });
      }
      if (widget.type == "Profile") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileEdit(
                widget.bio,
                (cropped != null ? cropped.path : auth.currentUser!.photoURL)
                    as String),
          ),
        );
      } else if (widget.type == "Group") {
        Navigator.pop(context, ReturnValues(cropped!.path));
      }
    });
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          onlyAll: true, type: RequestType.image);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(currentPage, 60);
      List<Widget> temp = [];
      for (var asset in media) {
        File? assetFile = await asset.file;
        temp.add(
          FutureBuilder(
            future: asset.thumbDataWithSize(200, 200),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  asset.type != AssetType.video) {
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        margin: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            border: selectedImages.contains(assetFile!.path)
                                ? Border.all(color: Colors.blue, width: 1.5)
                                : null),
                        child: GestureDetector(
                          onTap: () async {
                            imageFile = assetFile;
                            widget.type != "Message"
                                ? cropImage()
                                : setState(() {
                                    selectedImages.contains(imageFile!.path)
                                        ? selectedImages.remove(imageFile!.path)
                                        : selectedImages.add(imageFile!.path);
                                    widget.callback(imageFile!.path);
                                  });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: MemoryImage(
                                        snapshot.data as Uint8List,
                                      ))),
                              child: selectedImages.contains(assetFile.path)
                                  ? Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(MdiIcons.check,
                                          color: Colors.blue))
                                  : null),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        );
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.type != "Message"
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                'Gallery',
                style: fontStyle(25, Colors.black, FontWeight.w600),
              ),
              centerTitle: true,
              backgroundColor: Colors.blue,
              elevation: 0,
            ),
            body: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scroll) {
                  _handleScrollEvent(scroll);
                  return false;
                },
                child: GridView.builder(
                    itemCount: _mediaList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return _mediaList[index];
                    })),
          )
        : Align(
            alignment: Alignment.topCenter,
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
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
                height: 300,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30)),
                  child: Column(children: [
                    AppBar(
                      title: Text("Gallery",
                          style: fontStyle(15, Colors.black, FontWeight.w500)),
                      centerTitle: true,
                      toolbarHeight: 30,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: InkWell(
                              child: Icon(MdiIcons.close, color: Colors.black),
                              onTap: () => Chat.showGallery.value = false),
                        )
                      ],
                    ),
                    Expanded(
                      child: Stack(children: [
                        GridView.builder(
                            itemCount: _mediaList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (BuildContext context, int index) {
                              return _mediaList[index];
                            }),
                        selectedImages.isNotEmpty
                            ? Positioned(
                                height: 60,
                                width: 60,
                                bottom: 30,
                                right: 160,
                                child: FloatingActionButton(
                                  child: Icon(MdiIcons.arrowUp, size: 30),
                                  onPressed: () {},
                                ),
                              )
                            : SizedBox(height: 0),
                      ]),
                    ),
                  ]),
                )),
          );
  }
}
