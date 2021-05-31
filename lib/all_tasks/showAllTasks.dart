import 'dart:async';
import 'dart:convert';
import 'package:app2/all_tasks/taskDetials.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    checkIfThereAnyTaskes();
    super.initState();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  bool istaskFound = false;

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
                                                checkIfThereAnyTaskes)));
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
                                      "Stack",
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
                              listOfTasksWaiting,
                            ),
                            tabViewForTabBarAndTabView(
                              listOfTasksInProcess,
                            ),
                            tabViewForTabBarAndTabView(
                              listOfTasksStack,
                            ),
                            tabViewForTabBarAndTabView(
                              listOfTasksDone,
                            ),
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

  // Widget tabbarAndView() {
  //   return Expanded(
  //     child: Column(
  //       children: [
  //         TabBar(
  //           unselectedLabelColor: Colors.grey,
  //           labelColor: Colors.blue,
  //           indicator: CircleTabIndicator(color: Colors.blue, radius: 4),
  //           isScrollable: true,
  //           tabs: [
  //             Tab(
  //               child: Text(
  //                 "Waiting",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontFamily: "Rubik",
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //             Tab(
  //               child: Text(
  //                 "InProcess",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontFamily: "Rubik",
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //             Tab(
  //               child: Text(
  //                 "Stack",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontFamily: "Rubik",
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //             Tab(
  //               child: Text(
  //                 "Done",
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontFamily: "Rubik",
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ],
  //           controller: _tabController,
  //           indicatorSize: TabBarIndicatorSize.tab,
  //         ),
  //         Expanded(
  //           child: TabBarView(
  //             children: [
  //               tabViewForTabBarAndTabView(
  //                 listOfTasksWaiting,
  //               ),
  //               tabViewForTabBarAndTabView(
  //                 listOfTasksInProcess,
  //               ),
  //               tabViewForTabBarAndTabView(
  //                 listOfTasksStack,
  //               ),
  //               tabViewForTabBarAndTabView(
  //                 listOfTasksDone,
  //               ),
  //             ],
  //             controller: _tabController,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget tabViewForTabBarAndTabView(List listOfTasks) {
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
              padding:
                  EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
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
                          height: 21,
                          decoration: BoxDecoration(
                              color:
                                  newListReversed[index]["prority"] == "URGENT"
                                      ? Color.fromRGBO(248, 135, 135, 1)
                                      : Color.fromRGBO(46, 204, 113, 1),
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        PopupMenuButton(
                          icon: Icon(Icons.more_horiz,
                              color: Colors.grey, size: 40),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 30,
                                    color: Color.fromRGBO(158, 158, 158, 1),
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
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 30,
                                    color: Color.fromRGBO(158, 158, 158, 1),
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
                            ),
                            PopupMenuItem(
                              value: 3,
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
                          ],
                          onSelected: (item) {
                            switch (item) {
                              case 1:
                                {
                                  print("Delete task");
                                }
                                break;
                              case 2:
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateNewTask(
                                            "Edit Task",
                                            widget.workspaceId,
                                            checkIfThereAnyTaskes)));
                                break;
                              case 3:
                                print("add member to task");
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
                            content: newListReversed[index]["content"],
                            member:
                                newListReversed[index]["taskMembers"].length,
                            status: newListReversed[index]["prority"],
                            creationDate: newListReversed[index]
                                ["taskCreationDate"],
                            members: newListReversed[index]["taskMembers"],
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
                                    fontSize:
                                        MediaQuery.of(context).size.width > 400
                                            ? 22
                                            : 18,
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
                            // if (await Permission.storage.request().isGranted)
                            _showPicker(context);
                            // displayBottomSheet(context);
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
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
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