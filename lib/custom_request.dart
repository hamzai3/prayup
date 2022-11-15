// ignore_for_file: file_names, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:terry/NoInternet.dart';
import 'package:terry/home.dart';
import 'package:terry/profile.dart';
import 'package:terry/register.dart';

import 'package:dio/dio.dart';
import 'package:terry/requestedPrayers.dart';
import 'constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class CustomRequest extends StatefulWidget {
  @override
  _CustomRequestState createState() => _CustomRequestState();
}

class _CustomRequestState extends State<CustomRequest> {
  Constants c = Constants();
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController recipent_fname = TextEditingController();
  TextEditingController recipent_lname = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController recipent_email = TextEditingController();
  TextEditingController note = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  var selected_cat = 'Select Category';
  var close = 0;
  Future<bool> _exitApp(BuildContext context) async {
    if (close == 0) {
      c.showInSnackBar(context, "Press back again to EXIT");
      close++;
    } else {
      exit(0);
    }
    return Future.value(false);
  }

  var user_id;
  Response? form_response;
  _request() async {
    try {
      var dio = Dio();
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "user_prayer": "user_prayer",
          "note": note.text,
          "user": user,
          "name": fname.text,
          "r_email": recipent_email.text,
          "category": selected_cat,
          "r_gender": gender.text,
          "rf_name": recipent_fname.text,
          "rf_lname": recipent_lname.text,
        });
        try {
          form_response = await dio.post(
            c.getURL() + 'user_api.php',
            data: formData,
          );
        } on DioError catch (e) {
          print(e.message);
        }

        FirebaseFirestore.instance
            .collection('prayersRequests')
            .add({'email': user.toString(), 'prayer': email.text.toString()});
        email.text = '';
        c.setshared("CustomPaid", "FALSE");
        Future.delayed(Duration(milliseconds: 900), () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (_) => Profile()));
        });
        print(form_response.toString());
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

  var user = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    c.getshared("UserName").then((value) {
      if (value != 'null') {
        setState(() {
          user = value;
          // email.text = value;
        });
      }
    });
    c.getshared("fullname").then((value) {
      if (value != 'null') {
        setState(() {
          // fname.text = value;
        });
      }
    });
    // getCustomRequest();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.blackColor(),
      appBar: CupertinoNavigationBar(
        backgroundColor: c.blackColor(),
        middle: Text(
          'Custom Prayer',
          style:
              TextStyle(fontSize: c.getFontSize(context), color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.all(7),
                      //   child: Container(
                      //     child: Padding(
                      //       padding:
                      //           EdgeInsets.only(left: 20, right: 20, top: 20),
                      //       child: Container(
                      //           child: Image.asset(
                      //         "assets/logo.png",
                      //         width: c.deviceWidth(context) * 0.3,
                      //       )),
                      //     ),
                      //   ),
                      // ),
                      c.getDivider(20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: AutoSizeText(
                                'Custom Prayer',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: c.whiteColor(),
                                  fontFamily: c.fontFamily(),
                                  fontSize: c.getFontSizeLarge(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              )),
                        ],
                      ),
                      c.getDivider(c.deviceHeight(context) * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: AutoSizeText(
                                  'Here you can request custom prayer for yourself and  your special ones '
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: c.getFontSizeSmall(context),
                                      // fontWeight: FontWeight.w800,
                                      color: c.getColor("grey")),
                                )),
                          ),
                        ],
                      ),
                      c.getDivider(c.deviceHeight(context) * 0.01),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Your name cannot be empty';
                              }
                            },
                            controller: fname,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Your Name",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.080,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Your Email cannot be empty';
                              }
                            },
                            controller: email,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Your Email",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.080,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Recipient first name cannot be empty';
                              }
                            },
                            controller: recipent_fname,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Recipient First Name",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.080,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Recipient last name cannot be empty';
                              }
                            },
                            controller: recipent_lname,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Recipient Last Name",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.080,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Recipient Gender cannot be empty';
                              }
                            },
                            controller: gender,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Recipient Gender",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.02,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.080,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Recipient email cannot be empty';
                              }
                            },
                            controller: recipent_email,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Recipient Email",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.height * 0.02,
                            right: MediaQuery.of(context).size.height * 0.02,
                            bottom: 10),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.width * 8.0,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: c.whiteColor(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DropdownButton<String>(
                                iconEnabledColor: Colors.white,
                                hint: Text("Select Category"),
                                value: selected_cat,
                                items: <String>[
                                  "Select Category",
                                  "Health",
                                  "Finances",
                                  "Family",
                                  "Job",
                                  "School",
                                  "Wife",
                                  "healing",
                                  "new Home",
                                  "car ",
                                  "faith",
                                  "studies",
                                  "ministry",
                                  "pastor ",
                                  "Church",
                                  "husband",
                                  "Mother",
                                  "father",
                                  "Son",
                                  "Daughter",
                                  "birthday ",
                                  "anniversary",
                                  "marriage",
                                  "promotion ",
                                  "Other"
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      c.capitalize(value),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (s) {
                                  setState(() {
                                    selected_cat = s!;
                                  });
                                },
                              ),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.height * 0.02,
                            right: MediaQuery.of(context).size.height * 0.02,
                            bottom: 30),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 8.0,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value!.isEmpty) {
                                // return 'Mobile number is mandatory';
                                return 'Prayer note cannot be empty';
                              }
                            },
                            controller: note,
                            style: TextStyle(
                                fontSize: c.getFontSize(context),
                                color: Colors.black),
                            minLines: 5,
                            maxLines: 8,
                            maxLength: 30,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.email_outlined,
                                color: c.whiteColor(),
                              ),
                              hintText: "Note",
                              filled: true,
                              fillColor: c.whiteColor(),
                              hintStyle: TextStyle(
                                  fontSize: c.getFontSize(context),
                                  color: Colors.black),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: BorderSide(
                                  color: c.primaryColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _isSubmitted
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: EdgeInsets.only(
                                bottom: 30.0,
                                left: MediaQuery.of(context).size.height * 0.02,
                                right:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              child: InkResponse(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    print("CustomRequest");
                                    _request();
                                    c.showInSnackBar(context,
                                        "Request sent, we will get back on this request!");
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: c.primaryColor(),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Request",
                                      style: TextStyle(
                                        color: c.blackColor(),
                                        fontWeight: FontWeight.w600,
                                        fontSize: c.getFontSizeLabel(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
