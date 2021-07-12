import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// ignore: must_be_immutable
class CreateNewTask extends StatefulWidget {
  String title;
  int workspaceId;
  final Function checkExsitingTask;
  int taskID;
  int role;

  CreateNewTask(this.title, this.workspaceId, this.checkExsitingTask,
      this.taskID, this.role);

  @override
  _CreateNewTaskState createState() => _CreateNewTaskState();
}

class _CreateNewTaskState extends State<CreateNewTask> {
  bool reminder = false;

  static final Map<String, String> priorty = {
    'normal': 'NORMAL',
    'urgent': 'Urgent'
  };

  List listOfMember = [
    'waiting',
    'inProcess',
    'stack',
    'done',
    'low',
    'medium',
    'high',
    'urgent'
  ];

  String _selectedPriorty = priorty.keys.first;

  void onStatusPriorty(String priortyKey) {
    setState(() {
      _selectedPriorty = priortyKey;
    });
    print(_selectedPriorty);
  }

  TextEditingController _textEditingControllerTitle = TextEditingController();
  TextEditingController _textEditingControllerContent = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  var memberOfTask = [];

  TextEditingController _searchForMember = TextEditingController();
  bool keyboard = false;
  FocusNode inputNode = FocusNode();

  Icon addMemberToTask = Icon(
    Icons.person_add_rounded,
    color: Colors.green,
    size: 25,
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
            actions: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18)),
                padding: EdgeInsets.symmetric(horizontal: 5),
                margin: EdgeInsets.only(right: 10, top: 7),
                child: PopupMenuButton(
                  icon: Icon(Icons.more_vert, size: 28, color: Colors.blue),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            widget.title == "Edit Task"
                                ? Icons.update_outlined
                                : Icons.save,
                            size: 30,
                            color: Color.fromRGBO(158, 158, 158, 1),
                          ),
                          SizedBox(width: 12),
                          Text(
                            widget.title == "Edit Task"
                                ? "Save Change"
                                : "Save Task",
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
                            widget.title == "Edit Task"
                                ? Icons.edit
                                : Icons.add,
                            size: 30,
                            color: Color.fromRGBO(158, 158, 158, 1),
                          ),
                          SizedBox(width: 12),
                          Text(
                            widget.title == "Edit Task"
                                ? "Task Members"
                                : "Add Member",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "RubicB",
                            ),
                          )
                        ],
                      ),
                    ),
                    widget.title == "Edit Task"
                        ? widget.role == 0
                            ? PopupMenuItem(
                                value: 3,
                                child: Row(
                                  children: [
                                    Icon(
                                      widget.title == "Edit Task"
                                          ? Icons.remove_circle
                                          : null,
                                      size: 30,
                                      color: Colors.red[200],
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Leave",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: "RubicB",
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : null
                        : null,
                    PopupMenuItem(
                      value: 4,
                      child: Row(
                        children: [
                          Icon(
                            widget.title == "Edit Task"
                                ? Icons.cancel
                                : Icons.cancel,
                            size: 30,
                            color: Color.fromRGBO(158, 158, 158, 1),
                          ),
                          SizedBox(width: 12),
                          Text(
                            widget.title == "Edit Task" ? "Cancel" : "Cancel",
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
                          widget.title == "Edit Task"
                              ? _updateTask(
                                  title: _textEditingControllerTitle.text,
                                  content: _textEditingControllerContent.text,
                                  priorty: _selectedPriorty,
                                  taskID: widget.taskID)
                              : _saveTask(
                                  title: _textEditingControllerTitle.text,
                                  content: _textEditingControllerContent.text,
                                  priorty: _selectedPriorty);
                        }
                        break;
                      case 2:
                        {
                          _getMemberToInvite();
                        }

                        break;

                      case 3:
                        _leave(widget.taskID);
                        break;
                      case 4:
                        widget.title == "Edit Task"
                            ? Navigator.pop(context)
                            : Navigator.pop(context);
                        break;
                    }
                  },
                ),
              )
            ],
            iconTheme: IconThemeData(color: Colors.blue, size: 28),
          ),
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  part1(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget part1() {
    var children2 = <Widget>[
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
            controller: _textEditingControllerTitle,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "Task Name",
              contentPadding: EdgeInsets.only(left: 30, top: 15, bottom: 15),
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
            controller: _textEditingControllerContent,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: "Task Description",
              contentPadding: EdgeInsets.only(left: 30, top: 15, bottom: 15),
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

      // Text(
      //   "Title",
      //   style: TextStyle(
      //       color: Color.fromRGBO(0, 122, 255, 1),
      //       fontSize: 27,
      //       fontWeight: FontWeight.bold),
      // ),
      // // enter title of task
      // TextField(
      //   style: TextStyle(fontSize: 38, color: Colors.black),
      //   decoration: InputDecoration(
      //       focusedBorder: UnderlineInputBorder(
      //         borderSide: BorderSide(color: Colors.grey),
      //       ),
      //       enabledBorder: UnderlineInputBorder(
      //         borderSide: BorderSide(color: Colors.grey),
      //       ),
      //       border: OutlineInputBorder()),
      //   controller: _textEditingControllerTitle,
      // ),
      // SizedBox(height: 40),
      // SizedBox(height: 40),
      // Text(
      //   "Content",
      //   style: TextStyle(
      //       color: Color.fromRGBO(0, 122, 255, 1),
      //       fontSize: 27,
      //       fontWeight: FontWeight.bold),
      // ),
      // // enter content of the task
      // TextField(
      //   style: TextStyle(fontSize: 20, color: Colors.black),
      //   decoration: InputDecoration(
      //       focusedBorder: UnderlineInputBorder(
      //         borderSide: BorderSide(color: Colors.grey),
      //       ),
      //       enabledBorder: UnderlineInputBorder(
      //         borderSide: BorderSide(color: Colors.grey),
      //       ),
      //       border: OutlineInputBorder()),
      //   controller: _textEditingControllerContent,
      // ),
      // widget.title != "Edit Task" ? Container() : _status(),
      // SizedBox(height: 40),
      // SizedBox(height: 40),
      Text(
        "Priorty",
        style: TextStyle(
            color: Color.fromRGBO(0, 104, 255, 1),
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 20),
      CupertinoRadioChoice(
        choices: priorty,
        onChange: onStatusPriorty,
        initialKeyValue: 'low',
      ),
    ];
    return Container(
      padding: EdgeInsets.only(left: 35, top: 20),
      width: MediaQuery.of(context).size.width - 30,
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children2,
      ),
    );
  }

  _updateTask(
      {String title, String content, String priorty, int taskID}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/task/edit");

    if (title.isNotEmpty) {
      var response = await http.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "taskId": taskID,
            "taskTitle": title,
            "taskContent": content,
            "priority": priorty,
          }));
      jsonResponse = json.decode(response.body);
      if (jsonResponse["successful"]) {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "Task is Create",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )));
        widget.checkExsitingTask();
        Navigator.pop(context);
      }
      if (!jsonResponse["successful"]) {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.yellow),
                SizedBox(width: 10),
                Text(
                  jsonResponse["message"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )));
      }
    } else {
      scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow),
              SizedBox(width: 10),
              Text(
                "task title is Empty",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )));
    }
  }

  _saveTask({String title, String content, String priorty}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/new/task");

    if (title.isNotEmpty) {
      var response = await http.post(url,
          headers: requestHeaders,
          body: jsonEncode({
            "workspace_id": widget.workspaceId,
            "taskTitle": title,
            "taskContent": content,
            "priority": priorty,
            "assignedMembers": memberOfTask
          }));
      jsonResponse = json.decode(response.body);
      if (jsonResponse["successful"]) {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  "Task is Create",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )));
        widget.checkExsitingTask();
        Navigator.pop(context);
      }
      if (!jsonResponse["successful"]) {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.yellow),
                SizedBox(width: 10),
                Text(
                  jsonResponse["message"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )));
      }
    } else {
      scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow),
              SizedBox(width: 10),
              Text(
                "task title is Empty",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )));
    }
  }

  showsnakbar(String type, String msg) {
    var snakbar;
    snakbar = SnackBar(
        duration: Duration(seconds: 5),
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.yellow),
            SizedBox(width: 10),
            Text(
              msg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ));
    scaffoldMessengerKey.currentState.showSnackBar(snakbar);
  }

  var listOfWorkspaceMembers = [];

  _showDialogInvition(int workSpaceID) {
    var w = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          elevation: 5,
          title: new Text("Add Member To Task"),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // widget.workspaceId != null
                //     ? Container(
                //         height: w > 400 ? 70 : 60,
                //         margin: EdgeInsets.all(15),
                //         padding: EdgeInsets.symmetric(horizontal: 10),
                //         decoration: BoxDecoration(
                //             color: Color.fromRGBO(243, 246, 255, 1),
                //             borderRadius: BorderRadius.circular(10)),
                //         child: Center(
                //           child: TextFormField(
                //             autofocus: keyboard,
                //             focusNode: inputNode,
                //             controller: _searchForMember,
                //             onFieldSubmitted: (_) {
                //               _searchForMemberInTask(
                //                   workSpaceID, _searchForMember.text);
                //             },
                //             // ignore: missing_return
                //             validator: (value) {
                //               if (value == null || value.isEmpty) {
                //                 return 'search box is Empty';
                //               }
                //               return null;
                //             },
                //             style: TextStyle(
                //               fontSize: w > 400 ? 22 : 18,
                //               color: Color.fromRGBO(0, 82, 205, 1),
                //             ),
                //             decoration: InputDecoration(
                //               border: InputBorder.none,
                //               hintText: "Search for Member",
                //               // hintStyle: TextStyle(
                //               //   fontSize: 25,
                //               // ),
                //               icon: Icon(Icons.search, size: 30),
                //             ),
                //           ),
                //         ),
                //       )
                //     : null,
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var image =
                            listOfWorkspaceMembers[index]["user_avatar"];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: image == null
                                    ? Container(
                                        width: w > 400 ? 60 : 40,
                                        height: w > 400 ? 60 : 40,
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
                                        fit: BoxFit.cover,
                                        width: w > 400 ? 60 : 40,
                                        height: w > 400 ? 60 : 40,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
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
                              Flexible(
                                child: Text(
                                  "${listOfWorkspaceMembers[index]['firstName']} ${listOfWorkspaceMembers[index]['secondName']}",
                                  style: TextStyle(
                                    fontSize: w > 400 ? 22 : 18,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                  icon: addMemberToTask,
                                  onPressed: () {
                                    Map member;
                                    if (!memberOfTask.contains(
                                        listOfWorkspaceMembers[index]
                                            ["userId"])) {
                                      member = {
                                        "userId": listOfWorkspaceMembers[index]
                                            ["userId"]
                                      };
                                      member.forEach((key, value) {
                                        memberOfTask.add(member);
                                      });
                                    }
                                  })
                            ],
                          ),
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
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
                    duration: Duration(seconds: 2),
                    content: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 10),
                        Text(
                          memberOfTask.length.toString() +
                              " Member add to task",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )));
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
    var url = Uri.parse("${MyApp.url}/workspace/members/${widget.workspaceId}");
    var response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = json.decode(response.body);
    setState(() {
      if (widget.workspaceId != null) {
        listOfWorkspaceMembers = jsonResponse["data"];
      }
    });
    _showDialogInvition(widget.workspaceId);
  }

  //search for member using API
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

  _leave(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // ignore: avoid_init_to_null
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/task/leave/$id");
    var response = await http.delete(
      url,
      headers: {
        "Content-type": "application/json; charset=UTF-8",
        "token": sharedPreferences.getString("token"),
      },
    );
    jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print(jsonResponse["success"]);
      setState(() {
        widget.checkExsitingTask;
      });
      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      print(jsonResponse["error"]);
    }
  }
}
