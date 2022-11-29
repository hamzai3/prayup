// ignore_for_file: file_names, prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:terry/login.dart';

import 'constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:auto_size_text/auto_size_text.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Constants c = Constants();
  TextEditingController name = TextEditingController();
  TextEditingController passsword = TextEditingController();
  TextEditingController email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // FirebaseFirestore firestore = new FirebaseFirestore();
  bool hide_password = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var checkedValue = 0;
  // ignore: non_constant_identifier_names
  List data = [];
  bool _loading = false, _isSubmitted = false;

  var close = 0;
  Future<bool> _exitApp(BuildContext context) async {
    if (close == 0) {
      c.showInSnackBar(context, "Press back again to EXIT");
      close++;
    } else {
      exit(0);
    }
    // Scaffold.of(context).showSnackBar(
    //   const SnackBar(content: Text("No back history item")),
    // );
    return Future.value(false);
  }

  Future<void> signUpWithEmailAndPassword(
    emailId,
    pwd,
  ) async {
    try {
      print(emailId);
      print(passsword);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailId,
        password: pwd,
      );
      print(userCredential.user);
      // print(userCredential.user?.displayName);
      // addUser();
      // c.setshared("name", value)
      FirebaseFirestore.instance.collection('users').add({
        'email': email.text.toString(),
        'fullname': name.text.toString(),
        'play': "5",
        'premium': 'NO',
        'download': '0',
        'play_limit': '0',
        'download_limit': '0',
        'subscribed_on': 'NO',
        'for_days': '0',
        'plan': '0 Days',
      });
      c.showInSnackBar(context, "Account registered, Login to continue");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
        Navigator.push(context, CupertinoPageRoute(builder: (_) => Login()));
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        print('${e.code}');
        if (e.code.toString().trim() == 'email-already-in-use') {
          c.showInSnackBar(context, "Account already exists,try another email");
        } else {
          c.showInSnackBar(context, "Something went wrong, Try again");
        }
      });
    }
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
                                    'Sign up to continue'.toString(),
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
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    // return 'Mobile number is mandatory';
                                    return 'Name cannot be empty';
                                  }
                                },
                                controller: name,
                                style: TextStyle(
                                    fontSize: c.getFontSize(context),
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.person_outline,
                                    color: c.whiteColor(),
                                  ),
                                  hintText: "Name",
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
                          Padding(
                            padding: EdgeInsets.only(
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
                                          ? Icons.lock_outline
                                          : Icons.lock_open_outlined,
                                      color: c.whiteColor(),
                                    ),
                                  ),
                                  // suffix: InkWell(
                                  //   onTap: () {
                                  //     setState(() {
                                  //       if (hide_password) {
                                  //         hide_password = false;
                                  //       } else {
                                  //         hide_password = true;
                                  //       }
                                  //     });
                                  //   },
                                  //   child: Text(
                                  //     hide_password ? "😑" : "😯",
                                  //     style: TextStyle(color: c.whiteColor()),
                                  //   ),
                                  // ),
                                  hintText: "Password",
                                  fillColor: c.primaryColor(),
                                  hintStyle: TextStyle(
                                      fontSize: c.getFontSize(context),
                                      color: Colors.white),
                                  border: OutlineInputBorder(), filled: true,
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
                                        signUpWithEmailAndPassword(
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
                                        gradient: c.buttonGradient(),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Sign Up",
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
