import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/forgotPassword.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'logn.dart';

class Register extends StatefulWidget {
  static String fName;

  @override
  State<StatefulWidget> createState() {
    return new _Register();
  }
}

class _Register extends State<Register> {
  final TextEditingController _firstName = new TextEditingController();
  final TextEditingController _secondName = new TextEditingController();
  final TextEditingController _eMail = new TextEditingController();
  final TextEditingController _passWord = new TextEditingController();
  final TextEditingController _confPassword = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var padding = EdgeInsets.only(top: 5, bottom: 5);
    return Form(
      key: _formKey,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(243, 246, 255, 1),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(25, 15, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: w > 400 ? 30 : 10),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Image(
                        width: w > 400 ? 100 : 70,
                        height: w > 400 ? 100 : 70,
                        image: AssetImage("asset/logo2.png"),
                      ),
                    )),
                  ),
                  SizedBox(height: 5),
                  Center(
                      child: Text(
                    "Workspacer",
                    style: TextStyle(
                        fontSize: w > 400 ? 35 : 25,
                        color: Color.fromRGBO(62, 128, 255, 1)),
                  )),
                  SizedBox(height: 10),
                  lebel(padding, "First Name"),
                  textField(_firstName, false),
                  SizedBox(height: 10),
                  lebel(padding, "Second Name"),
                  textField(_secondName, false),
                  SizedBox(height: 10),
                  lebel(padding, "Email"),
                  textField(_eMail, false),
                  SizedBox(height: 10),
                  lebel(padding, 'Password'),
                  textField(_passWord, true),
                  SizedBox(height: 10),
                  lebel(padding, 'Confirm Password'),
                  textField(_confPassword, true),

                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 12, 0, 5),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       InkWell(
                  //         onTap: () => Navigator.pop(context),
                  //         child: Text(
                  //           "Log In",
                  //           style: TextStyle(
                  //               fontFamily: "Rubik",
                  //               fontSize: 20,
                  //               color: Color.fromRGBO(112, 112, 112, 1)),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 82, 204, 1),
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    height: 60,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());

                        signUp(_firstName.text, _secondName.text, _eMail.text,
                            _passWord.text);
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "Rubik",
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(216, 229, 255, 1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 1, color: Color.fromRGBO(0, 104, 255, 1))),
                    width: double.infinity,
                    height: 60,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back to LogIn",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "Rubik",
                            color: Color.fromRGBO(62, 128, 255, 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding lebel(EdgeInsets padding, String text) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style:
            TextStyle(fontSize: 22, fontFamily: "Rubik", color: Colors.black),
      ),
    );
  }

  Widget textField(TextEditingController controller, bool obscure) {
    var w = MediaQuery.of(context).size.width;
    return TextField(
      style: TextStyle(
        fontSize: w < 400 ? 19 : 24,
        fontFamily: "Rubik",
        color: Colors.black,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: new BorderSide(color: Colors.black),
        ),
      ),
      controller: controller,
      obscureText: obscure,
    );
  }

  Map<String, String> requestHeaders = {
    "Content-type": "application/json; charset=UTF-8",
  };

  signUp(String firstName, String secondName, String email,
      String password) async {
    if (await Permission.storage.request().isGranted) {
      // ignore: avoid_init_to_null
      var jsonResponse = null;
      var response;
      var url = Uri.parse("${MyApp.url}/user/register");

      if (_passWord.text == _confPassword.text) {
        response = await http.post(
          url,
          headers: requestHeaders,
          body: jsonEncode(
            <String, String>{
              "firstName": firstName,
              "secondName": secondName,
              "email": email,
              "password": password
            },
          ),
        );
        jsonResponse = json.decode(response.body);
        if (!jsonResponse["successful"]) {
          showsnakbar(
            jsonResponse["message"],
          );
        }
        if (jsonResponse["successful"]) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Logn()));
        }
      } else {
        scaffoldMessengerKey.currentState.showSnackBar(SnackBar(
            duration: Duration(seconds: 5),
            content: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.yellow),
                SizedBox(width: 10),
                Text(
                  "Password does not match",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            )));
      }
    }
  }

  showsnakbar(String msg) {
    var snakbar;
    if (msg == null)
      snakbar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          msg.contains(',')
              ? "${msg.split(',')[0]}'\n'${msg.split(',')[1]}"
              : msg,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      );
    else
      snakbar = SnackBar(
          duration: Duration(seconds: 5),
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow),
              SizedBox(width: 10),
              Text(
                msg.contains(',')
                    ? "${msg.split(',')[0]}'\n'${msg.split(',')[1]}"
                    : msg,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ));
    scaffoldMessengerKey.currentState.showSnackBar(snakbar);
  }
}
