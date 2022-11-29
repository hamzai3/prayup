import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:terry/audio_player.dart';
import 'package:terry/audio_player_offline.dart';
import 'package:terry/bottomNav.dart';
import 'package:terry/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

class MyDownloads extends StatefulWidget {
  final playlist;
  const MyDownloads({super.key, this.playlist});

  @override
  State<MyDownloads> createState() => _MyDownloadsState();
}

class _MyDownloadsState extends State<MyDownloads> {
  TextEditingController keyword = TextEditingController();
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

  List temp_data = [];
  int _current = 0;
  List sliderCount = [0, 1, 2, 3, 4];
  Constants c = Constants();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('prayers');
  var allData, playlistData;
  bool isLoading = true, noData = false;

  Random random = new Random();
  var username;
  @override
  void initState() {
    super.initState();
    c.getshared("UserName").then((value) {
      setState(() {
        print("Username $username");
        if (value != 'null') {
          username = value;
        } else {
          username = "Guest";
        }
      });
    });
    c.getshared("downlaods").then((value) {
      setState(() {
        print(value);
        if (value != 'null') {
          // username = value;
          print("downlaodsa re $value");
          value = '{"downloaded":[$value]}';
          allData = json
              .decode(value.toString().replaceAll("},]}", "}]}"))['downloaded'];
          print("In all data of downlaods we have $allData");
          isLoading = false;
        } else {
          isLoading = true;

          noData = true;
        }
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.bgColor(),
      // appBar: CupertinoNavigationBar(
      //   backgroundColor: c.blackColor(),
      //   middle: Text(
      //     'My Downloads',
      //     style:
      //         TextStyle(fontSize: c.getFontSize(context), color: Colors.white),
      //   ),
      // ),
      body: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: SafeArea(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'My Downloads',
                      style: TextStyle(
                          fontSize: c.getFontSizeLarge(context) - 5,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
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
                          return 'Cannot MyDownloads nothing, enter keyword';
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
                        hintText: " Search in downloads",
                        fillColor: c.primaryColor(),
                        filled: true,
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
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : noData
                      ? Center(
                          child: Text(
                          "There are no downloaded prayers",
                          style: TextStyle(
                              fontSize: c.getFontSizeSmall(context),
                              // fontWeight: FontWeight.w800,
                              color: c.whiteColor()),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allData.length,
                          itemBuilder: (context, j) {
                            return Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.0, color: c.whiteColor()),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(20), // Image border
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(
                                        c.deviceWidth(context) *
                                            0.1), // Image radius
                                    child: Image.asset(
                                      "assets/slider/${(random.nextInt(4) + 1)}.png",
                                    ),
                                  ),
                                ),
                                title: AutoSizeText(
                                  allData[j]['allbum'],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: c.getFontSizeSmall(context),
                                      fontWeight: FontWeight.w800,
                                      color: c.getColor("grey")),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(right: 58.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
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
                                trailing: Icon(
                                  Icons.play_arrow,
                                  color: c.whiteColor(),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              AudioPlayerPageOffline(
                                                data: allData[j],
                                              )));
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
}
