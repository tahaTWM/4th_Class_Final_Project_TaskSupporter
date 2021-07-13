import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app2/all_tasks/attachment.dart';
import 'package:app2/all_tasks/taskDetials.dart';
import 'package:app2/homePage/workSpaceMembers.dart';
import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import '../canlendar/craeteNewTask.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main.dart';

// ignore: must_be_immutable
class ShowAllTasks extends StatefulWidget {
  String workSpaceTitle;
  int workspaceId;
  String role;
  String userAvatar;

  ShowAllTasks(
      this.workSpaceTitle, this.workspaceId, this.role, this.userAvatar);

  @override
  _ShowAllTasksState createState() => _ShowAllTasksState();
}

class _ShowAllTasksState extends State<ShowAllTasks>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  var listOfTasksWaiting = [];
  var listOfTasksInProcess = [];
  var listOfTasksStack = [];
  var listOfTasksDone = [];
  var _picker = ImagePicker();
  var workspaceId;
  ScrollController _scrollController = ScrollController();

  bool closeTask = false;

  File file;

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    checkIfThereAnyTaskes();
    super.initState();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool istaskFound = false;

  static final Map<String, String> status = {
    'WAITING': 'WAITING',
    'IN_PROGRESS': 'IN_PROGRESS',
    'STUCk': 'STUCk',
    'DONE': 'DONE'
  };

  String _selectedStatus = status.keys.first;

  void onStatusSelected(String statusKey) {
    setState(() {
      _selectedStatus = statusKey;
    });
  }

  TextEditingController _action = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    istaskFound
        ? Timer(
            Duration(seconds: 1),
            () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              curve: Curves.easeInOut,
              duration: Duration(seconds: 1),
            ),
            // ignore: unnecessary_statements
          )
        // ignore: unnecessary_statements
        : null;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(243, 246, 255, 1),
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Row(
            children: [
              widget.userAvatar == "null"
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(),
                      ),
                      child: Center(
                        child: Text(
                          widget.workSpaceTitle.split('')[0],
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontFamily: "CCB"),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        "${MyApp.url}${widget.userAvatar}",
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
              SizedBox(width: 20),
              Text(
                widget.workSpaceTitle,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontFamily: "RubikL",
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 20),
                            //Task and new Task
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Tasks",
                                  style: TextStyle(
                                      fontSize: 38,
                                      fontFamily: "RubikB",
                                      color: Colors.black),
                                ),
                                // ignore: deprecated_member_use
                                RaisedButton.icon(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  elevation: 9,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CreateNewTask(
                                                "Create New Task",
                                                widget.workspaceId,
                                                checkIfThereAnyTaskes,
                                                null,
                                                null)));
                                  },
                                  icon: Icon(Icons.add,
                                      size: w > 400 ? 30 : 20,
                                      color: Color.fromRGBO(62, 128, 255, 1)),
                                  label: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 2, bottom: 2),
                                    child: Text(
                                      "New",
                                      style: TextStyle(
                                          fontSize: w > 400 ? 25 : 20,
                                          color:
                                              Color.fromRGBO(62, 128, 255, 1)),
                                    ),
                                  ),
                                  color: Color.fromRGBO(210, 228, 255, 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                ),
                              ],
                            ),
                          ),
                          // search bar
                          Container(
                            height: w > 400 ? 70 : 50,
                            margin: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(
                                  243,
                                  246,
                                  255,
                                  1,
                                ),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: TextField(
                                style: TextStyle(
                                  fontSize: w > 400 ? 25 : 20,
                                  color: Color.fromRGBO(0, 82, 205, 1),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search tasks...",
                                  hintStyle: TextStyle(
                                    fontSize: w > 400 ? 25 : 20,
                                  ),
                                  icon: Icon(Icons.search,
                                      size: w > 400 ? 30 : 20),
                                ),
                                enabled: false,
                              ),
                            ),
                          ),
                          TabBar(
                            isScrollable: true,
                            unselectedLabelColor: Colors.grey,
                            labelColor: Colors.blue,
                            indicator: CircleTabIndicator(
                                color: Colors.blue, radius: 5),
                            tabs: [
                              Tab(
                                child: Row(
                                  children: [
                                    Text(
                                      "Waiting",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Rubik",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "\(" +
                                          listOfTasksWaiting.length.toString() +
                                          "\)",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  children: [
                                    Text(
                                      "InProcess",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Rubik",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "\(" +
                                          listOfTasksInProcess.length
                                              .toString() +
                                          "\)",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  children: [
                                    Text(
                                      "Stuck",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Rubik",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "\(" +
                                          listOfTasksStack.length.toString() +
                                          "\)",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  children: [
                                    Text(
                                      "Done",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Rubik",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "\(" +
                                          listOfTasksDone.length.toString() +
                                          "\)",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                          ),
                        ],
                      ),
                    ),
                    // for tavView
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TabBarView(
                          children: [
                            tabViewForTabBarAndTabView(
                                listOfTasksWaiting, "WAITING"),
                            tabViewForTabBarAndTabView(
                                listOfTasksInProcess, "IN_PROGRESS"),
                            tabViewForTabBarAndTabView(
                                listOfTasksStack, "STUCK"),
                            tabViewForTabBarAndTabView(listOfTasksDone, "DONE"),
                          ],
                          controller: _tabController,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabViewForTabBarAndTabView(List listOfTasks, String OldStatus) {
    var width = MediaQuery.of(context).size.width;
    if (listOfTasks.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        // color: Color.fromRGBO(243, 246, 255, 1),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            List<dynamic> newListReversed = listOfTasks.reversed.toList();
            var newDateTime =
                DateTime.parse(newListReversed[index]["taskCreationDate"]);

            return Container(
              padding: EdgeInsets.only(top: 3, left: 20, right: 20, bottom: 5),
              margin: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //line of prority and more
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                              color:
                                  newListReversed[index]["prority"] == "URGENT"
                                      ? Color.fromRGBO(248, 135, 135, 1)
                                      : Color.fromRGBO(46, 204, 113, 1),
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        PopupMenuButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          icon: Icon(Icons.more_horiz,
                              color: Colors.grey, size: 40),
                          itemBuilder: (context) => [
                            newListReversed[index]["isTaskOwner"] == 1
                                ? PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 30,
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Delete",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "RubicB",
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 30,
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
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
                                  ),
                            newListReversed[index]["isTaskOwner"] == 1
                                ? PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: 30,
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Edit",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "RubicB",
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : null,
                            PopupMenuItem(
                              value: 3,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.comment_bank_rounded,
                                    size: 30,
                                    color: Color.fromRGBO(158, 158, 158, 1),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Add Action",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "RubicB",
                                    ),
                                  )
                                ],
                              ),
                            ),
                            newListReversed[index]["isTaskOwner"] == 1
                                ? PopupMenuItem(
                                    value: 4,
                                    child: Row(children: [
                                      Icon(
                                        Icons.add_circle_rounded,
                                        size: 30,
                                        color: Color.fromRGBO(158, 158, 158, 1),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Add Memeber",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "RubicB",
                                        ),
                                      ),
                                    ]),
                                  )
                                : null
                          ],
                          onSelected: (item) {
                            switch (item) {
                              case 1:
                                {
                                  newListReversed[index]["isTaskOwner"] == 1
                                      ? delete(newListReversed[index]["taskId"])
                                      : leave(newListReversed[index]["taskId"]);
                                }
                                break;
                              case 2:
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateNewTask(
                                            "Edit Task",
                                            widget.workspaceId,
                                            checkIfThereAnyTaskes,
                                            newListReversed[index]["taskId"],
                                            newListReversed[index]
                                                ["isTaskOwner"])));
                                break;
                              case 3:
                                _showDialogAction(
                                    newListReversed[index]["taskId"],
                                    OldStatus,
                                    newListReversed[index]["taskId"],
                                    newListReversed[index]["title"]);
                                break;
                              case 4:
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => WorkSpaceMember(
                                                widget.workspaceId,
                                                null,
                                                checkIfThereAnyTaskes,
                                                "Add Member to Task",
                                                newListReversed[index]
                                                    ["taskId"],
                                              )));
                                }
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetails(
                            title: newListReversed[index]["title"],
                            prority: newListReversed[index]["prority"],
                            taskID: newListReversed[index]["taskId"],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //task title and time ago for task
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  newListReversed[index]["title"],
                                  style: TextStyle(
                                    fontSize: width > 400 ? 30 : 22,
                                    fontFamily: "RubikB",
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                timeago.format(newDateTime),
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width > 400
                                            ? 22
                                            : 18,
                                    fontFamily: "Rubik",
                                    color: Color.fromRGBO(158, 158, 158, 1)),
                              ),
                            ],
                          ),
                        ),
                        //task description
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            newListReversed[index]["content"],
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 400
                                        ? 22
                                        : 20,
                                fontFamily: "Rubik",
                                color: Color.fromRGBO(158, 158, 158, 1)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // members in task and attachment
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          color: Color.fromRGBO(158, 158, 158, 1),
                          size: 25,
                        ),
                        SizedBox(width: 10),
                        Text(
                          newListReversed[index]["taskMembers"]
                              .length
                              .toString(),
                          style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 18),
                        ),
                        SizedBox(width: 30),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Attachment()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.attachment_rounded,
                                color: Color.fromRGBO(158, 158, 158, 1),
                                size: 25,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Attachment",
                                style: TextStyle(
                                    color: Color.fromRGBO(158, 158, 158, 1),
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: listOfTasks.length,
        ),
      );
    } else
      return Container(
          width: 200,
          height: 100,
          // color: Color.fromRGBO(156, 176, 207, 1),
          margin: EdgeInsets.only(top: 10, left: 20, right: 20),
          child: Center(
            child: Text(
              "No Task Add Yet!!",
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontFamily: "RubikL",
              ),
            ),
          ));
  }

  //get task from api
  checkIfThereAnyTaskes() async {
    var jsonResponse = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      'token': sharedPreferences.getString("token"),
    };
    var url = Uri.parse(
        '${MyApp.url}/workspace/tasks/${widget.workspaceId}/${widget.role}');
    var response = await http.get(
      url,
      headers: requestHeaders,
    );

    jsonResponse = json.decode(response.body);
    if (jsonResponse["successful"]) {
      setState(() {
        listOfTasksWaiting = jsonResponse['data']["WAITING"];
        listOfTasksInProcess = jsonResponse['data']["IN_PROGRESS"];
        listOfTasksStack = jsonResponse['data']["STUCK"];
        listOfTasksDone = jsonResponse['data']["DONE"];
        workspaceId = jsonResponse["data"]["workspaceId"];
      });
      setState(() {
        istaskFound = false;
      });
    }
    if (!jsonResponse["successful"]) {
      scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            "No Task Add Yet",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )));
      setState(() {
        istaskFound = false;
      });
    }
  }

  delete(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // ignore: avoid_init_to_null
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/task/delete/$id");
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
        checkIfThereAnyTaskes();
      });
      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      print(jsonResponse["error"]);
    }
  }

  leave(int id) async {
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
        checkIfThereAnyTaskes();
      });
      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      print(jsonResponse["error"]);
    }
  }

  Column _status() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          "Status",
          style: TextStyle(
              color: Color.fromRGBO(0, 122, 255, 1),
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        CupertinoRadioChoice(
          choices: status,
          onChange: onStatusSelected,
          initialKeyValue: 'waiting',
        ),
      ],
    );
  }

  _showDialogAction(
      int taskID, String oldStatus, int taskid, String taskName) async {
    _action.clear();
    var w = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          elevation: 5,
          title: Center(
            child: Text("Task Action"),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: [
                Center(
                    child: Text(
                  taskName,
                  style: TextStyle(
                    fontSize: w > 400 ? 23 : 20,
                    color: Color.fromRGBO(0, 82, 205, 1),
                    fontWeight: FontWeight.bold,
                  ),
                )),
                SizedBox(height: 10),
                _status(),
                SizedBox(height: 10),
                Container(
                  height: w > 400 ? 200 : 150,
                  // margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        223,
                        231,
                        255,
                        1,
                      ),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: TextField(
                      maxLines: 8,
                      controller: _action,
                      style: TextStyle(
                        fontSize: w > 400 ? 20 : 16,
                        color: Color.fromRGBO(0, 82, 205, 1),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.only(left: 10, right: 10, top: 10),
                        hintText:
                            "Please leave a comment or let's us know your progress.",
                        hintStyle: TextStyle(
                          fontSize: w > 400 ? 20 : 16,
                        ),
                      ),
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
              child: new Text(
                "Close",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(
                "Submit",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                _updateTaskAction(oldStatus, taskid);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _updateTaskAction(String oldStatus, int taskid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var respnse = null;
    var jsonResponse = null;
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var url = Uri.parse("${MyApp.url}/task/action");
    respnse = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(
        <String, dynamic>{
          "comment": _action.text,
          "old_task_status": oldStatus,
          "new_task_status": _selectedStatus,
          "action_type": _action.text.isNotEmpty ? "COMMENT" : "OPEN",
          "task_id": taskid
        },
      ),
    );
    jsonResponse = json.decode(respnse.body);

    setState(() {
      checkIfThereAnyTaskes();
    });
  }
}

//this class and the class below it to add dot below tapbar
class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
