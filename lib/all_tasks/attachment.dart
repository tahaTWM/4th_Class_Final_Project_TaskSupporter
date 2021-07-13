import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Attachment extends StatefulWidget {
  @override
  _AttachmentState createState() => _AttachmentState();
}

class _AttachmentState extends State<Attachment> {
  bool upload = false;
  var list = [];
  double percent = 0.0;
  @override
  void initState() {
    Timer timer;
    timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
      setState(() {
        percent += 10;
        if (percent >= 100) {
          timer.cancel();
          // percent=0;
        }
      });
    });
    super.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 246, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 246, 255, 1),
        elevation: 0,
        title: Text(
          "Attachments",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18)),
            padding: EdgeInsets.symmetric(horizontal: 5),
            margin: EdgeInsets.only(right: 10, top: 7),
            child: PopupMenuButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              icon: Icon(Icons.more_vert, size: 28, color: Colors.blue),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.paperclip,
                        size: 30,
                        // color: Color.fromRGBO(158, 158, 158, 1),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Add Attachment",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "RubicB",
                        ),
                      )
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 30,
                        color: Color.fromRGBO(158, 158, 158, 1),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "RubicB",
                        ),
                      )
                    ],
                  ),
                ),
              ],
              onSelected: (item) {
                switch (item) {
                  case 1:
                    {
                      _showPickerFileOrImage(context);
                    }
                    break;
                  case 2:
                    {
                      setState(() {
                        upload = true;
                      });
                    }

                    break;
                }
              },
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.blue, size: 28),
      ),
      body: upload != true
          ? Center(
              child: Text("NoThing Now"),
            )
          : Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              alignment: Alignment.center,
              child: LinearPercentIndicator(
                //leaner progress bar
                animation: true,
                animationDuration: 1000,
                lineHeight: 20.0,
                percent: percent / 100,
                center: Text(
                  percent.toString() + "%",
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.blue[400],
                backgroundColor: Colors.grey[300],
              ),
            ),
    );
  }
  //this function to add attachment to task
  //image picker
  //select betwen camera and storage

  void _showPicker(context) async {
    await Permission.storage.request();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery(context);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // for display attachment
  displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
        elevation: 0,
        context: context,
        builder: (ctx) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "Welcome to AndroidVille!",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        });
  }

  _showPickerFileOrImage(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.insert_drive_file),
                      title: new Text('File'),
                      onTap: () async {
                        var file =
                            await FilePicker.platform.pickFiles() as File;
                        _confromUploadImageOrFile(context, file);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.image),
                    title: new Text('Image'),
                    onTap: () {
                      _showPicker(context);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromGallery(BuildContext context) async {
    // ignore: deprecated_member_use
    var _image = (await ImagePicker.pickImage(
      source: ImageSource.gallery,
    ));
    _confromUploadImageOrFile(context, _image);
  }

  _imgFromCamera(BuildContext context) async {
    // ignore: deprecated_member_use
    var _image = (await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50));
    _confromUploadImageOrFile(context, _image);
  }

  _confromUploadImageOrFile(BuildContext context, File _image) {
    return showDialog(
        context: context,
        builder: (contect) {
          return AlertDialog(
            title: Text("Changing Profile Image"),
            content: Text(
              "Are Sure You want to Change Profile image?",
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Yes"),
              ),
              RaisedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("No"),
              ),
            ],
          );
        });
  }
}
