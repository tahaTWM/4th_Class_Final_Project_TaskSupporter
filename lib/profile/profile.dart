import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/logn.dart';
import '../main.dart';
import 'package:flutter/cupertino.dart';

import '../navBar.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool timeZoneSwitch = false;
  bool showAllEventSwitch = false;
  bool emailNotifSwitch = false;
  var profileName = '';
  var fName = '';
  var sName = '';
  var email = '';
  TextEditingController textEditingControllerFName = TextEditingController();
  TextEditingController textEditingControllerSName = TextEditingController();
  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerConformNewPassword =
      TextEditingController();

  TextEditingController textEditingControllerOldPassword =
      TextEditingController();
  TextEditingController textEditingControllerNewPassword =
      TextEditingController();

  File image;

  String workspaces = "0";
  String tasks = "0";

  @override
  void initState() {
    super.initState();
    name();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  var imagePath;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          backgroundColor: Color.fromRGBO(250, 250, 250, 2),
          elevation: 0,
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18)),
              padding: EdgeInsets.symmetric(horizontal: 5),
              margin: EdgeInsets.only(right: 10, top: 7),
              child: PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  size: width > 400 ? 30 : 20,
                  color: Colors.blue,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 30,
                          color: Color.fromRGBO(158, 158, 158, 1),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Edit Account",
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
                          Icons.logout,
                          size: 30,
                          color: Color.fromRGBO(158, 158, 158, 1),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Log out",
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
                      bottomsheet(context, "Edit Account");
                      break;
                    case 2:
                      siginOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Logn()));
                      break;
                  }
                },
              ),
            )
          ],
          iconTheme: IconThemeData(color: Colors.blue, size: 28),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.width * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // border: Border.all(),
                ),
                child: Stack(
                  children: [
                    if (imagePath == "null")
                      image == null
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(),
                              ),
                              child: Center(
                                child: Text(
                                  fName[0].toUpperCase(),
                                  style: TextStyle(
                                      fontSize: width > 400 ? 80 : 40,
                                      fontFamily: "CCB"),
                                ),
                              ))
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: MediaQuery.of(context).size.width * 0.45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(width: 2),
                              ),
                              child: Image.file(image),
                            )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          "${MyApp.url}$imagePath",
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.width * 0.45,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPicker(context),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: MediaQuery.of(context).size.height * 0.04,
                          color: Colors.grey.withOpacity(0.8),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey[800],
                              size: width > 400 ? 30 : 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: width > 400 ? 30 : 20,
              ),
              Text(
                fName + " " + sName,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: width > 400 ? 50 : 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              workspaces,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        // SizedBox(height: 5),
                        Text(
                          "Workspace",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              tasks,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        // SizedBox(height: 5),
                        Text(
                          "Tasks",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "0",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        // SizedBox(height: 3),
                        Text(
                          "Notifactions",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: width > 400 ? 150 : 70,
              ),
              InkWell(
                onTap: () => bottomsheet(context, "Edit Account"),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: width - 100,
                        height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 82, 205, 0.1),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text(
                          "Edit Account",
                          style: TextStyle(fontSize: width > 400 ? 24 : 20),
                        )),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: width > 400 ? 30 : 20,
              ),
              InkWell(
                onTap: () => bottomsheet(context, "Change Password"),
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: width - 100,
                        height: MediaQuery.of(context).size.height * 0.06,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 82, 205, 0.1),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text(
                          "Change Password",
                          style: TextStyle(fontSize: width > 400 ? 24 : 20),
                        )),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _imgFromCamera(BuildContext context) async {
    // ignore: deprecated_member_use
    var _image = (await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50));
    _showAlertDilog(context, _image);
  }

  _imgFromGallery(BuildContext context) async {
    // ignore: deprecated_member_use
    var _image = (await ImagePicker.pickImage(
      source: ImageSource.gallery,
    ));
    _showAlertDilog(context, _image);
  }

  uploadimage(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (image != null) {
      var imageBytes = image.readAsBytesSync();
      var request =
          http.MultipartRequest("POST", Uri.parse("${MyApp.url}/user/avatar"));
      request.files.add(
        http.MultipartFile.fromBytes(
          "userAvatar",
          imageBytes,
          filename: basename(image.path),
          contentType: new MediaType('image', 'jpg'),
        ),
      );
      request.headers.addAll({"token": sharedPreferences.getString("token")});
      final response = await request.send();
      final resSTR = await response.stream.bytesToString();
      print(json.decode(resSTR));

      showsnakbar(json.decode(resSTR), context);
    }
  }

  //select betwen camera and storage
  _showPicker(context) {
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

  bottomsheet(BuildContext context, String select) {
    if (select == "Change Password")
      return showAdaptiveActionSheet(
        context: context,
        title: const Text('Change Password'),
        bottomSheetColor: Color.fromRGBO(226, 234, 246, 1),
        actions: <BottomSheetAction>[
          // ignore: missing_required_param
          BottomSheetAction(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 246, 255, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: textEditingControllerOldPassword,
                onFieldSubmitted: (_) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'search box is Empty';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Color.fromRGBO(0, 82, 205, 1),
                ),
                decoration: InputDecoration(
                  hintText: "Enter Old Password",
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.vpn_key_outlined,
                    color: Color.fromRGBO(0, 82, 205, 1),
                  ),
                ),
              ),
            ),
          ),
          // ignore: missing_required_param
          BottomSheetAction(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 246, 255, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: textEditingControllerNewPassword,
                onFieldSubmitted: (_) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'search box is Empty';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Color.fromRGBO(0, 82, 205, 1),
                ),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter New Password",
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.vpn_key,
                    color: Color.fromRGBO(0, 82, 205, 1),
                  ),
                ),
              ),
            ),
          ),
          // ignore: missing_required_param
          BottomSheetAction(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 246, 255, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: textEditingControllerConformNewPassword,
                onFieldSubmitted: (_) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'search box is Empty';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Color.fromRGBO(0, 82, 205, 1),
                ),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Confirm New Password",
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.vpn_key,
                    color: Color.fromRGBO(0, 82, 205, 1),
                  ),
                ),
              ),
            ),
          ),
        ],
        cancelAction: CancelAction(
          title: const Text('Save Change'),
          onPressed: () {
            Navigator.pop(context);
            _changePassword(
                context,
                textEditingControllerOldPassword.text,
                textEditingControllerNewPassword.text,
                textEditingControllerConformNewPassword.text);
          },
        ),
      );
    else
      return showAdaptiveActionSheet(
        context: context,
        title: const Text('Edit Profile'),
        bottomSheetColor: Color.fromRGBO(226, 234, 246, 1),
        actions: <BottomSheetAction>[
          // ignore: missing_required_param
          BottomSheetAction(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 246, 255, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: textEditingControllerFName,
                onFieldSubmitted: (_) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'search box is Empty';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Color.fromRGBO(0, 82, 205, 1),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.person_rounded,
                    color: Color.fromRGBO(0, 82, 205, 1),
                  ),
                ),
              ),
            ),
          ),
          // ignore: missing_required_param
          BottomSheetAction(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 246, 255, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: textEditingControllerSName,
                onFieldSubmitted: (_) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'search box is Empty';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Color.fromRGBO(0, 82, 205, 1),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.person_rounded,
                    color: Color.fromRGBO(0, 82, 205, 1),
                  ),
                ),
              ),
            ),
          ),
          // ignore: missing_required_param
          BottomSheetAction(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(243, 246, 255, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                enabled: false,
                controller: textEditingControllerEmail,
                onFieldSubmitted: (_) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'search box is Empty';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Colors.grey[400],
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.account_circle,
                    color: Color.fromRGBO(0, 82, 205, 1),
                  ),
                ),
              ),
            ),
          ),
        ],
        cancelAction: CancelAction(
          title: const Text('Update'),
          onPressed: () {
            _updateName(context);
            Navigator.pop(context);
          },
        ),
      );
  }

  name() async {
    var response = null;
    var jsonResponse = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<dynamic> list = sharedPreferences.getStringList("firstSecond");
    email = sharedPreferences.getString("email");
    setState(() {
      textEditingControllerFName.text = list[0];
      textEditingControllerSName.text = list[1];
      textEditingControllerEmail.text = email;
      fName = list[0];
      sName = list[1];
      imagePath = sharedPreferences.getString("userAvatar");
    });
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };

    var url = Uri.parse("${MyApp.url}/");
    response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = await json.decode(response.body);
    setState(() {
      workspaces = jsonResponse["assignedWorkspaces"].toString();
      tasks = jsonResponse["assignedTasks"].toString();
    });
  }

  siginOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("token");
    sharedPreferences.remove("firstSecond");
    sharedPreferences.remove("userAvatar");

    // sharedPreferences.clear();
    // ignore: deprecated_member_use
    // sharedPreferences.commit();
  }

  void evictImage(String url) {
    final NetworkImage provider = NetworkImage(url);
    if (!url.contains("null")) {
      provider.evict().then<void>((bool success) {
        if (success) debugPrint('removed image');
      });
    }
  }

  showsnakbar(var res, BuildContext context) async {
    var w = MediaQuery.of(context).size.width;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var snakbar;
    if (res["successful"] == true) {
      snakbar = SnackBar(
        duration: Duration(seconds: 5),
        content: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(
            "image is update it",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "CCB",
                fontSize: w > 400 ? 20 : 17),
          ),
          trailing: Icon(
            Icons.check,
            color: Colors.green,
          ),
        ),
      );
      sharedPreferences.setString("userAvatar", res["data"]);
      evictImage(MyApp.url + res["data"]);
      setState(() {
        imagePath = res["data"];
      });
      setState(() {
        var list = sharedPreferences.getStringList("firstSecond");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NavBar(list[0])));
      });
    } else
      snakbar = SnackBar(
        duration: Duration(seconds: 5),
        content: ListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text(
            "Error while updating image",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "CCB",
                fontSize: w > 400 ? 20 : 17),
          ),
          trailing: Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
        ),
      );
    scaffoldMessengerKey.currentState.showSnackBar(snakbar);
  }

  _showAlertDilog(BuildContext context, File _image) {
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
                  setState(() {
                    image = _image;
                  });
                  uploadimage(context);
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

  _changePassword(BuildContext context, String oldPassword, String newPassword,
      String confirmPassword) async {
    var w = MediaQuery.of(context).size.width;
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": pref.getString("token")
    };
    var response = null, jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/user/password/reset");
    if (newPassword == confirmPassword) {
      print(oldPassword + " " + newPassword + " " + confirmPassword);
      response = http.post(url,
          headers: requestHeaders,
          body: jsonEncode(<String, String>{
            "oldPassword": oldPassword,
            "newPassword": newPassword,
          }));
      print(response.body);
      jsonResponse = json.decode(response.body);

      if (jsonResponse["successful"]) {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 5),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Password is updated",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "RubikL",
                      fontSize: w > 400 ? 20 : 17),
                ),
                Icon(
                  Icons.check,
                  color: Colors.green,
                ),
              ],
            )));
      }
      if (!jsonResponse["successful"]) {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 5),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  jsonResponse["message"],
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "RubikL",
                      fontSize: w > 400 ? 20 : 17),
                ),
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.yellow,
                ),
              ],
            )));
      }
    } else {
      scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Input password Error",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "RubikL",
                    fontSize: w > 400 ? 20 : 17),
              ),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.yellow,
              ),
            ],
          )));
    }
  }

  _updateName(BuildContext context) async {
    var response = null;
    var jsonResponse = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };

    if (textEditingControllerFName.text.isNotEmpty &&
        textEditingControllerSName.text.isNotEmpty) {
      var url = Uri.parse("${MyApp.url}/profile/edit");
      response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(
          <String, String>{
            "firstName": textEditingControllerFName.text,
            "secondName": textEditingControllerSName.text,
          },
        ),
      );
      jsonResponse = await json.decode(response.body);
      if (jsonResponse["successful"] == true) {
        await sharedPreferences.setStringList('firstSecond', [
          jsonResponse['data']['firstName'],
          jsonResponse['data']['secondName'],
        ]);

        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(
              "your name will change after restart the app",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "CCB",
                  fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 13),
            ),
            trailing: Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ));
      } else {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(
              jsonResponse["message"],
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "CCB",
                  fontSize: MediaQuery.of(context).size.width > 400 ? 20 : 17),
            ),
            trailing: Icon(
              Icons.error_outline_rounded,
              color: Colors.yellow,
            ),
          ),
        ));
      }
    }
  }
}
