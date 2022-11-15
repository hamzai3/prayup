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
import 'package:terry/register.dart';
import 'package:terry/requestedPrayerPlayer.dart';

class RequestedPrayers extends StatefulWidget {
  @override
  _RequestedPrayersState createState() => _RequestedPrayersState();
}

class _RequestedPrayersState extends State<RequestedPrayers> {
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
          "getAllPrayers": "getAllPrayers",
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'user_api.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }
        decodeCat(form_response.toString());
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
  var temp = [];
  decodeCat(js) {
    print(js);
    setState(() {
      // js = js.replaceAll('{', '{"');
      // js = js.replaceAll(': ', '": "');
      // js = js.replaceAll(', ', '", "');
      // js = js.replaceAll('}', '"}');
      // js = js.replaceAll('}", "{', '},{');
      // print(js);
      temp = json.decode(js)['response'];
      isLoading = false;
      print(temp.length);
      //jsvar str1 = js
      //     .toString()
      //     .replaceAll("[{", "")
      //     .replaceAll("}]", "")
      //     .replaceAll("{id", "id")
      //     .split("},");
      // print("str1 $str1");
      // // data = str1;
      // print("String is ");
      // print(str1[0]);
      // for (int p = 0; p < str1.length; p++) {
      //   var single = [];
      //   for (int s = 0; s < str1[p].split(",").length; s++) {
      //     single.add(str1.toString().split(":"));
      //   }
      //   temp.add(str1[p].split(","));
      // }
      // print("Final array ");
      // print(temp);
      // isLoading = false;
      // if (data![0]['status'] == "failed") {
      //   setState(() {
      //     // isLoading = false;
      //     no_records = true;
      //   });
      // } else if (data![0]['status'] == "success") {
      //   setState(() {
      //     // isLoading = false;
      //   });
      // }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    c.getshared("UserName").then((value) {
      if (value != '' && value != null && value != ' ' && value != 'null') {
        setState(() {
          user_id = value;
          print("user id is $user_id");
        });
      }
    });
    c.getshared("notifications").then((value) {
      // print("CatVal $value");
      if (value != '' && value != null && value != ' ' && value != 'null') {
        decodeCat(value);
      }
      _notifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: CupertinoNavigationBar(
        backgroundColor: c.blackColor(),
        middle: Text(
          'Requested Prayers',
          style:
              TextStyle(fontSize: c.getFontSize(context), color: Colors.white),
        ),
      ),
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
              : SizedBox(
                  height: c.deviceHeight(context),
                  child: ListView.builder(
                      itemCount: temp.length,
                      itemBuilder: (context, i) {
                        return temp[i]['for_user'].toString() != user_id
                            ? Container()
                            : Container(
                                decoration: BoxDecoration(
                                  color: c.primaryColor(),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                margin: EdgeInsets.only(
                                  top: 30.0,
                                  left:
                                      MediaQuery.of(context).size.height * 0.02,
                                  right:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                RequestedPlayerPageOffline(
                                                  data: temp[i],
                                                )));
                                  },
                                  title: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                          fontSize: c.getFontSizeSmall(context),
                                          fontFamily: c.fontFamily()),
                                      children: [
                                        TextSpan(
                                          text: (temp[i]['prayer_name']
                                              .toString()),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: c.fontFamily()),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                          fontSize:
                                              c.getFontSizeSmall(context) - 3,
                                          fontFamily: c.fontFamily()),
                                      children: [
                                        TextSpan(
                                          text: temp[i]['artist'].toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.play_arrow,
                                    color: c.whiteColor(),
                                  ),
                                ),
                              );
                      }),
                ),
      bottomNavigationBar: BottomNav(currentPage: 2),
    );
  }
}
