import 'package:flutter/material.dart';

import '../main.dart';

class TaskDetails extends StatelessWidget {
  String title;
  String content;
  String creationDate;
  int member;
  String status;
  List members;
  TaskDetails(
      {@required this.title,
      @required this.content,
      @required this.creationDate,
      this.member,
      @required this.status,
      this.members});
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    print(members);
    var padding = EdgeInsets.symmetric(vertical: 10, horizontal: 20);
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 246, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(243, 246, 255, 1),
        centerTitle: true,
        title: Text(
          "Task Details",
          style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontFamily: "RubikL",
              fontWeight: FontWeight.w800),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task Title",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 25),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task Content",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 25),
                ),
                SizedBox(height: 10),
                Text(
                  content,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task Status",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 25),
                ),
                SizedBox(height: 10),
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                      color: status == "URGENT"
                          ? Color.fromRGBO(248, 135, 135, 1)
                          : Color.fromRGBO(46, 204, 113, 1),
                      borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Creation Date",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 25),
                ),
                SizedBox(height: 10),
                Text(
                  creationDate.split(" ")[0] +
                      ' ' +
                      creationDate.split(" ")[1].split(".")[0],
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task Creater",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 25),
                ),
                SizedBox(height: 10),
                Text(
                  "owner",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Task Members",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 25),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(), shape: BoxShape.circle),
                      padding: EdgeInsets.all(8),
                      child: Text(member.toString()),
                    )
                  ],
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: double.infinity,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(30)),
                    height: w * 0.5,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: member,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: ClipOval(
                            child: Image.network(
                              "${MyApp.url}${members[index]["user_avatar"]}",
                              fit: BoxFit.cover,
                              width: w > 400 ? 55 : 40,
                              height: w > 400 ? 55 : 40,
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
                            ),
                          ),
                          title: Text(members[index]["firstName"] +
                              " " +
                              members[index]["secondName"]),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
