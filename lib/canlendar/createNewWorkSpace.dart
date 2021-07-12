import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../navBar.dart';

class CreateNewWorkSpace extends StatefulWidget {
  String title;
  int workspaceID;
  String workspaceName;
  String workspaceDesc;
  var userAvatart;

  CreateNewWorkSpace(this.title, this.workspaceID, this.workspaceName,
      this.workspaceDesc, this.userAvatart);

  @override
  _CreateNewWorkSpaceState createState() => _CreateNewWorkSpaceState();
}

class _CreateNewWorkSpaceState extends State<CreateNewWorkSpace> {
  TextEditingController _workspaceTitle = TextEditingController();
  TextEditingController _workspaceDesc = TextEditingController();
  bool reminder = false;
  var errorMSG = "";
  var listfirstSecond;
  final _formkey = GlobalKey<FormState>();

  var listOfWorkspaceMembers = [];

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  TextEditingController _searchForMember = TextEditingController();
  bool keyboard = false;
  FocusNode inputNode = FocusNode();
  var membersOfWorkspace = [];

  @override
  void initState() {
    super.initState();
    if (widget.title == "Edit WorkSpace") {
      _workspaceTitle.text = widget.workspaceName;
      _workspaceDesc.text = widget.workspaceDesc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(250, 250, 250, 2),
            elevation: 0,
            title: Text(
              widget.title,
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            // actions: [asset/
            //   Container(
            //     decoration: BoxDecoration(
            //         color: Colors.white, borderRadius: BorderRadius.circular(18)),
            //     padding: EdgeInsets.symmetric(horizontal: 12),
            //     margin: EdgeInsets.only(right: 10, top: 7),
            //     child: Icon(Icons.more_vert, size: 28, color: Colors.blue),
            //   )
            // ],
            iconTheme: IconThemeData(color: Colors.blue, size: 28),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  upperPart(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  createWorkspace(String title, String desc) async {
    FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token"),
    };
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/create");
    var response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(
        <String, String>{"workspaceName": title, "workspaceDescription": desc},
      ),
    );
    jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse["successful"]) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  NavBar(sharedPreferences.getStringList('firstSecond')[0])));
    }
    if (!jsonResponse["successful"]) {
      scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow),
              SizedBox(width: 10),
              Text(
                  "${jsonResponse["data"]["type"] == "workspaceName" ? "WorkSpace title is Empty" : "Description is Empty"}"),
            ],
          )));
    }
    // if (response.statusCode == 200) {
    //   if (jsonResponse != null) {
    //
    //     // Navigator.push(
    //     //     context,
    //     //     MaterialPageRoute(
    //     //         builder: (context) =>
    //     //             NavBar(sharedPreferences.getStringList('firstSecond')[0])));
    //   }
    // } else if (response.statusCode == 400) {
    //   setState(() {
    //     errorMSG = jsonResponse["error"].toString();
    //     _workspaceTitle.clear();
    //     _workspaceDesc.clear();
    //   });
    // } else {
    //   print("undefine Case!!");
    // }
  }

  updateWorkspace(String title, String desc) async {
    FocusScope.of(context).requestFocus(FocusNode());
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token"),
    };
    var jsonResponse = null;
    var response = null;
    var url = Uri.parse("${MyApp.url}/workspace/update");
    if (title.isEmpty) {
      scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow),
              SizedBox(width: 10),
              Text("workspace name is Empty"),
            ],
          )));
    } else {
      response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(
          <String, dynamic>{
            "workspaceId": widget.workspaceID,
            "updateWorkspaceName": title,
            "updateWorkspaceDescription": desc
          },
        ),
      );
    }
    jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (jsonResponse['successful']) {
      var list2 = await sharedPreferences.getStringList("firstSecond");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NavBar(list2[0])));
    }

    // if (response.statusCode == 400) {
    //   setState(() {
    //     errorMSG = jsonResponse["error"].toString();
    //     _workspaceTitle.clear();
    //     _workspaceDesc.clear();
    //   });
    // } else {
    //   print("undefine Case!!");
    // }
  }

  Widget upperPart() {
    return Container(
      padding: EdgeInsets.only(left: 35, top: 20),
      width: MediaQuery.of(context).size.width - 30,
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(errorMSG),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
                maxLength: 100,
                autofocus: false,
                textAlign: TextAlign.start,
                // ignore: deprecated_member_use
                autovalidate: true,
                style: Theme.of(context).textTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                controller: _workspaceTitle,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "Workspace Name",
                  contentPadding:
                      EdgeInsets.only(left: 30, top: 15, bottom: 15),
                  labelStyle: TextStyle(fontSize: 24),
                  errorStyle: Theme.of(context).textTheme.caption.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  hintText: "Enter ",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  focusColor: Color.fromRGBO(0, 104, 255, 1),
                ),
                onChanged: (str) {
                  // To do
                },
                onSaved: (str) {
                  // To do
                },
                onFieldSubmitted: (value) {}),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
                maxLength: 255,
                autofocus: false,
                textAlign: TextAlign.start,
                // ignore: deprecated_member_use
                autovalidate: true,
                style: Theme.of(context).textTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                controller: _workspaceDesc,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: "Workspace Description",
                  contentPadding:
                      EdgeInsets.only(left: 30, top: 15, bottom: 15),
                  labelStyle: TextStyle(fontSize: 24),
                  errorStyle: Theme.of(context).textTheme.caption.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  hintText: "Enter ",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(0, 104, 255, 1),
                    ),
                  ),
                  focusColor: Color.fromRGBO(0, 104, 255, 1),
                ),
                onChanged: (str) {
                  // To do
                },
                onSaved: (str) {
                  // To do
                },
                onFieldSubmitted: (value) {}),
          ),

          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                color: Color.fromRGBO(216, 229, 255, 1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    width: 1, color: Color.fromRGBO(0, 104, 255, 1))),
            width: double.infinity,
            height: 60,
            // ignore: deprecated_member_use
            child: FlatButton(
              onPressed: () async {
                widget.title == 'Edit WorkSpace'
                    ? updateWorkspace(_workspaceTitle.text, _workspaceDesc.text)
                    : createWorkspace(
                        _workspaceTitle.text, _workspaceDesc.text);
              },
              child: Text(
                widget.title == 'Edit WorkSpace' ? "Update" : "Save",
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Rubik",
                    color: Color.fromRGBO(62, 128, 255, 1)),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(0),
          //   child: Center(
          //     // ignore: deprecated_member_use
          //     child: RaisedButton.icon(
          //       onPressed: () {
          //         widget.title == 'Edit WorkSpace'
          //             ? updateWorkspace(
          //                 _workspaceTitle.text, _workspaceDesc.text)
          //             : createWorkspace(
          //                 _workspaceTitle.text, _workspaceDesc.text);
          //       },
          //       icon: Icon(
          //         Icons.download_done_rounded,
          //         size: MediaQuery.of(context).size.width > 400 ? 50 : 30,
          //       ),
          //       label: Padding(
          //         padding:
          //             const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          //         child: Text(
          //           widget.title == 'Edit WorkSpace' ? "Update" : "Save",
          //           style: TextStyle(
          //               fontFamily: "Rubik",
          //               fontSize:
          //                   MediaQuery.of(context).size.width > 400 ? 30 : 20),
          //         ),
          //       ),
          //       color: Colors.lightBlue[300],
          //       elevation: 10,
          //       shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10)),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  _showDialogInvition(int workSpaceID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          elevation: 5,
          title: new Text("Search for Member"),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: [
                Container(
                  height: 75,
                  margin: EdgeInsets.all(15),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(243, 246, 255, 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextFormField(
                      autofocus: keyboard,
                      focusNode: inputNode,
                      controller: _searchForMember,
                      onFieldSubmitted: (_) {
                        _searchForMemberInTask(
                            workSpaceID, _searchForMember.text);
                      },
                      // ignore: missing_return
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'search box is Empty';
                        }
                        return null;
                      },
                      style: TextStyle(
                        fontSize: 25,
                        color: Color.fromRGBO(0, 82, 205, 1),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search for Member",
                        // hintStyle: TextStyle(
                        //   fontSize: 25,
                        // ),
                        icon: Icon(Icons.search, size: 30),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var image =
                            listOfWorkspaceMembers[index]["user_avatar"];
                        print(image);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: image == null
                                          ? Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  listOfWorkspaceMembers[index]
                                                          ["firstName"][0]
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontFamily: "CCB",
                                                      fontSize: 24),
                                                ),
                                              ),
                                            )
                                          : Image.network(
                                              "${MyApp.url}$image",
                                              fit: BoxFit.fill,
                                              width: 60,
                                              height: 60,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent
                                                          loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                    SizedBox(width: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listOfWorkspaceMembers[index]
                                              ['firstName'],
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          listOfWorkspaceMembers[index]
                                              ['secondName'],
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                listOfWorkspaceMembers[index]["isJoined"] == 1
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.person_remove_rounded,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                        onPressed: () {})
                                    : IconButton(
                                        icon: Icon(
                                          Icons.person_add_rounded,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          _inviteEmployee(
                                              listOfWorkspaceMembers[index]
                                                  ["userId"]);
                                        })
                              ]),
                        );
                      },
                      itemCount: listOfWorkspaceMembers.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _getMemberToInvite() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token"),
    };

    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/members/${widget.workspaceID}");
    var response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = json.decode(response.body);
    print(jsonResponse["data"]);
    setState(() {
      if (widget.workspaceID != null) {
        listOfWorkspaceMembers = jsonResponse["data"];
      }
    });
    _showDialogInvition(widget.workspaceID);
  }

  //search for member using API
  _searchForMemberInTask(int workSpaceID, String Searchcontent) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token"),
    };
    var jsonResponse = null;
    var url = Uri.parse(
        "${MyApp.url}/workspace/members/seek/$workSpaceID/$Searchcontent");
    var response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = json.decode(response.body);
    if (jsonResponse["data"] != null)
      setState(() {
        listOfWorkspaceMembers = jsonResponse["data"];
      });
    listOfWorkspaceMembers.forEach((element) {
      if (element["user_avatar"] != null) print(element);
    });
  }

  //invite employee
  _inviteEmployee(int employeeID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var url = Uri.parse("${MyApp.url}/workspace/invite");
    await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(
        <String, dynamic>{
          "workspaceId": widget.workspaceID,
          "employeeId": employeeID
        },
      ),
    );
    Navigator.pop(context);
  }
}
