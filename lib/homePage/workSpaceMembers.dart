import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class WorkSpaceMember extends StatefulWidget {
  int workspaceID;
  var userAvatar;
  final Function checkWorkSpaces;
  String title;
  int taskId;

  WorkSpaceMember(
    this.workspaceID,
    this.userAvatar,
    this.checkWorkSpaces,
    this.title,
    this.taskId,
  );

  @override
  _WorkSpaceMemberState createState() => _WorkSpaceMemberState();
}

class _WorkSpaceMemberState extends State<WorkSpaceMember> {
  @override
  void initState() {
    _getMember();
    super.initState();
  }

  bool keyboard = false;
  FocusNode inputNode = FocusNode();
  TextEditingController _search = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black, fontFamily: 'RubikL'),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              widget.title == "Add Member to Workspace"
                  ? Container(
                      height: width < 400 ? 50 : 75,
                      margin: EdgeInsets.all(15),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(243, 246, 255, 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: TextFormField(
                          autofocus: keyboard,
                          controller: _search,
                          focusNode: inputNode,
                          onFieldSubmitted: (_) {
                            if (_formkey.currentState.validate()) {
                              _searchForMemberInTask(
                                  widget.workspaceID, _search.text);
                              return ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(seconds: 2),
                                      content: Text('search seccessful')));
                            } else
                              return ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(seconds: 2),
                                      content: Text('search fail')));
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'search box is Empty';
                            }
                            return null;
                          },
                          style: TextStyle(
                            fontSize: width < 400 ? 18 : 25,
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
                    )
                  : Container(),
              Expanded(
                child: Container(
                  width: width,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var image = listOfWorkspaceMembers[index]["user_avatar"];
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
                                      child: listOfWorkspaceMembers[index]
                                                  ["user_avatar"] ==
                                              null
                                          ? Container(
                                              width: width < 400 ? 50 : 60,
                                              height: width < 400 ? 50 : 60,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                      listOfWorkspaceMembers[
                                                                  index]
                                                              ["firstName"]
                                                          .toString()
                                                          .split('')[0]
                                                          .toUpperCase())))
                                          : Image.network(
                                              "${MyApp.url}$image",
                                              fit: BoxFit.cover,
                                              width: width < 400 ? 50 : 60,
                                              height: width < 400 ? 50 : 60,
                                            )),
                                  SizedBox(width: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listOfWorkspaceMembers[index]
                                            ['firstName'],
                                        style: TextStyle(
                                          fontSize: width < 400 ? 18 : 22,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        listOfWorkspaceMembers[index]
                                            ['secondName'],
                                        style: TextStyle(
                                          fontSize: width < 400 ? 18 : 22,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              widget.title == "Add Member to Workspace"
                                  ? listOfWorkspaceMembers[index]["isJoined"] ==
                                          0
                                      ? IconButton(
                                          onPressed: () {
                                            _inviteEmployeeToWorkspace(
                                                listOfWorkspaceMembers[index]
                                                    ["userId"]);
                                          },
                                          icon: Icon(
                                            Icons.person_add_rounded,
                                            size: width < 400 ? 25 : 35,
                                            color: Colors.green,
                                          ))
                                      : Container()
                                  : Container(),
                              widget.title == "Add Member to Task"
                                  ? listOfWorkspaceMembers[index]["isInTask"] ==
                                          1
                                      ? Container()
                                      : IconButton(
                                          onPressed: () {
                                            _inviteEmployeeToTask(
                                                widget.taskId,
                                                listOfWorkspaceMembers[index]
                                                    ["userId"]);
                                          },
                                          icon: Icon(
                                            Icons.person_add_rounded,
                                            size: width < 400 ? 25 : 35,
                                            color: Colors.green,
                                          ))
                                  : Container()
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
      ),
    );
  }

  // search for member
  _searchForMemberInTask(int workSpaceID, String searchcontent) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token"),
    };

    var jsonResponse = null;
    var url = Uri.parse(
        "${MyApp.url}/workspace/members/seek/$workSpaceID/$searchcontent");
    var response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = json.decode(response.body);
    if (jsonResponse["data"] != null)
      setState(() {
        listOfWorkspaceMembers = jsonResponse["data"];
      });
  }

  var listOfWorkspaceMembers = [];
  _getMember() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var jsonResponse = null;
    var url = widget.title == "Add Member to Task"
        ? Uri.parse(
            "${MyApp.url}/workspace/${widget.workspaceID}/task/${widget.taskId}/members")
        : Uri.parse("${MyApp.url}/workspace/${widget.workspaceID}");
    var response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = json.decode(response.body);
    setState(() {
      listOfWorkspaceMembers = widget.title == "Add Member to Task"
          ? jsonResponse["data"]
          : jsonResponse["data"]["users"];
    });
  }

  //invite employee
  _inviteEmployeeToWorkspace(int employeeID) async {
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
    widget.checkWorkSpaces();
    Navigator.pop(context);
  }

  _inviteEmployeeToTask(int taskId, int newMemberId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var url = Uri.parse("${MyApp.url}/workspace/task/add/member");
    await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(
        <String, dynamic>{"taskId": taskId, "newMemberId": newMemberId},
      ),
    );
    widget.checkWorkSpaces();
    Navigator.pop(context);
  }

  _setTaskAction() async {}

  _inviteMemberToTask(int taskID, int memberID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/task/add/member");
    var response = await http.post(url,
        headers: requestHeaders,
        body: jsonEncode(
            <String, int>{"taskId": taskID, "newMemberId": memberID}));
    jsonResponse = json.decode(response.body);
    setState(() {
      _getMember();
      widget.checkWorkSpaces();
    });
  }
}
