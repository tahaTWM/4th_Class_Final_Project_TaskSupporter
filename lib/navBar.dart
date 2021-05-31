import 'package:flutter/cupertino.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'profile/profile.dart';
import 'package:flutter/material.dart';
import './homePage/homepage.dart';

class NavBar extends StatefulWidget {
  String fristName;
  NavBar(this.fristName);
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedItem;
  List<Widget> contents = [];
  @override
  Future<void> initState() {
    _selectedItem = 0;
    super.initState();
    contents.add(HomePage(widget.fristName));
    contents.add(Profile());
    // contents.add(Profile());
    // contents.add(Profile());
    // contents.add(Profile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 2),
      bottomNavigationBar: CustomBottomNavigationBar(
        iconList: [
          Typicons.th_large_outline,
          Icons.person_outline,
        ],
        textList: [
          "Workspaces",
          "Profile",
        ],
        onChange: (indx) {
          setState(() {
            _selectedItem = indx;
          });
        },
        defaultSelectedIndex: _selectedItem,
      ),
      body: Center(
        child: contents[_selectedItem],
      ),
    );
  }
}

class CustomBottomNavigationBar extends StatefulWidget {
  final int defaultSelectedIndex;
  final Function(int) onChange;
  final List<IconData> iconList;
  final List<String> textList;

  CustomBottomNavigationBar(
      {this.defaultSelectedIndex = 0,
      @required this.iconList,
      @required this.textList,
      @required this.onChange});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  List<IconData> _iconList = [];
  List<String> _textList = [];

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.defaultSelectedIndex;
    _iconList = widget.iconList;
    _textList = widget.textList;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _navBarItemList = [];

    for (var i = 0; i < _iconList.length; i++) {
      _navBarItemList.add(buildNavBarItem(_iconList[i], _textList[i], i));
    }

    return Container(
      color: Color.fromRGBO(243, 246, 255, 1),
      child: Row(
        children: _navBarItemList,
      ),
    );
  }

  Widget buildNavBarItem(IconData icon, String text, int index) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        widget.onChange(index);
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: width < 400 ? 50 : 60,
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.only(
          //     topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        width: MediaQuery.of(context).size.width / _iconList.length,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: index == _selectedIndex
                  ? Color.fromRGBO(0, 82, 205, 1)
                  : Colors.grey,
              size: width < 400 ? 18 : 25,
            ),
            Text(
              text,
              style: TextStyle(
                  color: index == _selectedIndex
                      ? Color.fromRGBO(0, 82, 205, 1)
                      : Colors.grey,
                  fontSize: width < 400 ? 14 : 20),
            ),
          ],
        ),
      ),
    );
  }
}
