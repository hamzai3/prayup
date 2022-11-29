// ignore_for_file: file_names, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:terry/help.dart';
import 'package:terry/home.dart';
import 'package:terry/register.dart';

import 'constants.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Constants c = Constants();
  TextEditingController passsword = TextEditingController();
  TextEditingController email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hide_password = true;
  bool _isSubmitted = false;

  var checkedValue = 0;
  // ignore: non_constant_identifier_names
  List data = [];
  bool _loading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future signInWithEmailAndPassword(
    email,
    password,
  ) async {
    c.showInSnackBar(context, "Please wait...");
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      c.setshared("UserName", email.toString());
      QuerySnapshot querySnapshot = await _collectionRef.get();
      // Get data from docs and convert map to List
      setState(() {
        List doc_id = [];
        var mydoc_id;
        List allData = querySnapshot.docs.map((doc) => doc.data()).toList();
        querySnapshot.docs.forEach((element) {
          print("docs are ");
          doc_id.add(element.id);
        });

        for (int u = 0; u < allData.length; u++) {
          if (allData[u]['email'] == email.toString()) {
            // allData = (allData[u]);
            mydoc_id = (doc_id[u]);
            break;
          }
        }
        print("MyDocId" + mydoc_id.toString());
        c.setshared("MyDocId", mydoc_id);
      });
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
        Navigator.push(context, CupertinoPageRoute(builder: (_) => Help()));
      });
    } on Exception catch (e) {
      print(" e $e");
      c.showInSnackBar(context, "Invalid details, Try again");
    }
  }

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('users');

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getLogin();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: c.bgColor(),
        body: WillPopScope(
            onWillPop: () => _exitApp(context),
            child: SafeArea(
                child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(7),
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                child: Container(
                                    child: Image.asset(
                                  "assets/logo.png",
                                  width: c.deviceWidth(context) * 0.3,
                                )),
                              ),
                            ),
                          ),
                          c.getDivider(20.0),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 17),
                                  child: AutoSizeText(
                                    'Welcome',
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
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 17),
                                  child: AutoSizeText(
                                    'Sign in to continue'.toString(),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: c.getFontSizeSmall(context),
                                        // fontWeight: FontWeight.w800,
                                        color: c.getColor("grey")),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 30.0,
                              left: MediaQuery.of(context).size.height * 0.02,
                              right: MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.082,
                              width: MediaQuery.of(context).size.width * 8.0,
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // return 'Mobile number is mandatory';
                                    return 'Email ID cannot be empty';
                                  }
                                },
                                controller: email,
                                style: TextStyle(
                                    fontSize: c.getFontSize(context),
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.email_outlined,
                                    color: c.whiteColor(),
                                  ),
                                  hintText: "Email",
                                  filled: true,
                                  fillColor: c.primaryColor(),
                                  hintStyle: TextStyle(
                                      fontSize: c.getFontSize(context),
                                      color: Colors.white),
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
                              // top: 10.0,
                              left: MediaQuery.of(context).size.height * 0.02,
                              right: MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.082,
                              width: MediaQuery.of(context).size.width * 8.0,
                              child: TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // return 'Mobile number is mandatory';
                                    return 'Password cannot be empty';
                                  }
                                },
                                obscureText: hide_password,
                                controller: passsword,
                                style: TextStyle(
                                    fontSize: c.getFontSize(context),
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (hide_password) {
                                          hide_password = false;
                                        } else {
                                          hide_password = true;
                                        }
                                      });
                                    },
                                    child: Icon(
                                      hide_password
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: c.whiteColor(),
                                    ),
                                  ),
                                  filled: true,
                                  hintText: "Password",
                                  fillColor: c.primaryColor(),
                                  hintStyle: TextStyle(
                                      fontSize: c.getFontSize(context),
                                      color: Colors.white),
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
                          InkWell(
                            onTap: () {
                              Future.delayed(const Duration(seconds: 0), () {
                                // Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) => Forgot()));
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.height * 0.02,
                                right:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                        fontSize: c.getFontSizeXS(context),
                                        color: c.whiteColor()),
                                  )
                                ],
                              ),
                            ),
                          ),
                          _isSubmitted
                              ? Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: EdgeInsets.only(
                                    top: 30.0,
                                    bottom: 30.0,
                                    left: MediaQuery.of(context).size.height *
                                        0.02,
                                    right: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  child: InkResponse(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        print("Login");
                                        signInWithEmailAndPassword(
                                            email.text, passsword.text);
                                      }
                                      // Future.delayed(const Duration(seconds: 0), () {
                                      //   Navigator.of(context).pop();
                                      //   Navigator.push(
                                      //       context,
                                      //       CupertinoPageRoute(
                                      //           builder: (_) => Intros()));
                                      // });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        // color: c.primaryColor(),
                                        gradient: c.buttonGradient(),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Sign In",
                                          style: TextStyle(
                                            color: c.whiteColor(),
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                c.getFontSizeLabel(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: c.getFontSizeLabel(context),
                                        fontFamily: c.fontFamily()),
                                    children: [
                                      TextSpan(
                                        text: 'OR',
                                        style: TextStyle(
                                          color: c.whiteColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => Register()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: c.getFontSizeLabel(context),
                                        fontFamily: c.fontFamily()),
                                    children: [
                                      TextSpan(
                                          text: "Don't have account? ",
                                          style: TextStyle(
                                            color: c.whiteColor(),
                                          )),
                                      TextSpan(
                                        text: 'Sign Up',
                                        style: TextStyle(
                                            color: c.whiteColor(),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                )
              ],
            ))));
  }
}

class Forgot extends StatefulWidget {
  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  Constants c = Constants();
  TextEditingController passsword = TextEditingController();
  TextEditingController email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool hide_password = true;
  bool _isSubmitted = false;

  var checkedValue = 0;
  // ignore: non_constant_identifier_names
  List data = [];
  bool _loading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future signInWithEmailAndPassword(
    email,
    password,
  ) async {
    c.showInSnackBar(context, "Please wait...");
    try {
      c.showInSnackBar(context,
          "Your request to reset password is received you well received email with a link to reste password");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
        Navigator.push(context, CupertinoPageRoute(builder: (_) => Login()));
      });
      // final userCredential = await _auth.signInWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      c.setshared("UserName", email.toString());
      // c.showInSnackBar(context, "Login success");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
        Navigator.push(context, CupertinoPageRoute(builder: (_) => Login()));
      });
    } on Exception catch (e) {
      print(" e $e");
      c.showInSnackBar(context, "");
    }
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getLogin();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: c.bgColor(),
        body: WillPopScope(
            onWillPop: () => _exitApp(context),
            child: SafeArea(
                child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(7),
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                child: Container(
                                    child: Image.asset(
                                  "assets/logo.png",
                                  width: c.deviceWidth(context) * 0.3,
                                )),
                              ),
                            ),
                          ),
                          c.getDivider(20.0),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 17),
                                  child: AutoSizeText(
                                    'Recover Account',
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
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 17),
                                    child: AutoSizeText(
                                      'Enter the email associated with your account and we’ll send an email with instructions to reset your password.'
                                          .toString(),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: c.getFontSizeSmall(context),
                                          // fontWeight: FontWeight.w800,
                                          color: c.getColor("grey")),
                                    )),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 30.0,
                              left: MediaQuery.of(context).size.height * 0.02,
                              right: MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.082,
                              width: MediaQuery.of(context).size.width * 8.0,
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // return 'Mobile number is mandatory';
                                    return 'Email ID cannot be empty';
                                  }
                                },
                                controller: email,
                                style: TextStyle(
                                    fontSize: c.getFontSize(context),
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.email_outlined,
                                    color: c.whiteColor(),
                                  ),
                                  hintText: "Email",
                                  fillColor: c.primaryColor(),
                                  filled: true,
                                  hintStyle: TextStyle(
                                      fontSize: c.getFontSize(context),
                                      color: Colors.white),
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
                                    top: 30.0,
                                    bottom: 30.0,
                                    left: MediaQuery.of(context).size.height *
                                        0.02,
                                    right: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  child: InkResponse(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        print("Login");
                                        signInWithEmailAndPassword(
                                            email.text, passsword.text);
                                      }
                                      // Future.delayed(const Duration(seconds: 0), () {
                                      //   Navigator.of(context).pop();
                                      //   Navigator.push(
                                      //       context,
                                      //       CupertinoPageRoute(
                                      //           builder: (_) => Intros()));
                                      // });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(13),
                                      decoration: BoxDecoration(
                                        // color: c.primaryColor(),
                                        gradient: c.buttonGradient(),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Sign In",
                                          style: TextStyle(
                                            color: c.whiteColor(),
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                c.getFontSizeLabel(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: c.getFontSizeLabel(context),
                                        fontFamily: c.fontFamily()),
                                    children: [
                                      TextSpan(
                                        text: 'OR',
                                        style: TextStyle(
                                          color: c.whiteColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.push(context,
                                  CupertinoPageRoute(builder: (_) => Login()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: c.getFontSizeLabel(context),
                                        fontFamily: c.fontFamily()),
                                    children: [
                                      TextSpan(
                                          text: "Already have an account? ",
                                          style: TextStyle(
                                            color: c.whiteColor(),
                                          )),
                                      TextSpan(
                                        text: 'Sign in',
                                        style: TextStyle(
                                            color: c.whiteColor(),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                )
              ],
            ))));
  }
}
