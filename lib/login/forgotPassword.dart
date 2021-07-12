import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../login/logn.dart';
import '../main.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController _eMail = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Form(
      key: _formkey,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(243, 246, 255, 1),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: w > 400 ? 140 : 80),
                          child: Center(
                            child: Image(
                                width: w > 400 ? 100 : 70,
                                height: w > 400 ? 100 : 70,
                                image: AssetImage("asset/logo2.png")),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                            child: Text(
                          "Workspacer",
                          style: TextStyle(
                              fontSize: 42,
                              color: Color.fromRGBO(62, 128, 255, 1)),
                        )),
                      ],
                    ),
                    SizedBox(height: w > 400 ? 40 : 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontSize: 22,
                                fontFamily: "Rubik",
                                color: Colors.black),
                          ),
                        ),
                        Container(
                          width: w - 20,
                          child: new TextFormField(
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: "Rubik",
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                hintText: "Enter your email address"),
                            controller: _eMail,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!EmailValidator.validate(value))
                                  return 'it is not email';
                              } else
                                return 'the text feild is empty';
                              return null;
                            },
                            onFieldSubmitted: (_) async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              forgotPassword(_eMail.text);
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     InkWell(
                        //       onTap: () => Navigator.pop(context),
                        //       child: Text(
                        //         "Log In",
                        //         style: TextStyle(
                        //             fontFamily: "Rubik",
                        //             fontSize: 20,
                        //             color: Color.fromRGBO(112, 112, 112, 1)),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 82, 204, 1),
                              borderRadius: BorderRadius.circular(10)),
                          width: double.infinity,
                          height: 60,
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              forgotPassword(_eMail.text);
                            },
                            child: Text(
                              "Reset Password",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: "RubikB",
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
                                  width: 1,
                                  color: Color.fromRGBO(0, 104, 255, 1))),
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
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> requestHeaders = {
    "Content-type": "application/json; charset=UTF-8",
  };
  forgotPassword(String email) async {
    var jsonResponse = null;
    var response;
    var url = Uri.parse("${MyApp.url}/user/password/forget");

    response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(
        <String, String>{"email": email},
      ),
    );
    jsonResponse = json.decode(response.body);
    showsnakbar(jsonResponse["message"]);
  }

  showsnakbar(String msg) {
    var snakbar;
    if (msg == null)
      snakbar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          msg,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                msg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ));
    scaffoldMessengerKey.currentState.showSnackBar(snakbar);
    Future.delayed(
      Duration(seconds: 5),
      () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => Logn())),
    );
  }
}
