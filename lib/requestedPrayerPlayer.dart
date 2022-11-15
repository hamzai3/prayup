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
import 'package:terry/playlist.dart';

// typedef OnError = void Function(Exception exception);
late var audio_url;

class RequestedPlayerPageOffline extends StatefulWidget {
  final data;
  RequestedPlayerPageOffline({this.data});
  // const RequestedPlayerPageOffline({Key? key}) : super(key: key);

  @override
  _RequestedPlayerPageOfflineState createState() =>
      _RequestedPlayerPageOfflineState();
}

class _RequestedPlayerPageOfflineState
    extends State<RequestedPlayerPageOffline> {
  late AudioPlayer player;
  bool _ready = false;
  late AudioPlayerManager manager;
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('playlists');
  var allData, playlistData;
  int total_duration = 0;
  bool isLoading = true, noData = false;

  var username = "User";
  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setLoopMode(LoopMode.one);
    setState(() {
      audio_url = widget.data['file'];
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
    print("We got eidget object");
    print(widget.data['file']);
    player.setUrl(widget.data['file']).then((_) {
      if (mounted)
        setState(() {
          _ready = true;
          total_duration =
              Duration(seconds: int.parse(widget.data['duration'].toString()))
                  .inMinutes;
          isLoading = false;
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
    // loop();
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
                                Navigator.of(context).pop();
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
                        borderRadius: BorderRadius.circular(20), // Image border
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
                            widget.data['prayer_name'],
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
                              min: 0.00,
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
                            Text(player.position.inMinutes.toString() + ":00",
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
                                            1)
                                        .toString())));
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
                                // player.seek(Duration(minutes: 1));
                                player.seek(Duration(
                                    seconds: int.parse((double.parse(player
                                                    .position.inSeconds
                                                    .toString())
                                                .ceil() +
                                            1)
                                        .toString())));
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
