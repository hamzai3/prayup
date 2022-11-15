import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terry/NoInternet.dart';
import 'package:terry/bottomNav.dart';
import 'package:terry/constants.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Constants c = Constants();
  final _formKey = GlobalKey<FormState>();
  List? data;
  TextEditingController email = TextEditingController();
  TextEditingController pwd = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitted = false;
  Response? form_response;

  bool hide_password = true;
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoSizeText(value,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: c.getFontSizeLabel(context),
              fontFamily: c.fontFamily(),
              color: Colors.white)),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      elevation: 5.0,
    ));
  }

  var close = 0;
  Future<bool> _exitApp(BuildContext context) async {
    if (close == 0) {
      showInSnackBar("Press back again to close app");
      close++;
    } else {
      exit(0);
    }
    return Future.value(false);
  }

  var user_id;
  _notifications() async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "getAllNotification": "getAllNotification",
          "user_id": user_id,
        });
        try {
          form_response = await dio.post(
            c.getURL() + '/notifications.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        decodeCat(form_response.toString());
        c.setshared("notifications", form_response.toString());
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NoInternet()),
            ModalRoute.withName('/NoInternet'));
      }
    } catch (e, s) {
      print("Error " + e.toString() + " Stack " + s.toString());
    }
  }

  bool isLoading = true, no_records = false;
  late List data_category;
  decodeCat(js) {
    print(js);
    setState(() {
      var jsonval = json.decode(js);
      data = jsonval["response"];
      if (data![0]['status'] == "failed") {
        setState(() {
          isLoading = false;
          no_records = true;
        });
      } else if (data![0]['status'] == "success") {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    c.getshared("notifications").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodeCat(value);
      }
      _notifications();
    });
    c.getshared("user_id").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          user_id = value;
          print("user id is $user_id");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: c.getAppBar("Notifications", context, transition: true),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : no_records
              ? Center(
                  child: Text(
                    "No Notifications Found",
                    style: TextStyle(
                      color: c.getColor("light_black"),
                      fontSize: c.getFontSizeLarge(context) - 10,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: data?.length,
                  itemBuilder: (context, i) {
                    return Container(
                      decoration: BoxDecoration(
                        color: c.getColor("light_blue"),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.only(
                        top: 30.0,
                        left: MediaQuery.of(context).size.height * 0.02,
                        right: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: ListTile(
                        title: Text.rich(
                          TextSpan(
                            style: TextStyle(
                                fontSize: c.getFontSizeSmall(context),
                                fontFamily: c.fontFamily()),
                            children: [
                              TextSpan(
                                text: (data?[i]['msg']
                                    .toString()
                                    .split(",")[0]
                                    .toString()),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: c.fontFamily()),
                              ),
                              TextSpan(
                                text: data?[i]['msg'].toString().replaceAll(
                                    data![i]['msg']
                                        .toString()
                                        .split(",")[0]
                                        .toString(),
                                    ''),
                              ),
                            ],
                          ),
                        ),
                        trailing: Text.rich(
                          TextSpan(
                            style: TextStyle(
                                fontSize: c.getFontSizeXS(context) - 3,
                                fontFamily: c.fontFamily()),
                            children: [
                              TextSpan(
                                text: data![i]['added_on'].toString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
      bottomNavigationBar: BottomNav(currentPage: 2),
    );
  }
}
