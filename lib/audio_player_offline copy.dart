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

class AudioPlayerPageOffline extends StatefulWidget {
  final data;
  AudioPlayerPageOffline({this.data});
  // const AudioPlayerPageOffline({Key? key}) : super(key: key);

  @override
  _AudioPlayerPageOfflineState createState() => _AudioPlayerPageOfflineState();
}

class _AudioPlayerPageOfflineState extends State<AudioPlayerPageOffline> {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Playlist",
                    style: TextStyle(
                        fontSize: c.getFontSizeLabel(context),
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                        fontFamily: c.fontFamily()),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop("cancel");
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
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
                                  color: Colors.white.withOpacity(0.5),
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
                              color: c.getPink(),
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
    player.setFilePath(widget.data['url']).then((_) {
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

  var playerDuration = 0.0;
  Constants c = Constants();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: c.blackColor(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  const Color(0xFF280F48),
                  const Color(0xFF51002E),
                  // linear-gradient(180deg, #280F48 0%, #51002E 100%)
                ],
                begin: const FractionalOffset(1.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
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
                                Navigator.push(context,
                                    CupertinoPageRoute(builder: (_) => Home()));
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: c.getPink(),
                              ),
                            )
                          ],
                        ),
                      ),
                      // c.getDivider(c.deviceHeight(context) * 0.06),
                      Stack(
                        alignment: Alignment(0.0, 0.0),
                        children: [
                          CircleAvatar(
                            radius: c.deviceWidth(context) * 0.3,
                            backgroundImage: AssetImage("assets/audio.png"),
                            backgroundColor: Colors.transparent,
                          ),
                          player.playing
                              ? Image.asset(
                                  "assets/player.gif",
                                  width: c.deviceWidth(context) * 0.85,
                                )
                              : Container(
                                  width: c.deviceWidth(context) * 0.85,
                                  height: c.deviceHeight(context) * 0.4,
                                )
                        ],
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
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: c.buttonGradient(),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fast_rewind_rounded,
                                color: c.whiteColor(),
                                size: c.deviceWidth(context) * 0.1,
                              ),
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
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: c.buttonGradient()),
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  !player.playing
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: c.whiteColor(),
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
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: c.buttonGradient(),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fast_forward_rounded,
                                color: c.whiteColor(),
                                size: c.deviceWidth(context) * 0.1,
                              ),
                            ),
                          )
                        ],
                      ),
                      c.getDivider(c.deviceHeight(context) * 0.06),
                      // GestureDetector(
                      //     onTap: () async {
                      //       setState(() {
                      //         showModalBottomSheetCupetino();
                      //       });
                      //     },
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: Icon(
                      //             Icons.playlist_add,
                      //             color: c.primaryColor(),
                      //             size: c.deviceWidth(context) * 0.1,
                      //           ),
                      //         ),
                      //         Text("Add To Playlist",
                      //             style: TextStyle(
                      //                 fontSize: c.getFontSizeSmall(context),
                      //                 fontWeight: FontWeight.w800,
                      //                 color: c.getColor("grey"))),
                      //       ],
                      //     )),
                    ],
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
