import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../navBar.dart';

import 'logn.dart';

class SelectIP extends StatefulWidget {
  @override
  _SelectIPState createState() => _SelectIPState();
}

class _SelectIPState extends State<SelectIP> {
  // Default Radio Button Selected Item When App Starts.
  String radioButtonItem = '';

  // Group Value for Radio Button.
  int id = 1;
  TextEditingController _localController = TextEditingController();
  TextEditingController _ngrokController = TextEditingController();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    _localController.text = "http://192.168.";
    checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(243, 246, 255, 1),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: w > 400 ? 90 : 30),
                  child: Center(
                    child: Image(
                        width: w > 400 ? 150 : 100,
                        height: w > 400 ? 150 : 100,
                        image: AssetImage("asset/logo2.png")),
                  ),
                ),
                SizedBox(
                  height: w > 400 ? 100 : 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: id,
                      onChanged: (val) {
                        setState(() {
                          radioButtonItem = 'loacl';
                          id = 1;
                        });
                      },
                    ),
                    Text(
                      'Local Ip Address',
                      style: new TextStyle(fontSize: 17.0),
                    ),
                  ],
                ),
                id == 1
                    ? entering("Local Ip", "Enter Ip after http://19.168.",
                        _localController)
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: 2,
                      groupValue: id,
                      onChanged: (val) {
                        setState(() {
                          radioButtonItem = 'ngrok';
                          id = 2;
                        });
                      },
                    ),
                    Text(
                      'Ngrok Ip Address',
                      style: new TextStyle(fontSize: 17.0),
                    ),
                  ],
                ),
                id == 2
                    ? entering(
                        "Ngrok Ip", "Enter Ip after http://", _ngrokController)
                    : Container(),
                SizedBox(
                  height: w > 400 ? 80 : 40,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.52,
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                        padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        onPressed: () => onSubmit(),
                        textColor: Colors.white,
                        color: Color.fromRGBO(15, 86, 195, 1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              // color: Colors.pink,
                              child: Text(
                                'Submit to Enter App',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding entering(
          String title, String hint, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.all(6.0),
        child: TextFormField(
          maxLength: 30,
          autofocus: false,
          textAlign: TextAlign.start,
          // ignore: deprecated_member_use
          autovalidate: true,
          style: Theme.of(context).textTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black,
              ),
          controller: controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: title,
            contentPadding: EdgeInsets.all(1),
            prefixIcon: Icon(
              Icons.keyboard,
              color: Colors.black45,
            ),
            suffixIcon: Icon(
              Icons.network_wifi,
              color: Colors.black45,
            ),
            errorStyle: Theme.of(context).textTheme.caption.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: BorderSide(
                color: Color(0xFF26b78b),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: BorderSide(
                color: Color(0xFF26b78b),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: BorderSide(
                color: Color(0xFF26b78b),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: BorderSide(
                color: Color(0xFF26b78b),
              ),
            ),
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Colors.grey,
                ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28.0),
              borderSide: BorderSide(
                color: Color(0xFF26b78b),
              ),
            ),
            focusColor: Colors.green,
          ),
          onChanged: (str) {
            // To do
          },
          onSaved: (str) {
            // To do
          },
          onFieldSubmitted: (value) => onSubmit(),
        ),
      );

  var fName = "No one";
  bool tokenFound = false;

  checkLoginStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var token = pref.getString("token");

    if (token == null) {
      setState(() {
        tokenFound = false;
      });
      // Navigator.push(context, MaterialPageRoute(builder: (context) => Logn()));
    }
    if (token != null) {
      List list;
      list = pref.getStringList("firstSecond") ?? null;
      fName = list[0].toString();
      setState(() {
        tokenFound = true;
        fName = list[0].toString();
      });
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => NavBar(fName)));
    }
  }

  onSubmit() {
    if (_ngrokController.text.isEmpty &&
        _localController.text == "http://192.168.") {
      scaffoldMessengerKey.currentState.showSnackBar(
        SnackBar(
          action: SnackBarAction(
            label: 'yes',
            onPressed: () {
              setState(() {
                MyApp.url = "http://192.168.1.2:100";
              });
              if (tokenFound)
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NavBar(fName)));
              if (!tokenFound)
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Logn()));
            },
          ),
          duration: Duration(seconds: 8),
          content: Text(
            "your Default ip address is:\n192.168.1.2:100 ?",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      if (_ngrokController.text.isNotEmpty) {
        setState(() {
          MyApp.url = _ngrokController.text;
        });
        if (tokenFound)
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NavBar(fName)));
        if (!tokenFound)
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Logn()));
      }
      if (_localController.text != "http://192.168.") {
        setState(() {
          MyApp.url = _localController.text;
        });
        if (tokenFound)
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NavBar(fName)));
        if (!tokenFound)
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Logn()));
      }
    }
  }
}
