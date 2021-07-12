import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../navBar.dart';
import '../homePage/workSpaceMembers.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import '../all_tasks/showAllTasks.dart';
import '../canlendar/createNewWorkSpace.dart';
import '../main.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  String firstName;

  HomePage(this.firstName);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var listOfWorkspace = [];
  var notWorkspacefound = false;
  var role = [];
  var i = 0;
  TextEditingController _search = TextEditingController();
  TextEditingController _searchForMember = TextEditingController();
  bool keyboard = false;
  FocusNode inputNode = FocusNode();
  final _formkey = GlobalKey<FormState>();
  int usersInworkspace;
  int workspaceIndex = 0;

  int isJoined;

  var userAvatar = null;

  File image;
  String imageEvictUrl = "";

  @override
  void initState() {
    _searchForMember.clear();
    checkWorkSpaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    DateTime formattedDate = now;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Form(
        key: _formkey,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(243, 246, 255, 1),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 0, right: 25, bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 5),
                          //logo and search icon
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              userAvatar.toString().contains("null")
                                  ? Container(
                                      width: width > 400 ? 60 : 40,
                                      height: width > 400 ? 60 : 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all()),
                                      child: Center(
                                        child: Text(
                                          widget.firstName
                                              .toString()
                                              .split('')[0]
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 26,
                                            color: Colors.black,
                                            fontFamily: "CCB",
                                          ),
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        "${MyApp.url}$userAvatar",
                                        fit: BoxFit.cover,
                                        width: width > 400 ? 60 : 40,
                                        height: width > 400 ? 60 : 40,
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

                              Image(
                                  image: AssetImage("asset/logo2.png"),
                                  width: 55,
                                  height: 55),
                              // InkWell(
                              //   //   // onTap: () => showKeyboard(),
                              //   child: Icon(
                              //     Icons.search_rounded,
                              //     size: 30,
                              //     color: Color.fromRGBO( , 1),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 10, bottom: 10),
                          //account text
                          child: Text(
                            "Hello, ${widget.firstName}!",
                            style: TextStyle(
                              fontSize: width > 400 ? 30 : 25,
                              fontFamily: "Rubik",
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                          //wellcomeing message
                          child: Text(
                            "Are you ready to do\nsomething amazing?",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Rubik",
                                color: Color.fromRGBO(158, 158, 158, 1)),
                          ),
                        ),
                        //search
                        // Container(
                        //   height: 75,
                        //   margin: EdgeInsets.symmetric(vertical: 10),
                        //   padding: EdgeInsets.symmetric(horizontal: 10),
                        //   decoration: BoxDecoration(
                        //       color: Color.fromRGBO(243, 246, 255, 1),
                        //       borderRadius: BorderRadius.circular(10)),
                        //   child: Center(
                        //     child: TextFormField(
                        //       autofocus: keyboard,
                        //       controller: _search,
                        //       focusNode: inputNode,
                        //       onFieldSubmitted: (_) {
                        //         if (_formkey.currentState.validate())
                        //           return ScaffoldMessenger.of(context)
                        //               .showSnackBar(SnackBar(
                        //                   duration: Duration(seconds: 2),
                        //                   content: Text('search seccessful')));
                        //         else
                        //           return ScaffoldMessenger.of(context)
                        //               .showSnackBar(SnackBar(
                        //                   duration: Duration(seconds: 2),
                        //                   content: Text('search fail')));
                        //       },
                        //       validator: (value) {
                        //         if (value == null || value.isEmpty) {
                        //           return 'search box is Empty';
                        //         }
                        //         return null;
                        //       },
                        //       style: TextStyle(
                        //         fontSize: 25,
                        //         color: Color.fromRGBO(0, 82, 205, 1),
                        //       ),
                        //       decoration: InputDecoration(
                        //         border: InputBorder.none,
                        //         hintText: "Search workspaces...",
                        //         // hintStyle: TextStyle(
                        //         //   fontSize: 25,
                        //         // ),
                        //         icon: Icon(Icons.search, size: 30),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   width: 100,
                        //   height: 100,
                        //   child: image(),
                        // ),
                      ])),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 0, bottom: 0),
                        //workspace and new worksapace
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Workspace",
                                  style: TextStyle(
                                      fontSize: width < 400 ? 20 : 25,
                                      fontFamily: "Rubik",
                                      color: Colors.black),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  width: width < 400 ? 33 : 40,
                                  height: width < 400 ? 33 : 40,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(217, 230, 255, 1),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Center(
                                      child: Text(
                                    listOfWorkspace.length != null
                                        ? listOfWorkspace.length.toString()
                                        : '0',
                                    style: TextStyle(
                                        fontSize: width < 400 ? 18 : 22,
                                        fontFamily: "Rubik",
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(0, 82, 205, 1)),
                                  )),
                                ),
                              ],
                            ),
                            // ignore: deprecated_member_use
                            RaisedButton.icon(
                              elevation: 9,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateNewWorkSpace(
                                                "Create New WorkSpace",
                                                null,
                                                null,
                                                null,
                                                userAvatar)));
                              },
                              icon: Icon(Icons.add,
                                  size: 30, color: Colors.white),
                              label: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "New",
                                  style: TextStyle(
                                      fontSize: width < 400 ? 20 : 25,
                                      color: Colors.white),
                                ),
                              ),
                              color: Color.fromRGBO(0, 82, 205, 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                          ],
                        ),
                      ),
                      //list view of all workspaces
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 10),
                          child: notWorkspacefound == false
                              ? Center(child: CircularProgressIndicator())
                              : listOfWorkspace.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No Workspace Add yet!!",
                                        style: TextStyle(
                                            fontFamily: "RubikL",
                                            fontSize: width < 400 ? 23 : 28),
                                      ),
                                    )
                                  : foundworkspace(
                                      formattedDate.toString(), context),
                        ),
                      ),
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

  void evictImage(String url) {
    if (!url.contains("null")) {
      final NetworkImage provider = NetworkImage(url);
      provider.evict().then<void>((bool success) {
        if (success) debugPrint('removed image!');
      });
    }
  }

  //list view of all workspaces
  ListView foundworkspace(String formattedDate, BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        workspaceIndex = index;
        return Container(
          margin: EdgeInsets.only(top: 10, bottom: 20),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => listOfWorkspace[index]["role"] == "employer"
                        ? _showPicker(
                            context, listOfWorkspace[index]["workspaceId"])
                        : null,
                    child: !listOfWorkspace[index]["workspaceAvatar"]
                            .toString()
                            .contains("null")
                        ?
                        // Container()
                        ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              "${MyApp.url}${listOfWorkspace[index]['workspaceAvatar']}",
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                );
                              },
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(112, 112, 112, 0.1),
                                borderRadius: BorderRadius.circular(50)),
                            child: Center(
                                child: Text(
                              listOfWorkspace[index]["workspaceName"]
                                  .toString()
                                  .split('')[0],
                              style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: "Rubik",
                                  fontWeight: FontWeight.w600),
                            )),
                          ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            Icons.star_border_rounded,
                            size: width > 400 ? 50 : 25,
                            color: Color.fromRGBO(132, 132, 132, 1),
                          ),
                        ),
                        SizedBox(width: 10),
                        PopupMenuButton(
                          icon: Icon(
                            Icons.more_horiz,
                            size: width > 400 ? 40 : 25,
                            color: Color.fromRGBO(132, 132, 132, 1),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(
                                    listOfWorkspace[index]["role"] == "employer"
                                        ? Icons.delete
                                        : Icons.logout,
                                    size: width > 400 ? 30 : 20,
                                    color: Color.fromRGBO(158, 158, 158, 1),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    listOfWorkspace[index]["role"] == "employer"
                                        ? "Delete"
                                        : "Leave",
                                    style: TextStyle(
                                      fontSize: width > 400 ? 20 : 16,
                                      fontFamily: "RubicB",
                                    ),
                                  )
                                ],
                              ),
                            ),
                            listOfWorkspace[index]["role"] == "employer"
                                ? PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: width > 400 ? 30 : 20,
                                          color:
                                              Color.fromRGBO(158, 158, 158, 1),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Edit",
                                          style: TextStyle(
                                            fontSize: width > 400 ? 20 : 16,
                                            fontFamily: "RubicB",
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : null,
                            PopupMenuItem(
                              value: 3,
                              child: Row(children: [
                                Icon(
                                  Icons.add_circle_rounded,
                                  size: width > 400 ? 30 : 20,
                                  color: Color.fromRGBO(158, 158, 158, 1),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Add Memeber",
                                  style: TextStyle(
                                    fontSize: width > 400 ? 20 : 16,
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
                                  listOfWorkspace[index]["role"] == "employer"
                                      ? delete(
                                          listOfWorkspace[index]["workspaceId"])
                                      : leave(listOfWorkspace[index]
                                          ["workspaceId"]);
                                }
                                break;
                              case 2:
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateNewWorkSpace(
                                                "Edit WorkSpace",
                                                listOfWorkspace[index]
                                                    ["workspaceId"],
                                                listOfWorkspace[index]
                                                    ["workspaceName"],
                                                listOfWorkspace[index]
                                                    ["workspaceDescription"],
                                                userAvatar)));
                                break;
                              case 3:
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkSpaceMember(
                                              listOfWorkspace[index]
                                                  ["workspaceId"],
                                              userAvatar,
                                              checkWorkSpaces,
                                              "Add Member to Workspace",
                                              null,
                                            )));
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //for the task to gose to the list for all tasks
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowAllTasks(
                              listOfWorkspace[index]["workspaceName"],
                              listOfWorkspace[index]["workspaceId"],
                              listOfWorkspace[index]["role"],
                              userAvatar)));
                },
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //workspace title
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              "${listOfWorkspace[index]["workspaceName"]}",
                              style: TextStyle(
                                fontSize: width > 400 ? 30 : 22,
                                fontFamily: "RubikB",
                              ),
                            ),
                          ),
                          //workspace descripition
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 30),
                            child: Text(
                              "${listOfWorkspace[index]["workspaceDescription"]}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width > 400 ? 24 : 22,
                                  fontFamily: "Rubik",
                                  color: Color.fromRGBO(112, 112, 112, 1)),
                            ),
                          ),
                          //done task row
                          Row(children: [
                            Icon(
                              Typicons.input_checked,
                              size: 25,
                              color: Color.fromRGBO(112, 112, 112, 1),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "done tasks",
                              style: TextStyle(
                                  color: Color.fromRGBO(112, 112, 112, 1),
                                  fontSize: 20),
                            ),
                          ]),
                          SizedBox(height: 10),
                          //building ui row
                          Row(
                            children: [
                              Icon(
                                Typicons.puzzle_outline,
                                size: 25,
                                color: Color.fromRGBO(112, 112, 112, 1),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Building UI",
                                style: TextStyle(
                                    color: Color.fromRGBO(112, 112, 112, 1),
                                    fontSize: 20),
                              ),
                              // Text(
                              //   "dsdasda",
                              //   style: TextStyle(
                              //       color: Color.fromRGBO(132, 132, 132, 1),
                              //       fontSize: 22),
                              // ),
                            ],
                          ),
                          //date row
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 20, top: 20, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    child: Row(children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 25,
                                    color: Color.fromRGBO(112, 112, 112, 1),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    listOfWorkspace[index]["creation_date"]
                                        .toString()
                                        .split('T')[0],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color:
                                            Color.fromRGBO(112, 112, 112, 1)),
                                  )
                                ])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WorkSpaceMember(
                                        listOfWorkspace[index]["workspaceId"],
                                        userAvatar,
                                        checkWorkSpaces,
                                        "Add Member to Workspace",
                                        null,
                                      ))),
                          child: Container(
                            // color: Colors.lightBlue,
                            width: width * 0.28,
                            height: width > 400
                                ? MediaQuery.of(context).size.height * 0.07
                                : MediaQuery.of(context).size.height * 0.06,
                            child: listOfWorkspace[index]['users'].length !=
                                    null
                                ? ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext bc, int index) {
                                      print(listOfWorkspace[workspaceIndex]
                                              ["users"]
                                          .length);
                                      return listOfWorkspace[workspaceIndex]
                                                      ["users"][index]
                                                  ["user_avatar"] ==
                                              null
                                          ? Container(
                                              width: 50,
                                              height: 50,
                                              margin: EdgeInsets.only(right: 5),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(),
                                              ),
                                              child: Center(
                                                  child: Text(listOfWorkspace[0]
                                                              ["users"][index]
                                                          ["firstName"]
                                                      .toString()
                                                      .split('')[0]
                                                      .toUpperCase()
                                                      .toUpperCase())))
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: ClipOval(
                                                child: Image.network(
                                                  "${MyApp.url}${listOfWorkspace[workspaceIndex]["users"][index]["user_avatar"]}",
                                                  fit: BoxFit.cover,
                                                  // width: width > 400 ? 55 : 48,
                                                  // height: width > 400 ? 55 : 48,
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
                                            );
                                    },
                                    itemCount: listOfWorkspace[workspaceIndex]
                                            ["users"]
                                        .length,
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: listOfWorkspace.length ?? 1,
    );
  }

  //popup invaite member
  // void _showDialog(int workSpaceID, BuildContext context) {
  //   var width = MediaQuery.of(context).size.width;
  //   var height = MediaQuery.of(context).size.height;
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // return object of type Dialog
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(25))),
  //         elevation: 5,
  //         title: new Text(
  //           "Search for Member",
  //           style: TextStyle(fontSize: width < 400 ? 16 : 20),
  //         ),
  //         content: Container(
  //           height: height * 0.5,
  //           width: width,
  //           child: Column(
  //             children: [
  //               Container(
  //                 height: width < 400 ? 55 : 75,
  //                 margin: EdgeInsets.all(15),
  //                 padding: EdgeInsets.symmetric(horizontal: 10),
  //                 decoration: BoxDecoration(
  //                     color: Color.fromRGBO(243, 246, 255, 1),
  //                     borderRadius: BorderRadius.circular(10)),
  //                 child: Center(
  //                   child: TextFormField(
  //                     autofocus: keyboard,
  //                     focusNode: inputNode,
  //                     controller: _searchForMember,
  //                     onFieldSubmitted: (_) {
  //                       _searchForMemberInTask(
  //                           workSpaceID, _searchForMember.text);
  //                     },
  //                     // ignore: missing_return
  //                     validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return 'search box is Empty';
  //                       }
  //                       return null;
  //                     },
  //                     style: TextStyle(
  //                       fontSize: width < 400 ? 16 : 20,
  //                       color: Color.fromRGBO(0, 82, 205, 1),
  //                     ),
  //                     decoration: InputDecoration(
  //                       border: InputBorder.none,
  //                       hintText: "Search for Member",
  //                       // hintStyle: TextStyle(
  //                       //   fontSize: 25,
  //                       // ),
  //                       icon: Icon(Icons.search, size: 30),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   width: width,
  //                   child: ListView.builder(
  //                     itemBuilder: (context, index) {
  //                       return Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             vertical: 20, horizontal: 20),
  //                         child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Row(
  //                                 children: [
  //                                   listOfWorkspaceMembers[index]
  //                                               ["user_avatar"] ==
  //                                           null
  //                                       ? Container(
  //                                           width: width < 400 ? 50 : 60,
  //                                           height: width < 400 ? 50 : 60,
  //                                           decoration: BoxDecoration(
  //                                             shape: BoxShape.circle,
  //                                             border: Border.all(),
  //                                           ),
  //                                           child: Center(
  //                                               child: Text(
  //                                                   listOfWorkspaceMembers[
  //                                                           index]["firstName"]
  //                                                       .toString()
  //                                                       .split('')[0]
  //                                                       .toUpperCase()
  //                                                       .toUpperCase())))
  //                                       : ClipRRect(
  //                                           borderRadius:
  //                                               BorderRadius.circular(100),
  //                                           child: Image.network(
  //                                             "${MyApp.url}${listOfWorkspaceMembers[index]["user_avatar"]}",
  //                                             fit: BoxFit.cover,
  //                                             width: width < 400 ? 40 : 60,
  //                                             height: width < 400 ? 40 : 60,
  //                                             loadingBuilder:
  //                                                 (BuildContext context,
  //                                                     Widget child,
  //                                                     ImageChunkEvent
  //                                                         loadingProgress) {
  //                                               if (loadingProgress == null)
  //                                                 return child;
  //                                               return Center(
  //                                                 child:
  //                                                     CircularProgressIndicator(
  //                                                   value: loadingProgress
  //                                                               .expectedTotalBytes !=
  //                                                           null
  //                                                       ? loadingProgress
  //                                                               .cumulativeBytesLoaded /
  //                                                           loadingProgress
  //                                                               .expectedTotalBytes
  //                                                       : null,
  //                                                 ),
  //                                               );
  //                                             },
  //                                           ),
  //                                         ),
  //                                   SizedBox(width: 10),
  //                                   Row(
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     children: [
  //                                       Text(
  //                                         listOfWorkspaceMembers[index]
  //                                             ['firstName'],
  //                                         style: TextStyle(
  //                                           fontSize: width < 400 ? 18 : 22,
  //                                           color: Colors.black,
  //                                         ),
  //                                       ),
  //                                       SizedBox(width: 10),
  //                                       Text(
  //                                         listOfWorkspaceMembers[index]
  //                                             ['secondName'],
  //                                         style: TextStyle(
  //                                           fontSize: width < 400 ? 18 : 22,
  //                                           color: Colors.black,
  //                                         ),
  //                                       )
  //                                     ],
  //                                   ),
  //                                 ],
  //                               ),
  //                               Row(
  //                                 children: [
  //                                   listOfWorkspaceMembers[index]["isJoined"] !=
  //                                           0
  //                                       ? IconButton(
  //                                           onPressed: () {},
  //                                           icon: Icon(
  //                                               Icons.person_remove_rounded,
  //                                               size: width < 400 ? 25 : 30,
  //                                               color: Colors.red),
  //                                         )
  //                                       : IconButton(
  //                                           icon: Icon(Icons.person_add_rounded,
  //                                               size: width < 400 ? 25 : 30,
  //                                               color: Colors.green),
  //                                           onPressed: () {
  //                                             _inviteEmployee(
  //                                                 workSpaceID,
  //                                                 listOfWorkspaceMembers[index]
  //                                                     ["userId"],
  //                                                 context);
  //                                           })
  //                                 ],
  //                               )
  //                             ]),
  //                       );
  //                     },
  //                     itemCount: listOfWorkspaceMembers.length,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           // usually buttons at the bottom of the dialog
  //           new FlatButton(
  //             child: new Text("Close"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // invite member
  var listOfWorkspaceMembers = [];

  // _getMember(int workSpaceId, BuildContext context) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   Map<String, String> requestHeaders = {
  //     "Content-type": "application/json; charset=UTF-8",
  //     "token": sharedPreferences.getString("token"),
  //   };
  //   // print(sharedPreferences.getString("token") + '\n\n');
  //   var jsonResponse = null;
  //   var url = Uri.parse("${MyApp.url}/workspace/members/$workSpaceId");
  //   var response = await http.get(
  //     url,
  //     headers: requestHeaders,
  //   );
  //   jsonResponse = json.decode(response.body);
  //   setState(() {
  //     listOfWorkspaceMembers = jsonResponse["data"];
  //   });
  //   _showDialog(workSpaceId, context);
  // }

  //search for member using API
  // _searchForMemberInTask(int workSpaceID, String Searchcontent) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   Map<String, String> requestHeaders = {
  //     "Content-type": "application/json; charset=UTF-8",
  //     "token": sharedPreferences.getString("token"),
  //   };
  //   var jsonResponse = null;
  //   var url = Uri.parse(
  //       "${MyApp.url}/workspace/members/seek/$workSpaceID/$Searchcontent");
  //   var response = await http.get(
  //     url,
  //     headers: requestHeaders,
  //   );
  //   jsonResponse = json.decode(response.body);
  //   if (jsonResponse["data"] != null)
  //     setState(() {
  //       listOfWorkspaceMembers = jsonResponse["data"];
  //     });
  // }

  // showKeyboard(BuildContext context) {
  //   setState(() {
  //     keyboard = !keyboard;
  //   });
  //   if (keyboard)
  //     FocusScope.of(context).requestFocus(inputNode);
  //   else {
  //     FocusScope.of(context).unfocus();
  //     _search.clear();
  //   }
  // }

  // returnUsersCount(List list) {
  //   return list.length;
  // }

  checkWorkSpaces() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userAvatar = sharedPreferences.getString("userAvatar");
    });

    Map<String, String> requestHeaders = {
      "Content-type": "application/json; charset=UTF-8",
      "token": sharedPreferences.getString("token")
    };
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspaces");

    var response = await http.get(
      url,
      headers: requestHeaders,
    );
    jsonResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      if (!jsonResponse["successful"]) {
        print("No work space found");
        setState(() {
          notWorkspacefound = false;
        });
      } else {
        setState(() {
          notWorkspacefound = true;
          // ignore: unnecessary_statements
          if (jsonResponse['data'] != null) {
            listOfWorkspace = jsonResponse['data'];
          } else
            listOfWorkspace = [];
        });
      }
    } else if (response.statusCode == 400) {
      print(jsonResponse["error"]);
    } else {
      print("undefine Case!!");
    }
  }

  List images;

  Container container(Color color, String text) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(child: Text(text)),
    );
  }

  delete(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // ignore: avoid_init_to_null
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/delete/$id");
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
        checkWorkSpaces();
      });
    } else if (response.statusCode == 400) {
      print(jsonResponse["error"]);
    }
  }

  leave(int id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // ignore: avoid_init_to_null
    var jsonResponse = null;
    var url = Uri.parse("${MyApp.url}/workspace/leave/$id");
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
        checkWorkSpaces();
      });
    } else if (response.statusCode == 400) {
      print(jsonResponse["error"]);
    }
  }

  //invite employee
  _inviteEmployee(int workspaceId, int employeeID, BuildContext context) async {
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
        <String, dynamic>{"workspaceId": workspaceId, "employeeId": employeeID},
      ),
    );
    Navigator.pop(context);
    setState(() {
      checkWorkSpaces();
    });
  }

  //select betwen camera and storage
  _showPicker(context, int workspaceID) {
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
                        _imgFromGallery(context, workspaceID);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera(context, workspaceID);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera(BuildContext context, int workspaceID) async {
    // ignore: deprecated_member_use
    var _image = (await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50));
    _showAlertDilog(context, _image, workspaceID);
  }

  _imgFromGallery(BuildContext context, int workspaceID) async {
    // ignore: deprecated_member_use
    var _image = (await ImagePicker.pickImage(
      source: ImageSource.gallery,
    ));
    _showAlertDilog(context, _image, workspaceID);
  }

  _showAlertDilog(BuildContext context, File _image, int workspaceID) {
    return showDialog(
        context: context,
        builder: (contect) {
          return AlertDialog(
            title: Text("Changing workspace Image"),
            content: Text(
              "Are Sure You want to Change workspace image?",
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              RaisedButton(
                onPressed: () {
                  evictImage(imageEvictUrl);
                  setState(() {
                    image = _image;
                  });
                  _addWorkSpace(workspaceID, context);
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

  _addWorkSpace(int worksoaceID, BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var jsonResponse;
    if (image != null) {
      var imageBytes = image.readAsBytesSync();
      var request = http.MultipartRequest(
          "POST", Uri.parse("${MyApp.url}/workspace/avatar/$worksoaceID"));
      request.files.add(
        http.MultipartFile.fromBytes(
          "workspaceAvatar",
          imageBytes,
          filename: basename(image.path),
          contentType: new MediaType('image', 'jpg'),
        ),
      );
      request.headers.addAll({"token": sharedPreferences.getString("token")});
      final response = await request.send();
      final resSTR = await response.stream.bytesToString();
      jsonResponse = json.decode(resSTR);
    }
    if (jsonResponse["successful"]) {
      var list = sharedPreferences.getStringList("firstSecond");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NavBar(list[0])));
    }

    if (!jsonResponse["successful"]) {
      print(jsonResponse["successful"]);
    }
  }
}
