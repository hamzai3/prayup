import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:terry/constants.dart';
import 'package:terry/profile.dart';
import 'package:terry/searchPrayer.dart';
import 'home.dart';

class BottomNav extends StatefulWidget {
  final currentPage, url;

  BottomNav({this.currentPage, this.url});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  var _currentIndex = 0;
  Constants c = new Constants();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Color(0xFF171717),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      currentIndex: widget.currentPage,
      selectedItemColor: c.primaryColor(),
      items: [
        BottomNavigationBarItem(
          backgroundColor: c.tertiaryColor(),
          icon: Icon(
            Icons.home,
            color: Colors.white,
            size: 26,
          ),
          activeIcon: Icon(
            Icons.home,
            color: c.primaryColor(),
            size: 26,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 26,
            ),
            activeIcon: Icon(
              Icons.search_rounded,
              color: c.primaryColor(),
              size: 26,
            ),
            label: "Search"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.white,
              size: 26,
            ),
            activeIcon: Icon(
              Icons.person,
              color: c.primaryColor(),
              size: 26,
            ),
            label: "Profile"),
      ],
      onTap: (index) {
        _currentIndex = widget.currentPage;
        if (index == 0) {
          Navigator.pop(context);
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Home()));
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     '/HomePage', (Route<dynamic> route) => false);
        }
        if (index == 1) {
          Navigator.pop(context);

          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => SearchPrayer()));
          // Navigator.push(
          //     context, CupertinoPageRoute(builder: (context) => Explore()));
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     '/LearnPage', (Route<dynamic> route) => false);
        }
        if (index == 2) {
          Navigator.pop(context);

          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => Profile()));
          // Navigator.push(
          //     context, CupertinoPageRoute(builder: (context) => Feeds()));
        }
      },
    );
  }
}
//for Logout and remove all presvios BACK
//Navigator.of(context).pushNamedAndRemoveUntil('/screen4', (Route<dynamic> route) => false);
