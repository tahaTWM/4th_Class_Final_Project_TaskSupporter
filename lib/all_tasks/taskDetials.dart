import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

import 'package:http/http.dart' as http;

import 'package:timeago/timeago.dart' as timeago;

class TaskDetails extends StatefulWidget {
  String title;
  String prority;
  int taskID;

  TaskDetails({@required this.title, @required this.prority, this.taskID});

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final ScrollController scrollController = ScrollController();

  var _history = [];
  var _timeSort = [];

  @override
  void initState() {
    _showHistory(widget.taskID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var padding = EdgeInsets.symmetric(vertical: 10, horizontal: 20);
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 246, 255, 1),
      appBar: AppBar(
        backgroundColor: widget.prority == "URGENT"
            ? Color.fromRGBO(248, 135, 135, 1)
            : Color.fromRGBO(46, 204, 113, 1),
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontFamily: "RubikL",
              fontWeight: FontWeight.w800),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _history != null
          ? Scrollbar(
              radius: Radius.circular(5),
              isAlwaysShown: true,
              controller: scrollController,
              child: Container(
                padding: EdgeInsets.all(5),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _history.length,
                  itemBuilder: (BuildContext context, int index) {
                    var url = "${MyApp.url}${_history[index]["user_avatar"]}";

                    return Column(
                      children: [
                        ListTile(
                            contentPadding: EdgeInsets.only(
                                bottom: 10, left: 10, right: 10, top: 5),
                            leading: url.contains("null")
                                ? Container(
                                    padding: EdgeInsets.all(10),
                                    decoration:
                                        BoxDecoration(shape: BoxShape.circle),
                                    child: Text(_history[index]["firstName"]
                                        .toString()[0]
                                        .toUpperCase()),
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        "${MyApp.url}${_history[index]["user_avatar"]}"),
                                  ),
                            title: Text(
                              _history[index]["firstName"],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            subtitle: Text(
                              _history[index]["action_type"] == "COMMENT"
                                  ? _history[index]["comment"]
                                  : _history[index]["action_type"] == "OPEN"
                                      ? "Changed Task Status From " +
                                          _history[index]["old_task_status"] +
                                          " To " +
                                          _history[index]["new_task_status"]
                                      : Container(),
                              // overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(timeago.format(DateTime.parse(
                                _history[index]["actionCreationDate"])))),
                        Divider(
                          color: Colors.black,
                          thickness: 1,
                          indent: 50,
                          endIndent: 50,
                        )
                      ],
                    );
                  },
                ),
              ),
            )
          : Center(
              child: Text("No History or this task"),
            ),
    );
  }

  _showHistory(int id) async {
    var respones = null;
    var jsonResponse = null;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      'token': sharedPreferences.getString("token"),
    };
    var url = Uri.parse('${MyApp.url}/workspace/task/$id');
    var response = await http.get(
      url,
      headers: requestHeaders,
    );

    jsonResponse = json.decode(response.body);
    if (jsonResponse['type'] == "ok") {
      setState(() {
        _history = jsonResponse["data"]["taskActions"];
      });
    } else {
      setState(() {
        _history = [];
      });
    }
  }
}
