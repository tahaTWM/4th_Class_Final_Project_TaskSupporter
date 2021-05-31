import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import './login/selectIP.dart';
import './splashScreen.dart';
import './navBar.dart';
import 'login/logn.dart';

void main() {
  // SharedPreferences.setMockInitialValues({});
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // lan ip
  static String url = "192.168.1.2:100";

  //nogrok ip
  // static String url = "http://a8592df906d6.ngrok.io";

  //wifi ip
  // static String url = "http://192.168.1.106:100";
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var fName = "No one";
  bool tokenFound = false;

  @override
  void initState() {
    // checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // checkLoginStatus();
    return MaterialApp(
      // home: !tokenFound ? Logn() : NavBar(fName),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  // checkLoginStatus() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   var token = pref.getString("token");

  //   if (token == null) {
  //     // setState(() {
  //     //   tokenFound = false;
  //     // });
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => Logn()));
  //   }
  //   if (token != null) {
  //     List list;
  //     list = pref.getStringList("firstSecond") ?? null;
  //     fName = list[0].toString();
  //     // setState(() {
  //     //   tokenFound = true;
  //     //   fName = list[0].toString();
  //     // });
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => NavBar(fName)));
  //   }
  // }
}
