import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class NewLoginForTesting extends StatefulWidget {
  @override
  _NewLoginForTestingState createState() => _NewLoginForTestingState();
}

class _NewLoginForTestingState extends State<NewLoginForTesting> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: _email),
              SizedBox(height: 20),
              TextField(
                controller: _password,
                onSubmitted: (_) => _logIn(),
              ),
              SizedBox(height: 20),
              // ignore: deprecated_member_use
              RaisedButton(
                onPressed: () => _logIn(),
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> requestHeaders = {
    "Content-type": "application/json; charset=UTF-8",
  };
  _logIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // ignore: unused_local_variable
    var response, jsonResponse;
    var url = Uri.parse("${MyApp.url}/user/login");
    response = await http.post(url,
        headers: requestHeaders,
        body: jsonEncode(
          <String, String>{
            "email": _email.text,
            "password": _password.text,
          },
        ));
    jsonResponse = await json.decode(response.body);
    var result = await pref.setString("token", jsonResponse["data"]["token"]);
    await pref.setStringList('firstSecond', [
      jsonResponse['data']['firstName'],
      jsonResponse['data']['secondName'],
    ]);

    await pref.setString(
        "userAvatar", jsonResponse['data']['user_avatar'].toString());

  }
}
