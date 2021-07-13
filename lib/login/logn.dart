import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../navBar.dart';
import 'forgotPassword.dart';
import 'register.dart';

class Logn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Logn();
  }
}

class _Logn extends State<Logn> {
  final TextEditingController _eMail = new TextEditingController();
  final TextEditingController _passWord = new TextEditingController();
  var errorMSG = "";
  bool isCheck = false;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getCredential();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
            // resizeToAvoidBottomInset: true,
            backgroundColor: Color.fromRGBO(243, 246, 255, 1),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // logo
                  Padding(
                    padding: EdgeInsets.only(top: w > 400 ? 90 : 30),
                    child: Center(
                      child: Image(
                          width: w > 400 ? 100 : 70,
                          height: w > 400 ? 100 : 70,
                          image: AssetImage("asset/logo2.png")),
                    ),
                  ),
                  SizedBox(height: 20),
                  // application name
                  Center(
                      child: Text(
                    "Workspacer",
                    style: TextStyle(
                        fontSize: w > 400 ? 42 : 30,
                        color: Color.fromRGBO(62, 128, 255, 1)),
                  )),
                  // email lable
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
                  // enter email
                  Container(
                    width: MediaQuery.of(context).size.width - 20,
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
                      onFieldSubmitted: (_) {
                        _formKey.currentState.validate();
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // password lable
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Passord",
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: "Rubik",
                          color: Colors.black),
                    ),
                  ),
                  // enter password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        child: new TextFormField(
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Rubik",
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: new BorderSide(color: Colors.red),
                            ),
                            hintText: "Enter your password",
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  semanticLabel: _obscureText
                                      ? 'show password'
                                      : 'hide password',
                                  color: Color.fromRGBO(112, 112, 112, 1),
                                ),
                              ),
                            ),
                          ),
                          controller: _passWord,
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (_passWord.text.length < 8)
                                return 'password should be 8 characters at less';
                            } else
                              return 'password should not be empty!';
                            return null;
                          },
                          onFieldSubmitted: (_) async {
                            if (_formKey.currentState.validate()) {
                              // FocusScope.of(context).requestFocus(FocusNode());
                              signIn(_eMail.text, _passWord.text);
                            }
                            //  else {
                            //   Timer.periodic(const Duration(seconds: 5), (t) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //             duration: Duration(seconds: 5),
                            //             content: Text(
                            //                 'wait 5 sec and try later..')));

                            //     t.cancel(); //stops the timer
                            //   });
                            // }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // remember email and forgot password
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: GFCheckbox(
                                size: GFSize.SMALL,
                                inactiveBorderColor:
                                    Color.fromRGBO(0, 82, 204, 1),
                                activeBorderColor:
                                    Color.fromRGBO(0, 82, 204, 1),
                                inactiveBgColor: Colors.transparent,
                                activeBgColor: GFColors.WHITE,
                                type: GFCheckboxType.circle,
                                onChanged: _onChanged,
                                value: isCheck,
                                activeIcon: const Icon(
                                  Icons.check,
                                  size: 20,
                                  color: Color.fromRGBO(0, 82, 204, 1),
                                ),
                                inactiveIcon: null,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Remember Email",
                              style: TextStyle(
                                  fontFamily: "Rubik",
                                  fontSize: 18,
                                  color: Color.fromRGBO(112, 112, 112, 1)),
                            ),
                            // Container(
                            //   color: Colors.yellow,
                            //   width: MediaQuery.of(context).size.width * 0.5,
                            //   padding: EdgeInsets.all(0),
                            //   margin: EdgeInsets.all(0),
                            //   child: ListTile(
                            //     leading: ,
                            //     title: Text(

                            //       style: TextStyle(
                            //           fontFamily: "Rubik",
                            //           fontSize: 18,
                            //           color: Color.fromRGBO(112, 112, 112, 1)),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Login button
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 82, 204, 1),
                        borderRadius: BorderRadius.circular(10)),
                    width: double.infinity,
                    height: 60,
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      onPressed: () {
                        signIn(_eMail.text, _passWord.text);
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "RubikB",
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // register
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      child: Text(
                        "Create a free account",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "Rubik",
                            color: Color.fromRGBO(62, 128, 255, 1)),
                      ),
                    ),
                  ),
                  SizedBox(height: 17),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword())),
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                              fontFamily: "Rubik",
                              fontSize: 18,
                              color: Color.fromRGBO(112, 112, 112, 1),
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  _onChanged(bool value) async {
    SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    if (_eMail.text.isNotEmpty) {
      setState(() {
        isCheck = value;
        sharedPreferences.setBool("check", isCheck);
        sharedPreferences.setString("email", _eMail.text);
        getCredential();
      });
    }
  }

  getCredential() async {
    SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isCheck = sharedPreferences.getBool("check");
      if (isCheck != null) {
        if (isCheck) {
          _eMail.text = sharedPreferences.getString("email");
        } else {
          _eMail.clear();
        }
      } else {
        isCheck = false;
      }
    });
  }

  Map<String, String> requestHeaders = {
    "Content-type": "application/json; charset=UTF-8",
  };

  signIn(String email, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // ignore: avoid_init_to_null
    var jsonResponse = null;
    var response;
    var url = Uri.parse("${MyApp.url}/user/login");
    response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(
        <String, String>{
          "email": email,
          "password": password,
        },
      ),
    );

    jsonResponse = json.decode(response.body);

    if (jsonResponse["successful"] == true) {
      await sharedPreferences.setString("token", jsonResponse['data']['token']);

      await sharedPreferences.setStringList('firstSecond', [
        jsonResponse['data']['firstName'],
        jsonResponse['data']['secondName'],
      ]);

      await sharedPreferences.setString(
          "userAvatar", jsonResponse['data']['user_avatar'].toString());

      await sharedPreferences.setString("email", _eMail.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavBar(
            jsonResponse['data']["firstName"],
          ),
        ),
      );
    }

    if (!jsonResponse["successful"]) {
      showsnakbar(
        jsonResponse["type"],
        jsonResponse["message"],
      );
    }
  }

  showsnakbar(String type, String msg) {
    var snakbar;
    if (type == null)
      snakbar = SnackBar(
        duration: Duration(seconds: 5),
        content: Text(
          msg.contains(',')
              ? "${msg.split(',')[0]}'\n'${msg.split(',')[1]}"
              : msg,
          maxLines: 2,
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
                msg.contains(',')
                    ? "${msg.split(',')[0]}'\n'${msg.split(',')[1]}"
                    : msg,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ));
    scaffoldMessengerKey.currentState.showSnackBar(snakbar);
  }
}
