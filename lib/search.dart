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
import 'home.dart';

class Search extends StatefulWidget {
  final playlist;
  const Search({super.key, this.playlist});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
  getData() async {
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    setState(() {
      allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      // print("Hey data is $allData");
      isLoading = false;
    });
    print(allData[0]);
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

  Random random = new Random();
  var username;
  @override
  void initState() {
    super.initState();

    if (widget.playlist != null) {
      getPlayListData();
    } else {
      getData();
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.primaryColor(),
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
                        hintText: widget.playlist != null
                            ? "Search Prayer"
                            : "Search",
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
                  : allData.length <= 0
                      ? Center(
                          child: Text(
                          "No Prayers added",
                          style: TextStyle(
                              fontSize: c.getFontSizeSmall(context),
                              fontWeight: FontWeight.w800,
                              color: c.whiteColor()),
                        ))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allData.length,
                          itemBuilder: (context, j) {
                            return allData[j]['free'] != "true"
                                ? Container()
                                : Container(
                                    margin: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.0,
                                          color: allData[j]['free'] == "true"
                                              ? c.whiteColor()
                                              : c.getColor("red")),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20.0)),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            20), // Image border
                                        child: SizedBox.fromSize(
                                          size: Size.fromRadius(
                                              c.deviceWidth(context) *
                                                  0.1), // Image radius
                                          child: Image.asset(
                                            "assets/slider/" +
                                                c.filename(allData[j]['album']
                                                    .toString()),
                                          ),
                                        ),
                                      ),
                                      title: AutoSizeText(
                                        allData[j]['album'],
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize:
                                                c.getFontSizeSmall(context),
                                            fontWeight: FontWeight.w800,
                                            color: c.getColor("grey")),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 58.0),
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
                                                            c.getFontSizeSmall(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: c
                                                            .getColor("green")),
                                                  )
                                                : AutoSizeText(
                                                    "Paid",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize:
                                                            c.getFontSizeSmall(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            c.getColor("red")),
                                                  ),
                                            AutoSizeText(
                                              allData[j]['artist'],
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: c.getFontSizeSmall(
                                                          context) -
                                                      2,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      c.getColor("light_grey")),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: c.primaryColor()),
                                        child: allData[j]['free'] == "true"
                                            ? Icon(
                                                Icons.play_arrow,
                                                color: c.getPink(),
                                              )
                                            : Icon(
                                                Icons.play_arrow,
                                                color: c.getPink(),
                                              ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    AudioPlayerPage(
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
