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

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:terry/search.dart';
import 'package:terry/searchPrayer.dart';

class PlayList extends StatefulWidget {
  const PlayList({super.key});

  @override
  State<PlayList> createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
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
  Constants c = Constants();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('playlists');
  var allData;
  bool isLoading = true, noData = false;

  var username = "User";
  getData() async {
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List
    setState(() {
      allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      print(allData);

      if (allData.length > 0) {
        for (int i = 0; i < allData.length; i++) {
          if (allData[i]['email'] != username) {
            allData.removeAt(i);
          }
        }
        isLoading = false;
      } else {
        isLoading = false;
        noData = true;
      }
      isLoading = false;
    });
  }

  Random random = new Random();

  void showModalBottomSheetCupetino() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create Playlist'),
            content: TextField(
              // controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Playlist name"),
              onSubmitted: (s) {
                FirebaseFirestore.instance.collection('playlists').add({
                  'email': username.toString(),
                  'name': s.toString()
                }).then((value) {
                  Navigator.pop(context);
                  getData();
                });
              },
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getData();
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
      backgroundColor: c.blackColor(),
      appBar: CupertinoNavigationBar(
        backgroundColor: c.blackColor(),
        middle: Text(
          'PlayList',
          style:
              TextStyle(fontSize: c.getFontSize(context), color: Colors.white),
        ),
      ),
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
                          return 'Cannot PlayList nothing, enter keyword';
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
                              print(temp_data[d]['name'].toString());
                              print(s.toString());
                              if (s.toString() == 'All' ||
                                  s.toString() == 'Select Category') {
                                allData.add(temp_data[d]);
                              } else if (temp_data[d]['name']
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
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        hintText: " Search Playlist",
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
                  : noData
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "No Playlist",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allData.length,
                          itemBuilder: (context, j) {
                            return Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1.0, color: c.primaryColor()),
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
                                  c.capitalize(allData[j]['name']),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: c.getFontSizeSmall(context),
                                      fontWeight: FontWeight.w800,
                                      color: c.getColor("grey")),
                                ),
                                trailing: Icon(
                                  Icons.play_arrow,
                                  color: c.whiteColor(),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) => SearchPrayer(
                                                playlist: allData[j]['name'],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: c.primaryColor(),
          onPressed: () {
            showModalBottomSheetCupetino();
          },
          label: Text("Create New Playlst")),
    );
  }
}
