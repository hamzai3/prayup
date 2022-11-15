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
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terry/profile.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class SearchPrayer extends StatefulWidget {
  final playlist;
  const SearchPrayer({super.key, this.playlist});

  @override
  State<SearchPrayer> createState() => _SearchPrayerState();
}

class _SearchPrayerState extends State<SearchPrayer> {
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
  List sliderCount = [0, 1, 2, 3, 4];
  Constants c = Constants();

  DateTime now = new DateTime.now();
  var dio = Dio();
  List temp_data = [];
  TextEditingController keyword = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('prayers');
  var allData, playlistData;
  bool isLoading = true, noData = false;
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

  getPlayListData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('playlists_prayers').get();
    // Get data from docs and convert map to List
    setState(() {
      allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      var temp = [];
      print(allData);
      if (allData.length > 0) {
        for (int i = 0; i < allData.length; i++) {
          if (allData[i]['email'] != username) {
            allData.removeAt(i);
          } else {
            if (allData[i]['playlist_name'] == widget.playlist) {
              temp.add(allData[i]['prayer']);
            }
          }
        }
        allData = temp;
        print(allData.length);
        if (allData.length > 0) {
          noData = true;
        }
        isLoading = false;
        print("final playlist data is $allData");
      } else {
        noData = true;
      }
    });
  }

  var username;
  Random random = new Random();
  int play = 0, download = 0;
  @override
  void initState() {
    super.initState();
    if (widget.playlist != null) {
      getPlayListData();
    } else {
      getData();
    }
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
              ListTile(
                title: Padding(
                  padding: EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: SizedBox(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Cannot search nothing, enter keyword';
                        }
                      },
                      controller: keyword,
                      autocorrect: true,
                      style: TextStyle(
                          fontSize: c.getFontSize(context),
                          color: Colors.white),
                      onChanged: (s) {
                        setState(() {
                          if (s.isNotEmpty) {
                            if (temp_data.isEmpty) {
                              temp_data = allData;
                            }
                            allData = [];
                            for (int d = 0; d < temp_data.length; d++) {
                              print(temp_data[d]['album'].toString());
                              print(s.toString());
                              if (s.toString() == 'All' ||
                                  s.toString() == 'Select Category') {
                                allData.add(temp_data[d]);
                              } else if (temp_data[d]['album']
                                  .toString()
                                  .toLowerCase()
                                  .contains(s.toString().toLowerCase())) {
                                allData.add(temp_data[d]);
                              }
                            }
                          } else {
                            allData = temp_data;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: c.whiteColor()),
                        hintText: " Search",
                        hintStyle: TextStyle(
                            fontSize: c.getFontSize(context),
                            color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: c.whiteColor(), width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              style: BorderStyle.none, color: c.whiteColor()),
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
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
                                  "assets/slider/${(random.nextInt(4) + 1)}.png",
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
                                      print("DSonloads is $download");
                                      if (download > 0) {
                                        c.showInSnackBar(context,
                                            "Prayer is being downloaded and it will be saved in My Downloads");
                                        c
                                            .download1(
                                                dio,
                                                allData[j]['url'],
                                                '/' +
                                                    allData[j]['album']
                                                        .toString()
                                                        .replaceAll(" ", "_") +
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
                                              c.setshared("downlaods", value);
                                            } else {
                                              c.setshared("downlaods", rec);
                                            }
                                          });
                                          c
                                              .getshared("downlaods")
                                              .then((value) {
                                            print(
                                                "Here affter downlaodsa $value");
                                          });
                                          c.updatedDownload(
                                              download - 1, doc_id);

                                          // c.setshared("Downloaded1", rec);
                                        });
                                      } else {
                                        c.showInSnackBar(context,
                                            "You have reached maximum download limit");
                                        showAlert(
                                            context,
                                            "599",
                                            "You have reached maximum download limit\nOr pay \$5.99 to download this prayer",
                                            allData[j]);
                                      }
                                      // getStatics();
                                      getData();
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
      bottomNavigationBar: BottomNav(currentPage: 1),
    );
  }

  play_audio(loop_id) {
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
