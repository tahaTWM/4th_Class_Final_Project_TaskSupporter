import 'package:flutter/material.dart';
import '../login/logn.dart';
import 'data.dart';
import 'register.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // ignore: deprecated_member_use
  List<SliderModel> mySLides = new List<SliderModel>();
  int slideIndex = 0;
  PageController controller;

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.0),
      height: isCurrentPage ? 12.0 : 8.0,
      width: isCurrentPage ? 12.0 : 8.0,
      decoration: BoxDecoration(
        color: isCurrentPage
            ? Color.fromRGBO(0, 220, 82, 1)
            : Color.fromRGBO(184, 217, 196, 1),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Icon icon = Icon(
    Icons.arrow_forward_rounded,
    size: 35.0,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    mySLides = getSlides();
    controller = new PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(69, 89, 122, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            // ignore: deprecated_member_use
            overflow: Overflow.visible,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(31, 31, 35, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(80),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.29,
                child: PageView(
                  controller: controller,
                  onPageChanged: (index) {
                    setState(() {
                      slideIndex = index;
                      if (slideIndex == 2) {
                        setState(() {
                          icon = Icon(Icons.arrow_downward_rounded,
                              size: 35, color: Colors.white);
                        });
                      }
                    });
                  },
                  children: <Widget>[
                    SlideTile(
                      imagePath: mySLides[0].getImageAssetPath(),
                      title: mySLides[0].getTitle(),
                      desc: mySLides[0].getDesc(),
                    ),
                    SlideTile(
                      imagePath: mySLides[1].getImageAssetPath(),
                      title: mySLides[1].getTitle(),
                      desc: mySLides[1].getDesc(),
                    ),
                    SlideTile(
                      imagePath: mySLides[2].getImageAssetPath(),
                      title: mySLides[2].getTitle(),
                      desc: mySLides[2].getDesc(),
                    ),
                  ],
                ),
              ),
              // FractionalTranslation(
              //   translation: Offset(0.0, 0.5),
              //   child: MaterialButton(
              //     onPressed: () {
              //       controller.animateToPage(++slideIndex,
              //           duration: Duration(milliseconds: 100),
              //           curve: Curves.linear);
              //     },
              //     color: Color.fromRGBO(111, 224, 153, 1),
              //     textColor: Colors.white,
              //     child: Icon(
              //       Icons.keyboard_arrow_right,
              //       size: 70,
              //     ),
              //     padding: EdgeInsets.all(16),
              //     shape: CircleBorder(),
              //   ),
              // ),
              Positioned(
                bottom: 100,
                child: slideIndex != 2
                    ? Container(
                        child: Row(
                          children: [
                            for (int i = 0; i < 3; i++)
                              i == slideIndex
                                  ? _buildPageIndicator(true)
                                  : _buildPageIndicator(false),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          _buildPageIndicator(false),
                          _buildPageIndicator(false),
                          _buildPageIndicator(true),
                        ],
                      ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonTheme(
                  height: 75,
                  minWidth: 160,
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Register()));
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'GiloryBold',
                          color: Color.fromRGBO(0, 82, 204, 1)),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(width: 40),
                ButtonTheme(
                  height: 75,
                  minWidth: 160,
                  child: RaisedButton(
                    textColor: Colors.white,
                    color: Color.fromRGBO(0, 82, 204, 1),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Logn()));
                    },
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'GiloryBold',
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class SlideTile extends StatelessWidget {
  String imagePath, title, desc;

  SlideTile({this.imagePath, this.title, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(imagePath),
          SizedBox(
            height: 20,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontFamily: "GiloryBold",
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(255, 195, 17, 1),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: "GiloryBold",
              ))
        ],
      ),
    );
  }
}
