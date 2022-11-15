import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:terry/audio_player.dart';
import 'package:terry/bottomNav.dart';
import 'package:terry/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:terry/custom_request.dart';
import 'package:terry/downloads.dart';
import 'package:terry/login.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:terry/playlist.dart';
import 'package:terry/requestedPrayers.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final showSheet;
  const Profile({super.key, this.showSheet});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController keyword = TextEditingController();

  late Map<String, dynamic> paymentIntentData;
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

  bool terms = false, warn = false;
  showAlert(BuildContext context, amount) {
    // set up the button
    // set up the AlertDialog
    var disp_amount = '0';

    if (amount == "1299") {
      disp_amount = "12.99";
    }

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Prayer Request",
                  style: TextStyle(
                      color: c.primaryColor(), fontWeight: FontWeight.w800),
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ))
              ],
            ),
            content: Text(
              "All sales are final and non-refundable",
              textAlign: TextAlign.center,
              style: TextStyle(color: c.primaryColor()),
            ),
            backgroundColor: Color(0xff252525),
            actions: [
              CheckboxListTile(
                title: Text(
                  "I agree terms & conditions",
                  style: TextStyle(color: warn ? Colors.red : Colors.white),
                ),
                activeColor: Colors.white,
                value: terms,
                onChanged: (newValue) {
                  print("Ok0");
                  setState(() {
                    terms = newValue!;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1.0, color: c.primaryColor()),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: c.primaryColor()),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: c.primaryColor(),
                      border: Border.all(width: 1.0, color: c.primaryColor()),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: TextButton(
                      child: Text(
                        "Continue",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (terms) {
                          Navigator.of(context).pop("cancel");
                          makePayment("custom", amount: "1299");
                        } else {
                          setState(() {
                            warn = true;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  List temp_data = [];
  int _current = 0;
  List sliderCount = [0, 1, 2, 3, 4];
  Constants c = Constants();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var allData, mydoc_id;
  bool isLoading = false;
  var username = "", fullname = '';
  DateTime now = new DateTime.now();

  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('users');

  final String _collection = 'collectionName';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.showSheet != null && widget.showSheet == true) {
      Future.delayed(Duration(microseconds: 500),
          (() => {showModalBottomSheetCupetino()}));
    }

    c.getshared("MyDocId").then((value) {
      if (value != 'null') {
        setState(() {
          mydoc_id = value;
        });
      }
    });
    // Stripe.publishableKey =
    //     'pk_test_51LqJSeLJDPAQV3CJBZijW1rN1zLfpGI92p4cp2lPXwHEkcsJW5Lr5JbVqm8AN1GfnVFrIr57Sp5kOeY0xoIqAT7O00CymHtH1u';
    // c.setshared("FreeDownload", (2).toString());
    // c.setshared("downlaods", "");
    // StripePayment.setOptions(
    //   StripeOptions(
    //      publishableKey:"YOUR_PUBLISHABLE_KEY"
    //       merchantId: "YOUR_MERCHANT_ID"
    //       androidPayMode: 'test'
// ));
//     Stripe.publishableKey =
//         'pk_test_51LqJSeLJDPAQV3CJBZijW1rN1zLfpGI92p4cp2lPXwHEkcsJW5Lr5JbVqm8AN1GfnVFrIr57Sp5kOeY0xoIqAT7O00CymHtH1u';
    // StripeNative.setPublishableKey(
    //     "pk_test_51LqJSeLJDPAQV3CJBZijW1rN1zLfpGI92p4cp2lPXwHEkcsJW5Lr5JbVqm8AN1GfnVFrIr57Sp5kOeY0xoIqAT7O00CymHtH1u");
    // StripeNative.setMerchantIdentifier("merchant.identifier");

    c.getshared("UserName").then((value) {
      setState(() {
        print(username);
        if (value != 'null') {
          username = value;
        } else {
          username = "Guest";
        }
      });
    });

    c.getshared("UserName").then((value) {
      if (value != null) {
        c.isUpdated(value).then((updated) {
          print("updayed resp is $updated");
          if (updated != null) {
            if (updated == false) {
              setState(() {
                isPremimum = false;
              });
            } else {
              setState(() {
                fullname = updated['fullname'];
                c.setshared("fullname", fullname);
              });
              if (updated['premium'] == 'YES') {
                setState(() {
                  isPremimum = true;
                });
              } else {
                setState(() {
                  isPremimum = false;
                });
              }
            }
          } else {
            setState(() {
              isPremimum = false;
            });
          }
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  bool isPremimum = false;
  void showModalBottomSheetCupetino() async {
    await showCupertinoModalBottomSheet(
      useRootNavigator: true,
      context: context,
      bounce: true,
      isDismissible: true,
      backgroundColor: const Color(0xff6B5A00),
      builder: (context) => Material(
        color: const Color(0xff6B5A00),
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                color: const Color(0xff6B5A00),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: ListTile(
                  title: AutoSizeText(
                    "Upgrade your plan",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: c.getFontSizeLabel(context) - 2,
                        // fontWeight: FontWeight.w800,
                        color: c.getColor("grey")),
                  ),
                  trailing: Container(
                      decoration: BoxDecoration(
                        // border: Border.all(
                        //   width: 1.0,
                        // ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        color: c.primaryColor(),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "PRO",
                          style: TextStyle(
                              // fontWeight: FontWeight.w800,
                              color: c.whiteColor()),
                        ),
                      ))),
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                color: const Color(0xff6B5A00),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pop("cancel");
                  makePayment("ONE", amount: "2999");
                },
                title: AutoSizeText(
                  "Subscribe for 3 Months",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: c.getFontSizeLabel(context) - 2,
                      // fontWeight: FontWeight.w800,
                      color: c.getColor("grey")),
                ),
                subtitle: AutoSizeText(
                  "Listen to 10 Free Songs\nDownload any 2 prayers",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: c.getFontSizeXS(context) - 3,
                      // fontWeight: FontWeight.w800,
                      color: c.getColor("grey")),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: c.getColor("red")),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    color: c.redColor(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "\$29.99",
                      style: TextStyle(
                          // fontWeight: FontWeight.w800,
                          color: c.whiteColor()),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                color: const Color(0xff6B5A00),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pop("cancel");
                  makePayment("TWO", amount: "4999");
                },
                title: AutoSizeText(
                  "Subscribe for 6 Months",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: c.getFontSizeLabel(context) - 2,
                      // fontWeight: FontWeight.w800,
                      color: c.getColor("grey")),
                ),
                subtitle: AutoSizeText(
                  "Listen to 20 Free Songs\nDownload any 5 prayers",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: c.getFontSizeXS(context) - 3,
                      // fontWeight: FontWeight.w800,
                      color: c.getColor("grey")),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: c.getColor("red")),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    color: c.redColor(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "\$49.99",
                      style: TextStyle(
                          // fontWeight: FontWeight.w800,
                          color: c.whiteColor()),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5.0),
              padding: const EdgeInsets.all(5.0),
              decoration: const BoxDecoration(
                color: const Color(0xff6B5A00),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pop("cancel");
                  makePayment("THREE", amount: "7999");
                  // FirebaseFirestore.instance.collection('subscribe').add({
                  //   'email': username.toString(),
                  //   'months': "12",
                  //   'free': "1000",
                  //   'download': "10",
                  //   'activated_on': now.year.toString() +
                  // "/" +
                  // now.month.toString() +
                  // "/" +
                  // now.day.toString(),
                  // });
                  // c.showInSnackBar(context,
                  //     "Congratulations, Subscription for 12 months is activated");
                  // setState(() {});
                  // Future.delayed(Duration(seconds: 1), () {
                  //   Navigator.push(
                  //       context, CupertinoPageRoute(builder: (_) => Profile()));
                  // });
                },
                title: AutoSizeText(
                  "Subscribe for 6 Months",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: c.getFontSizeLabel(context) - 2,
                      // fontWeight: FontWeight.w800,
                      color: c.getColor("grey")),
                ),
                subtitle: AutoSizeText(
                  "Listen to Unlimited Free Songs\nDownload any 10 prayers",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: c.getFontSizeXS(context) - 3,
                      // fontWeight: FontWeight.w800,
                      color: c.getColor("grey")),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0, color: c.getColor("red")),
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    color: c.redColor(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "\$79.99",
                      style: TextStyle(
                          // fontWeight: FontWeight.w800,
                          color: c.whiteColor()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.blackColor(),
      appBar: CupertinoNavigationBar(
        backgroundColor: c.blackColor(),
        middle: Text(
          'Profile',
          style:
              TextStyle(fontSize: c.getFontSize(context), color: Colors.white),
        ),
      ),
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  children: [
                    c.getDivider(c.deviceHeight(context) * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Initicon(
                          text: "$fullname".toUpperCase(),
                          elevation: 4,
                          size: c.deviceWidth(context) * 0.3,
                        ),
                        GestureDetector(
                          onTap: () {
                            c.showInSnackBar(context,
                                "Camera permissions not found, try again");
                          },
                          child: Icon(
                            Icons.edit,
                            color: c.whiteColor(),
                          ),
                        ),
                      ],
                    ),
                    c.getDivider(c.deviceHeight(context) * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 17),
                            child: AutoSizeText(
                              fullname.toUpperCase(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: c.whiteColor(),
                                fontFamily: c.fontFamily(),
                                fontSize: c.getFontSizeLabel(context) + 4,
                                fontWeight: FontWeight.w800,
                              ),
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 17),
                            child: AutoSizeText(
                              username.toUpperCase(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context) - 2,
                                  // fontWeight: FontWeight.w800,
                                  color: c.getColor("grey")),
                            )),
                      ],
                    ),
                    c.getDivider(c.deviceHeight(context) * 0.05),
                    isPremimum
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                                top: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                showModalBottomSheetCupetino();
                              },
                              leading: Icon(
                                Icons.star,
                                color: c.whiteColor(),
                              ),
                              title: Row(
                                children: [
                                  AutoSizeText(
                                    "Upgrade",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize:
                                            c.getFontSizeLabel(context) - 2,
                                        // fontWeight: FontWeight.w800,
                                        color: c.getColor("grey")),
                                  ),
                                  Container(
                                    width: 20,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.0,
                                            color: c.getColor("red")),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0)),
                                        color: c.redColor(),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Text(
                                          "PRO",
                                          style: TextStyle(
                                              // fontWeight: FontWeight.w800,
                                              color: c.whiteColor()),
                                        ),
                                      ))
                                ],
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: c.whiteColor(),
                              ),
                            ),
                          ),
                    !isPremimum
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) => RequestedPrayers()));
                              },
                              leading: Icon(
                                Icons.music_note,
                                color: c.whiteColor(),
                              ),
                              title: AutoSizeText(
                                "Prayer Requests",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: c.getFontSizeLabel(context) - 2,
                                    // fontWeight: FontWeight.w800,
                                    color: c.getColor("grey")),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: c.whiteColor(),
                              ),
                            ),
                          ),
                    !isPremimum
                        ? Container()
                        : Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  warn = false;
                                  terms = false;
                                });
                                c.getshared("CustomPaid").then((value) {
                                  if (value != null) {
                                    if (value == "TRUE") {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (_) => CustomRequest()));
                                    } else {
                                      showAlert(context, "12999");
                                    }
                                  } else {
                                    showAlert(context, "12999");
                                  }
                                });
                              },
                              leading: Icon(
                                Icons.queue_music_outlined,
                                color: c.whiteColor(),
                              ),
                              title: AutoSizeText(
                                "Custom Prayers",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: c.getFontSizeLabel(context) - 2,
                                    // fontWeight: FontWeight.w800,
                                    color: c.getColor("grey")),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: c.whiteColor(),
                              ),
                            ),
                          ),
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => PlayList()));
                        },
                        leading: Icon(
                          Icons.topic_outlined,
                          color: c.whiteColor(),
                        ),
                        title: AutoSizeText(
                          "Playlist",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: c.getFontSizeLabel(context) - 2,
                              // fontWeight: FontWeight.w800,
                              color: c.getColor("grey")),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: c.whiteColor(),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => MyDownloads()));
                        },
                        leading: Icon(
                          Icons.download,
                          color: c.whiteColor(),
                        ),
                        title: AutoSizeText(
                          "My Downloads",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: c.getFontSizeLabel(context) - 2,
                              // fontWeight: FontWeight.w800,
                              color: c.getColor("grey")),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: c.whiteColor(),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: c.whiteColor(),
                        ),
                        title: AutoSizeText(
                          "Logout",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: c.getFontSizeLabel(context) - 2,
                              // fontWeight: FontWeight.w800,
                              color: c.getColor("grey")),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: c.whiteColor(),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          c.clearShared().then((value) => Navigator.push(
                              context,
                              CupertinoPageRoute(builder: (_) => Login())));
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "Version 1.0.5",
                            style: TextStyle(
                              color: c.getColor("grey"),
                              fontSize: c.getFontSizeLabel(context) - 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: BottomNav(currentPage: 2),
    );
  }

  Future<void> makePayment(mode, {amount}) async {
    try {
      paymentIntentData = await createPaymentIntent(
          amount.toString(), 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntentData['client_secret'],
                  // applePay: true,
                  // googlePay: true,
                  // testEnv: true,
                  style: ThemeMode.light,
                  // merchantCountryCode: 'US',
                  merchantDisplayName: 'PrayUp'))
          .then((value) {
        // print("$value.toString()");
// if(value)
        var temp = value;
        // if(temp)

        print("After Patyment");
      });
      c.showInSnackBar(context, "Processing please wait...");

      ///now finally display payment sheeet
      displayPaymentSheet(mode);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(mode) async {
    try {
      // await Stripe.instance.confirmSetupIntent(
      //   paymentIntentData!['client_secret'],
      // );

      await Stripe.instance
          .presentPaymentSheet(
              parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData['client_secret'],
        confirmPayment: true,
      ))
          .then((newValue) async {
        setState(() {
          isLoading = true;
        });
        print('payment intent${paymentIntentData['id']}');
        print('payment intent${paymentIntentData['client_secret']}');
        print('payment intent${paymentIntentData['amount']}');
        String str = json.encode(paymentIntentData);
        print('payment intent$str');
        //orderPlaceApi(paymentIntentData!['id'].toString());
        // dynamicSnackBar(
        //   context: context,
        //   text: "Payment Successful",
        //   isErrorMsg: false,
        //   isSucessMsg: true,
        // );
        // await updateIsPaid();
        // Navigator.of(context).pop();
        // Navigator.of(context).pop();
        // Navigator.of(context).pop();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const ProductsScreen(),
        //   ),
        // );

        // paymentIntentData = null;
        print("Payment Done");

        if (mode == "ONE") {
          FirebaseFirestore.instance.collection('subscribe').add({
            'email': username.toString(),
            'months': "3",
            'free': "10",
            'download': "2",
            'activated_on': now.year.toString() +
                "/" +
                now.month.toString() +
                "/" +
                now.day.toString(),
          });
          c.showInSnackBar(context,
              "Congratulations, Subscription for 3 months is activated");
          setState(() {});
          c.updatedPremium(mydoc_id);
          c.updatedPlay("10", mydoc_id);
          c.updatedDownload("2", mydoc_id);
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
            Navigator.push(
                context, CupertinoPageRoute(builder: (_) => Profile()));
          });
        } else if (mode == "TWO") {
          FirebaseFirestore.instance.collection('subscribe').add({
            'email': username.toString(),
            'months': "6",
            'free': "20",
            'download': "5",
            'activated_on': now.year.toString() +
                "/" +
                now.month.toString() +
                "/" +
                now.day.toString(),
          });
          c.showInSnackBar(context,
              "Congratulations, Subscription for 6 months is activated");
          setState(() {});
          c.updatedPremium(mydoc_id);
          c.updatedPlay("20", mydoc_id);
          c.updatedDownload("5", mydoc_id);
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
            Navigator.push(
                context, CupertinoPageRoute(builder: (_) => Profile()));
          });
        } else if (mode == "TWO") {
          FirebaseFirestore.instance.collection('subscribe').add({
            'email': username.toString(),
            'months': "12",
            'free': "100000",
            'download': "10",
            'activated_on': now.year.toString() +
                "/" +
                now.month.toString() +
                "/" +
                now.day.toString(),
          });
          c.showInSnackBar(context,
              "Congratulations, Subscription for 12 months is activated");
          setState(() {});
          c.updatedPremium(mydoc_id);
          c.updatedPlay("100000", mydoc_id);
          c.updatedDownload("10", mydoc_id);
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
            Navigator.push(
                context, CupertinoPageRoute(builder: (_) => Profile()));
          });
        } else if (mode == 'custom') {
          c.setshared("CustomPaid", "TRUE");
          Navigator.push(
              context, CupertinoPageRoute(builder: (_) => CustomRequest()));
        }
      }).onError((error, stackTrace) {
        print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
        // dynamicSnackBar(
        //   context: context,
        //   text: error.toString(),
        //   isErrorMsg: true,
        //   isSucessMsg: false,
        // );
      });
    } on StripeException catch (e) {
      print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

//  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': (
            // addToCartProvider!.getTotalPrice().toStringAsFixed(0).toString()),
            amount.toString()),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                'Bearer sk_test_51IpelUA14Rd2Y1TvsDvAl9xyvJUkSaaLatSEkqTfokoSacKZAPKNbeNFzh08KE9MGfkCfaVbOo5Fy84LM6SdH39Q00FXTln0az',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  // calculateAmount(String amount) {
  //   final a = (int.parse(amount)) * 100;
  //   // final a = int.parse(amount);
  //   return a.toString();
  // }
}
