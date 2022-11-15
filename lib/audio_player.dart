import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:terry/constants.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:terry/home.dart';
import 'package:terry/playlist.dart';

// typedef OnError = void Function(Exception exception);
late var audio_url;

class AudioPlayerPage extends StatefulWidget {
  final data;
  AudioPlayerPage({this.data});
  // const AudioPlayerPage({Key? key}) : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer player;
  bool _ready = false;
  late AudioPlayerManager manager;
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('playlists');
  var allData, playlistData;
  int total_duration = 0;
  bool isLoading = true, noData = false;
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

  getPlayListData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('playlists_prayers').get();
    // Get data from docs and convert map to List
    setState(() {
      playlistData = querySnapshot.docs.map((doc) => doc.data()).toList();
      print(playlistData);
      if (playlistData.length > 0) {
        for (int i = 0; i < playlistData.length; i++) {
          if (playlistData[i]['email'] != username) {
            playlistData.removeAt(i);
          }
        }
        print("final playlist data is $playlistData");
      }
    });
  }

  void showModalBottomSheetCupetino() async {
    await showCupertinoModalBottomSheet(
      useRootNavigator: true,
      context: context,
      bounce: true,
      isDismissible: true,
      expand: true,
      builder: (context) => Material(
        color: c.primaryColor(),
        child: Center(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            shrinkWrap: true,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    "Select Playlist",
                    style: TextStyle(
                        fontSize: c.getFontSizeLabel(context),
                        color: Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                        fontFamily: c.fontFamily()),
                  ),
                ],
              ),
              (allData).length <= 0
                  ? ListTile(
                      title: Text.rich(
                        TextSpan(
                          style: TextStyle(
                              fontSize: c.getFontSizeLabel(context),
                              fontFamily: c.fontFamily()),
                          children: [
                            TextSpan(
                              text: "There are no playlists",
                              style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context) - 3,
                                  color: Colors.black.withOpacity(0.5),
                                  fontFamily: c.fontFamily()),
                            ),
                            TextSpan(
                              text: 'Create new Playlist',
                              style: TextStyle(
                                  fontSize: c.getFontSizeLabel(context) - 3,
                                  color: c.primaryColor(),
                                  fontFamily: c.fontFamily()),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (_) => PlayList()));
                      },
                    )
                  : SizedBox(
                      height: c.deviceHeight(context) * 0.8,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: 10),
                        itemCount: (allData).length,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: const Color(0xff6B5A00),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              title: Text(
                                c.capitalize(allData[i]['name']),
                                style: TextStyle(
                                    fontSize: c.getFontSizeLabel(context) - 3,
                                    color: Colors.white,
                                    fontFamily: c.fontFamily()),
                              ),
                              trailing: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              onTap: () {
                                print("not added to plalis2t");
                                print(playlistData.length);
                                print(widget.data['album']);
                                if (playlistData.length <= 0) {
                                  Navigator.pop(context);
                                  c.showInSnackBar(
                                      context,
                                      "Prayer added to " +
                                          allData[i]['name'] +
                                          " playlist");
                                  FirebaseFirestore.instance
                                      .collection('playlists_prayers')
                                      .add({
                                    'playlist_name': allData[i]['name'],
                                    'email': username,
                                    'prayer': widget.data
                                  });
                                }
                                for (int p = 0; p < playlistData.length; p++) {
                                  print("playlistData[p]['prayer'] at $p");
                                  print(playlistData[p]['prayer']["album"]);
                                  if (playlistData[p]['playlist_name'] ==
                                      allData[i]['name']) {
                                    // Navigator.of(context).pop();
                                    print("Yes its here");
                                    Navigator.pop(context);
                                    c.showInSnackBar(
                                        context,
                                        "Prayer is already in " +
                                            allData[i]['name'] +
                                            " playlist");
                                  } else {
                                    Navigator.pop(context);
                                    c.showInSnackBar(
                                        context,
                                        "Prayer added to " +
                                            allData[i]['name'] +
                                            " playlist");
                                    FirebaseFirestore.instance
                                        .collection('playlists_prayers')
                                        .add({
                                      'playlist_name': allData[i]['name'],
                                      'email': username,
                                      'prayer': widget.data
                                    });
                                  }
                                }
                                // if (playlistData.length <= 0) {
                                //   print("added to plalist");
                                //   Navigator.of(context).pop();
                                //   c.showInSnackBar(
                                //       context,
                                //       "Added to playlist " +
                                //           allData[i]['name']);
                                //   FirebaseFirestore.instance
                                //       .collection('playlists_prayers')
                                //       .add({
                                //     'playlist_name': allData[i]['name'],
                                //     'email': username,
                                //     'prayer': widget.data
                                //   });
                                // } else {
                                //   for (int p = 0;
                                //       p < playlistData.length;
                                //       p++) {
                                //     print("not added to plalis$p t");
                                //     if (playlistData[p]['playlist_name'] ==
                                //         allData[i]['name']) {
                                //       if (playlistData[p]['prayer']["album"] ==
                                //           widget.data['album']) {
                                //         print("not added to plalist");
                                //         Navigator.of(context).pop();
                                //         c.showInSnackBar(
                                //             context,
                                //             "Prayer is already in " +
                                //                 allData[i]['name'] +
                                //                 " playlist");
                                //       } else {
                                //         print("added to plalist");
                                //         Navigator.of(context).pop();
                                //         c.showInSnackBar(
                                //             context,
                                //             "Added to playlist " +
                                //                 allData[i]['name']);
                                // FirebaseFirestore.instance
                                //     .collection('playlists_prayers')
                                //     .add({
                                //   'playlist_name': allData[i]['name'],
                                //   'email': username,
                                //   'prayer': widget.data
                                // });
                                //       }
                                //     }
                                //   }
                                // }
                              },
                            ),
                          );
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  var username = "User";
  @override
  void initState() {
    super.initState();
    getData();
    getPlayListData();
    player = AudioPlayer();
    player.setLoopMode(LoopMode.one);
    setState(() {
      audio_url = widget.data['url'];
    });
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
    player.setUrl(widget.data['url']).then((_) {
      if (mounted)
        setState(() {
          _ready = true;
          total_duration =
              Duration(seconds: int.parse(widget.data['duration'].toString()))
                  .inMinutes;
        });
    });
    print("Duration for audio");
    print(widget.data['duration']);
    player.bufferedPositionStream.listen((event) {
      print(event.inMinutes.toString() + "Okay");
    });
    player.durationStream.listen((event) {
      print("PLayback");
      print(event!.inSeconds.toString());
      setState(() {});
    }, onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    loop();
  }

  loop() {
    setState(() {});
    Future.delayed(Duration(milliseconds: 900), () {
      player.playing ? loop() : doop();
    });
  }

  doop() {}

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  Future<bool> _exitApp(BuildContext context) async {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Home()));
    return Future.value(false);
  }

  var playerDuration = 0.0;
  Constants c = Constants();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
          backgroundColor: c.blackColor(),
          body: Container(
            child: Padding(
              padding: EdgeInsets.all(c.deviceWidth(context) * 0.01),
              child: !_ready
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (_) => Home()));
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_sharp,
                                  color: c.whiteColor(),
                                ),
                              )
                            ],
                          ),
                        ),
                        c.getDivider(c.deviceHeight(context) * 0.06),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20), // Image border
                          child: SizedBox.fromSize(
                            size: Size.fromRadius(
                                c.deviceWidth(context) * 0.4), // Image radius
                            child: Image.asset(
                              "assets/audio.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              widget.data['album'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: c.getFontSizeLarge(context),
                                  fontWeight: FontWeight.w800,
                                  color: c.whiteColor()),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              widget.data['artist'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: c.getFontSizeSmall(context),
                                  // fontWeight: FontWeight.w800,
                                  color: c.getColor("grey")),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SfSlider(
                                min: 0.0,
                                activeColor: c.primaryColor(),
                                max: double.parse(
                                    player.duration!.inSeconds.toString()),
                                value: player.position.inSeconds,
                                interval: 0.01,
                                enableTooltip: true,
                                minorTicksPerInterval: 1,
                                onChanged: (dynamic value) async {
                                  setState(() {
                                    player.seek(Duration(
                                        minutes: int.parse(
                                            double.parse(value.toString())
                                                .ceil()
                                                .toString())));
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("00:" + player.position.inSeconds.toString(),
                                  style: TextStyle(
                                      fontSize: c.getFontSizeSmall(context),
                                      fontWeight: FontWeight.w800,
                                      color: c.getColor("grey"))),
                              Text("$total_duration".toString() + ":00",
                                  style: TextStyle(
                                      fontSize: c.getFontSizeSmall(context),
                                      fontWeight: FontWeight.w800,
                                      color: c.getColor("grey")))
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  player.seek(Duration(
                                      minutes: int.parse((double.parse(player
                                                      .position.inMinutes
                                                      .toString())
                                                  .ceil() -
                                              10)
                                          .toString())));
                                  setState(() {});
                                });
                              },
                              child: Icon(
                                Icons.rotate_90_degrees_ccw_outlined,
                                color: c.whiteColor(),
                                size: c.deviceWidth(context) * 0.1,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  loop();
                                  !player.playing
                                      ? player.play()
                                      : player.pause();
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: c.primaryColor(),
                                  shape: BoxShape.circle,
                                  // border: Border.all(width: 3.0),
                                  // borderRadius: BorderRadius.all(Radius.circular(
                                  //         5.0) //                 <--- border radius here
                                  // ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    !player.playing
                                        ? Icons.play_arrow
                                        : Icons.pause,
                                    color: c.blackColor(),
                                    size: c.deviceWidth(context) * 0.2,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  player.seek(Duration(
                                      seconds: int.parse((double.parse(player
                                                      .position.inSeconds
                                                      .toString())
                                                  .ceil() +
                                              10)
                                          .toString())));
                                  setState(() {});
                                });
                              },
                              child: Icon(
                                Icons.rotate_90_degrees_cw_outlined,
                                color: c.whiteColor(),
                                size: c.deviceWidth(context) * 0.1,
                              ),
                            )
                          ],
                        ),
                        c.getDivider(c.deviceHeight(context) * 0.06),
                        GestureDetector(
                            onTap: () async {
                              setState(() {
                                showModalBottomSheetCupetino();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.playlist_add,
                                    color: c.primaryColor(),
                                    size: c.deviceWidth(context) * 0.1,
                                  ),
                                ),
                                Text("Add To Playlist",
                                    style: TextStyle(
                                        fontSize: c.getFontSizeSmall(context),
                                        fontWeight: FontWeight.w800,
                                        color: c.getColor("grey"))),
                              ],
                            )),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AudioPlayerManager {
  final player = AudioPlayer();
  Stream<DurationState>? durationState;

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
        (position, playbackEvent) => DurationState(
              progress: position,
              buffered: playbackEvent.bufferedPosition,
              total: playbackEvent.duration,
            ));
    player.setUrl(audio_url);
  }

  void dispose() {
    player.dispose();
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
