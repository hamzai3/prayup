import 'dart:convert';
import 'dart:io';

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
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terry/profile.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  var doc_id = '';
  int _current = 0;
  List sliderCount = [0, 1, 2, 3];
  Constants c = Constants();

  DateTime now = new DateTime.now();
  var dio = Dio();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('prayers');
  var allData;
  bool isLoading = true;
  getData() async {
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    setState(() {
      allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      // print("Hey data is $allData");
      isLoading = false;
    });
    c.getshared("UserName").then((value) {
      if (value != 'null') {
        print("IUserame is $value");
        c.isUpdated(value).then((snapshot) {
          print("IUserame is $snapshot");
          if (snapshot != false) {
            setState(() {
              play = int.parse(snapshot['play'].toString());
              download = int.parse(snapshot['download'].toString());
              isPremimum = snapshot['premium'] == "NO" ? false : true;
              subscribed_on =
                  DateTime.parse(snapshot['subscribed_on'].toString());
              mon_donwload_limit =
                  int.parse(snapshot['download_limit'].toString());
              mon_play_limit = int.parse(snapshot['play_limit'].toString());
              for_days = int.parse(snapshot['for_days'].toString());
            });
          }
        });
      }
    });
    c.getshared("MyDocId").then((value) {
      if (value != 'null') {
        setState(() {
          doc_id = value;
        });
      }
    });
    print("Finally my play is $play and downlaod is $download");
  }

  var username;
  Random random = new Random();
  int play = 0, download = 0;
  late DateTime subscribed_on;
  int for_days = 0, mon_play_limit = 0, mon_donwload_limit = 0;
  @override
  void initState() {
    super.initState();
    getData();
    // getStatics();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff
      getData();
      // getStatics();
    }
  }

  // getStatics() {
  //   c.getshared("UserName").then((value) {
  //     if (value != null) {
  //       setState(() {
  //         c.getshared("FreeLeft").then((value) {
  //           if (value != 'null') {
  //             c.getshared("FreeLeft").then((value) {
  //               free = int.parse(value.toString());
  //               // if (free != 5) {}
  //             });
  //             c.getshared("FreeDownload").then((value) {
  //               print("Free left on main is $value");
  //               download = int.parse(value.toString());
  //             });
  //           } else {
  //             c.isUpdated(value).then((updated) {
  //               print("updayed resp is $updated");
  //               if (updated != null) {
  //                 if (updated == false) {
  //                   isPremimum = false;
  //                   c.setshared("FreeLeft", "5");
  //                 } else {
  //                   isPremimum = true;
  //                   print(
  //                       "updated[0]['free'] " + updated[0]['free'].toString());
  //                   c.setshared("FreeLeft", updated[0]['free']);
  //                   c.getshared("FreeLeft").then((value) {
  //                     free = int.parse(value.toString());
  //                   });

  //                   c.setshared("FreeDownload", updated[0]['download']);
  //                   c.getshared("FreeDownload").then((value) {
  //                     download = int.parse(value.toString());
  //                   });
  //                 }
  //               }
  //             });
  //           }
  //         });
  //       });
  //     }
  //     print("updated[0]['free'] " + free.toString());
  //     print("updated[0]['download'] " + download.toString());
  //   });
  // }

  showAlert(BuildContext context, amount, msg, data) {
    // set up the button
    // set up the AlertDialog
    var disp_amount = '0';
    if (amount == "999") {
      disp_amount = "9.99";
    }
    if (amount == "599") {
      disp_amount = "5.99";
    }
    AlertDialog alert = AlertDialog(
      backgroundColor: Color(0xff252525),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Download Prayer",
            style:
                TextStyle(color: c.primaryColor(), fontWeight: FontWeight.w800),
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
        "$msg",
        style: TextStyle(color: c.primaryColor()),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.35,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: c.primaryColor(),
                border: Border.all(width: 1.0, color: c.primaryColor()),
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: TextButton(
                child: Text(
                  "Upgrade Account",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.push(
                      context, CupertinoPageRoute(builder: (_) => Profile()));
                },
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.35,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: c.primaryColor(),
                border: Border.all(width: 1.0, color: c.primaryColor()),
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              child: TextButton(
                child: Text(
                  "Pay \$$disp_amount ",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop("cancel");
                  makePayment(amount: int.parse(amount.toString()), data);
                },
              ),
            ),
          ],
        ),
        Divider(),
        Divider(),
        // Container(
        //   padding: EdgeInsets.all(5),
        //   decoration: BoxDecoration(
        //     color: c.primaryColor(),
        //     border: Border.all(width: 1.0, color: c.primaryColor()),
        //     borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        //   ),
        //   child: TextButton(
        //     child: Icon,
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool isPremimum = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.blackColor(),
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: c.deviceHeight(context) * 0.27,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
                      viewportFraction: 1,
                      initialPage: 0,
                      enableInfiniteScroll: false,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 1000),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: false,
                      scrollDirection: Axis.horizontal,
                      height: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.height * 0.40
                          : MediaQuery.of(context).size.height * 0.75,
                    ),
                    items: sliderCount.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return InkWell(
                            onTap: () {
                              Future.delayed(Duration(seconds: 1), () {});
                            },
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(20), // Image border
                              child: SizedBox.fromSize(
                                size: Size.fromRadius(c.deviceWidth(context) *
                                    0.9), // Image radius
                                child: Image.asset(
                                  "assets/banner/${(i + 1)}.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              isLoading
                  ? Container()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: allData.length,
                      itemBuilder: (context, j) {
                        return Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 1.0,
                                color: allData[j]['free'] == "true"
                                    ? c.whiteColor()
                                    : c.getColor("red")),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(20), // Image border
                              child: SizedBox.fromSize(
                                size: Size.fromRadius(c.deviceWidth(context) *
                                    0.1), // Image radius
                                child: Image.asset(
                                  "assets/banner/${(random.nextInt(4) + 1)}.png",
                                ),
                              ),
                            ),
                            title: AutoSizeText(
                              allData[j]['album'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: c.getFontSizeSmall(context),
                                  fontWeight: FontWeight.w800,
                                  color: c.getColor("grey")),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(right: 28.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  allData[j]['free'] == "true"
                                      ? AutoSizeText(
                                          "Free",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize:
                                                  c.getFontSizeSmall(context),
                                              fontWeight: FontWeight.w800,
                                              color: c.getColor("green")),
                                        )
                                      : AutoSizeText(
                                          "Paid",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize:
                                                  c.getFontSizeSmall(context),
                                              fontWeight: FontWeight.w800,
                                              color: c.getColor("red")),
                                        ),
                                  AutoSizeText(
                                    allData[j]['artist'],
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize:
                                            c.getFontSizeSmall(context) - 2,
                                        fontWeight: FontWeight.w800,
                                        color: c.getColor("light_grey")),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isPremimum == false) {
                                      c.showInSnackBar(context,
                                          "Upgrade your account to download this prayer");
                                      showAlert(
                                          context,
                                          "999",
                                          "Upgrade your account to access download feature\nOr pay \$9.99 to download this prayer",
                                          allData[j]);
                                    } else {
                                      var diff = DateTime.now()
                                          .difference(subscribed_on)
                                          .inDays;
                                      if (diff <
                                          int.parse(for_days.toString())) {
                                        var limitextender = 1;
                                        for (int i = 30; i < 365; i = i + 30) {
                                          print("\n\n\ Loop now is $i");
                                          if (diff < i) {
                                            if (download >=
                                                (mon_donwload_limit *
                                                    limitextender)) {
                                              //8>7
                                              c.showInSnackBar(context,
                                                  "You have reached maximum download limit for this month");
                                              showAlert(
                                                  context,
                                                  "599",
                                                  "Maximum download limit reached!\nPay \$5.99 to download this prayer",
                                                  allData[j]);
                                              break;
                                            } else {
                                              //this will run
                                              c
                                                  .updatedDownload(
                                                      download + 1, doc_id)
                                                  .then((value) {
                                                c.showInSnackBar(context,
                                                    "Prayer is being downloaded and it will be saved in My Downloads");
                                                c
                                                    .download1(
                                                        dio,
                                                        allData[j]['url'],
                                                        '/' +
                                                            allData[j]['album']
                                                                .toString()
                                                                .replaceAll(
                                                                    " ", "_") +
                                                            ".mp3")
                                                    .then((value) {
                                                  print("downloaded to $value");

                                                  //  var rec = '{"downloaded":}';
                                                  var rec =
                                                      '{"url":"$value","allbum":"${(allData[j]['album'].toString())}","artist":"${(allData[j]['artist'])}","duration":"${(allData[j]['duration'])}"},';
                                                  c
                                                      .getshared("downlaods")
                                                      .then((value) {
                                                    if (value != 'null') {
                                                      value = value + rec;
                                                      c.setshared(
                                                          "downlaods", value);
                                                    } else {
                                                      c.setshared(
                                                          "downlaods", rec);
                                                    }
                                                  });
                                                  c
                                                      .getshared("downlaods")
                                                      .then((value) {
                                                    print(
                                                        "Here affter downlaodsa $value");
                                                  });

                                                  // c.setshared("Downloaded1", rec);
                                                });
                                              });
                                              break;
                                            }
                                          }
                                          limitextender += 1;
                                        }

                                        getData();
                                      }
                                    }
                                  },
                                  child: Icon(
                                    Icons.download,
                                    color: c.whiteColor(),
                                  ),
                                ),
                                allData[j]['free'] == "true"
                                    ? Icon(
                                        Icons.play_arrow,
                                        color: c.whiteColor(),
                                      )
                                    : isPremimum == true
                                        ? Icon(
                                            Icons.play_arrow,
                                            color: c.getColor("red"),
                                          )
                                        : Icon(
                                            Icons.lock,
                                            color: c.getColor("red"),
                                          ),
                              ],
                            ),
                            onTap: () {
                              allData[j]['free'] == "true"
                                  ? play_audio(allData[j])
                                  : c.showInSnackBar(context,
                                      "Upgrade your account to access paid prayers");
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(currentPage: 0),
    );
  }

  play_audio(loop_id) {
    if (isPremimum == false) {
      if (play > 0) {
        c.updatedPlay(play - 1, doc_id).then((value) {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => AudioPlayerPage(
                        data: loop_id,
                      )));
        });
      } else {
        c.showInSnackBar(context,
            "You have listen to maximum free prayers, Upgrade your account to continue");
        Future.delayed(Duration(milliseconds: 1200), () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => Profile(
                        showSheet: true,
                      )));
        });
      }
    } else {
      var diff = DateTime.now().difference(subscribed_on).inDays;
      print("Diff is $diff");
      if (diff < int.parse(for_days.toString())) {
        var limitextender = 1;
        for (int i = 30; i < 365; i = i + 30) {
          print("\n\n\ Loop now is $i");
          if (diff < i) {
            // print(play);
            // print(mon_play_limit);
            // print((mon_play_limit * limitextender));
            print(play >= (mon_play_limit * limitextender));

            if (play >= (mon_play_limit * limitextender)) {
              //8>7
              c.showInSnackBar(context,
                  "You have listen to maximum free prayers for this month");

              break;
            } else {
              //this will run
              c.updatedPlay(play + 1, doc_id).then((value) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => AudioPlayerPage(
                              data: loop_id,
                            )));
              });
              break;
            }
          }
          limitextender += 1;
        }
      }
    }
  }
  // play(dataloop) {
  //   print("Hey we have $free pray");
  //   if (free > 0) {
  //     setState(() {
  //       (free - 1);
  //     });
  //     print(free);
  //     c.getshared("FreeUserLeft").then((value) {
  //       if (value != "null") {
  //         if (int.parse(value.toString()) > 0) {
  //           c.setshared("FreeUserLeft", (free - 1).toString());
  //         }
  //       }
  //     });
  //     c.getshared("FreeLeft").then((value) {
  //       if (value != "null") {
  //         if (int.parse(value.toString()) > 0) {
  //           c.setshared("FreeLeft", (free - 1).toString());
  //         }
  //       }
  //     });

  //     c.setshared("FreeUserLeft", (free - 1).toString());
  //     Future.delayed(Duration(milliseconds: 1200), () {
  //       Navigator.push(
  //           context,
  //           CupertinoPageRoute(
  //               builder: (context) => AudioPlayerPage(
  //                     data: dataloop,
  //                   )));
  //     });
  //   } else {
  // c.showInSnackBar(context,
  //     "You have listen to maximum free prayers, upgrade your account to continue");
  // Future.delayed(Duration(milliseconds: 1200), () {
  //   Navigator.push(
  //       context, CupertinoPageRoute(builder: (context) => Profile()));
  // });
  //   }
  // }

  late Map<String, dynamic> paymentIntentData;
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

      ///now finally display payment sheeet
      displayPaymentSheet(mode);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(allData) async {
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
        print("Payment Done \n and found $allData");
        c.showInSnackBar(context,
            "Prayer is being downloaded and it will be saved in My Downloads");
        c
            .download1(dio, allData['url'],
                '/' + allData['album'].toString().replaceAll(" ", "_") + ".mp3")
            .then((value) {
          print("downloaded to $value");

          //  var rec = '{"downloaded":}';
          var rec =
              '{"url":"$value","allbum":"${(allData['album'].toString())}","artist":"${(allData['artist'])}","duration":"${(allData['duration'])}"},';
          c.getshared("downlaods").then((value) {
            if (value != 'null') {
              value = value + rec;
              c.setshared("downlaods", value);
            } else {
              c.setshared("downlaods", rec);
            }
          });
          c.getshared("downlaods").then((value) {
            print("Here affter downlaodsa $value");
          });
          // c.setshared("Downloaded1", rec);
        });
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
        'amount': amount,
        // calculateAmount(
        //     // addToCartProvider!.getTotalPrice().toStringAsFixed(0).toString()),
        //     amount.toString()),
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

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    // final a = int.parse(amount);
    return a.toString();
  }
}
