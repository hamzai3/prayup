import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class NoInternet extends StatefulWidget {
  NoInternetState createState() => NoInternetState();
}

class NoInternetState extends State<NoInternet> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  _checkCon() async {
    // Navigator.of(context).pushReplacementNamed('/');
  }

  startTime() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var _duration = new Duration(seconds: 1);
        return new Timer(_duration, _checkCon);
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.only(top: 35.0),
                  child: new Image.asset(
                    'assets/nointernet.gif',
                    fit: BoxFit.fitHeight,
                    width: double.infinity,
                  ),
                ),
//              new AutoSizeAutoSizeText("You don't have Internet Connection"),
                new Card(
                    child: new CupertinoButton(
                        child: new AutoSizeText(
                          "Try again",
                          style: new TextStyle(fontSize: 15.0),
                        ),
                        onPressed: () {
                          _checkCon();
                        }))
              ],
            ),
          )),
    );
  }
}
