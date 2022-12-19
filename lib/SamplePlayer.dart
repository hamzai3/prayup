import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terry/constants.dart';
import 'package:terry/home.dart';
import 'package:terry/playlist.dart';

class MyPlayer extends StatefulWidget {
  final data;
  MyPlayer({this.data});
  @override
  MyPlayerState createState() => MyPlayerState();
}

class MyPlayerState extends State<MyPlayer> with WidgetsBindingObserver {
  // late AudioPlayer player!;

  var _playlist;
  int _addedCount = 0;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  bool _ready = false;
  final db = FirebaseFirestore.instance;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('playlists');
  var allData, playlistData;
  int total_duration = 0;
  var username = "User";
  bool isLoading = true, noData = false;
  Constants c = Constants();

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
                                Navigator.of(context).pop("cancel");
                                print("not added to plalis2t");
                                print(playlistData.length);
                                print(widget.data['album']);
                                if (playlistData.length <= 0) {
                                  if (Navigator.canPop(context)) {
                                    // Navigator.of(context).pop("cancel");
                                  }
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
                                var exists = 0;
                                for (int p = 0; p < playlistData.length; p++) {
                                  print("playlistData[p]['prayer'] at $p");
                                  print(playlistData[p]['prayer']["t"]);
                                  if (playlistData[p]['playlist_name'] ==
                                      allData[i]['name']) {
                                    // Navigator.of(context).pop();
                                    exists++;
                                    print("Yes its here");
                                    // Navigator.pop(context);

                                  } else {
                                    exists = 0;
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
                                    break;
                                  }
                                }
                                if (exists > 0) {
                                  c.showInSnackBar(
                                      context,
                                      "Prayer is already in " +
                                          allData[i]['name'] +
                                          " playlist");
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

  @override
  void initState() {
    super.initState();
    getData();
    getPlayListData();
    _playlist = ConcatenatingAudioSource(children: [
      // Remove this audio source from the Windows and Linux version because it's not supported yet
      if (kIsWeb ||
          ![TargetPlatform.windows, TargetPlatform.linux]
                  .contains(defaultTargetPlatform) &&
              widget.data != null)
        AudioSource.uri(
          Uri.parse(widget.data['u'].toString()),
          tag: AudioMetadata(
            album: widget.data['t'].toString(),
            title: widget.data['c'].toString(),
            artwork: "assets/audio.png",
          ),
        ),
    ]);
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
    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    player!.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      // Preloading audio is not currently supported on Linux.
      await player!.setAudioSource(_playlist,
          preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux);
    } catch (e) {
      // Catch load errors: 404, invalid url...
      print("Error loading audio source: $e");
    }
    // Show a snackbar whenever reaching the end of an item in the playlist.
    player!.positionDiscontinuityStream.listen((discontinuity) {
      if (discontinuity.reason == PositionDiscontinuityReason.autoAdvance) {
        _showItemFinished(discontinuity.previousEvent.currentIndex);
      }
    });
    player!.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _showItemFinished(player!.currentIndex);
      }
    });
    player!.sequenceStream.doOnPause(() {
      setState(() {
        loaded = 'done paused';
      });
    });
    player!.sequenceStream.doOnResume(() {
      setState(() {
        loaded = 'done playi';
      });
    });
  }

  var loaded = 'fsalse';
  void _showItemFinished(int? index) {
    if (index == null) return;
    final sequence = player!.sequence;
    if (sequence == null) return;
    final source = sequence[index];
    final metadata = source.tag as AudioMetadata;
    _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text('Finished playing ${metadata.title}'),
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  void dispose() {
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    player!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      player!.stop();
    }
  }

  playAudio() {
    player!.play();
    setState(() {
      loaded = 'true';
    });
  }

  pauseAudio() {
    player!.pause();
    setState(() {
      loaded = 'false';
    });
  }

  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player!.positionStream,
          player!.bufferedPositionStream,
          player!.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        player!.stop();
                        player!.dispose();
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
              Expanded(
                child: StreamBuilder<SequenceState?>(
                  stream: player!.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if (state?.sequence.isEmpty ?? true) {
                      return const SizedBox();
                    }
                    final metadata = state!.currentSource!.tag as AudioMetadata;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                // Center(child: Image.asset(metadata.artwork)),
                                Stack(
                              alignment: Alignment(0.0, 0.0),
                              children: [
                                CircleAvatar(
                                  radius: c.deviceWidth(context) * 0.3,
                                  backgroundImage: AssetImage("assets/slider/" +
                                      c.filename(widget.data['c'].toString())),
                                  backgroundColor: Colors.transparent,
                                ),
                                StreamBuilder<PositionData>(
                                  stream: _positionDataStream,
                                  builder: (context, snapshot) {
                                    final positionData = snapshot.data;
                                    return CircularSeekBar(
                                      width: double.infinity,
                                      height: 310,
                                      progress: positionData!.position.inSeconds
                                          .toDouble(),
                                      barWidth: 8,
                                      startAngle: 45,
                                      sweepAngle: 270,
                                      strokeCap: StrokeCap.round,
                                      progressGradientColors: [
                                        // background: linear-gradient(180deg, #552198 0%, #FE2DA3 100%);
                                        Color(0xff552198),
                                        Color(0xffFE2DA3),
                                        // Colors.orange,
                                        // Colors.yellow,
                                        // Colors.green,
                                        // Colors.blue,
                                        // Colors.indigo,
                                        // Colors.purple
                                      ],
                                      innerThumbRadius: 5,
                                      innerThumbStrokeWidth: 3,
                                      innerThumbColor: Colors.white,
                                      outerThumbRadius: 5,
                                      outerThumbStrokeWidth: 10,
                                      outerThumbColor: Color(0xffFE2DA3),
                                      animation: true,
                                      interactive: true,
                                      valueNotifier: _valueNotifier,
                                      // child: Center(
                                      //   child: ValueListenableBuilder(
                                      //       valueListenable: _valueNotifier,
                                      //       builder: (_, double value, __) =>
                                      //           Column(
                                      //             mainAxisSize:
                                      //                 MainAxisSize.min,
                                      //             children: [
                                      //               Card(
                                      //                 color: Color.fromARGB(
                                      //                     90, 85, 33, 152),
                                      //                 child: Padding(
                                      //                   padding:
                                      //                       const EdgeInsets
                                      //                           .all(18.0),
                                      //                   child: Text(
                                      //                     '${value.round()}',
                                      //                     style: TextStyle(
                                      //                         fontWeight:
                                      //                             FontWeight
                                      //                                 .bold,
                                      //                         color: c
                                      //                             .whiteColor()),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           )),
                                      // ),
                                    );
                                    // SeekBar(
                                    //   duration: positionData?.duration ??
                                    //       Duration.zero,
                                    //   position: positionData?.position ??
                                    //       Duration.zero,
                                    //   bufferedPosition:
                                    //       positionData?.bufferedPosition ??
                                    //           Duration.zero,
                                    //   onChangeEnd: (newPosition) {
                                    //     player!.seek(newPosition);
                                    //   },
                                    // );
                                  },
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          metadata.album,
                          style: TextStyle(
                              fontSize: c.getFontSizeLarge(context),
                              fontWeight: FontWeight.w800,
                              color: c.whiteColor()),
                        ),
                        Text(
                          metadata.title,
                          style: TextStyle(
                              fontSize: c.getFontSizeSmall(context),
                              // fontWeight: FontWeight.w800,
                              color: c.getColor("grey")),
                        ),
                      ],
                    );
                  },
                ),
              ),
              c.getDivider(10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<SequenceState?>(
                    stream: player!.sequenceStateStream,
                    builder: (context, snapshot) => IconButton(
                      icon: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: c.buttonGradient(),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        player!.seek(
                            Duration(seconds: player!.position.inSeconds - 10));
                      },
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                    stream: player!.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;
                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return Container(
                          margin: const EdgeInsets.all(8.0),
                          width: 64.0,
                          height: 64.0,
                          child: const CircularProgressIndicator(),
                        );
                      } else if (playing != true) {
                        return StatefulBuilder(builder: (context, setState) {
                          return Container(
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
                              child: IconButton(
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 64.0,
                                onPressed: playAudio,
                              ),
                            ),
                          );
                        });
                      } else if (processingState != ProcessingState.completed) {
                        return Container(
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
                            child: IconButton(
                              icon: const Icon(
                                Icons.pause,
                                color: Colors.white,
                              ),
                              iconSize: 64.0,
                              onPressed: pauseAudio,
                            ),
                          ),
                        );
                      } else {
                        return Container(
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
                            child: IconButton(
                              icon: const Icon(
                                Icons.replay,
                                color: Colors.white,
                              ),
                              iconSize: 64.0,
                              onPressed: () => player!.seek(Duration.zero,
                                  index: player!.effectiveIndices!.first),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  StreamBuilder<SequenceState?>(
                    stream: player!.sequenceStateStream,
                    builder: (context, snapshot) => IconButton(
                      icon: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: c.buttonGradient(),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        player!.seek(
                            Duration(seconds: player!.position.inSeconds + 10));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 240.0,
                child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        showModalBottomSheetCupetino();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: c.buttonGradient(),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.music_note_outlined,
                            color: c.whiteColor(),
                            size: c.deviceWidth(context) * 0.1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Add To Playlist",
                              style: TextStyle(
                                  fontSize: c.getFontSizeSmall(context),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins-Regular',
                                  color: c.whiteColor())),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AudioPlayer? player;

class ControlButtons extends StatefulWidget {
  const ControlButtons({Key? key}) : super(key: key);

  @override
  State<ControlButtons> createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // IconButton(
        //   icon: const Icon(
        //     Icons.volume_up,
        //     color: Colors.white,
        //   ),
        //   onPressed: () {
        //     showSliderDialog(
        //       context: context,
        //       title: "Adjust volume",
        //       divisions: 10,
        //       min: 0.0,
        //       max: 1.0,
        //       value: player.volume,
        //       stream: player.volumeStream,
        //       onChanged: player.setVolume,
        //     );
        //   },
        // ),

        // StreamBuilder<double>(
        //   stream: player.speedStream,
        //   builder: (context, snapshot) => IconButton(
        //     icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
        //         style: const TextStyle(
        //           fontWeight: FontWeight.bold,
        //           color: Colors.white,
        //         )),
        //     onPressed: () {
        //       showSliderDialog(
        //         context: context,
        //         title: "Adjust speed",
        //         divisions: 10,
        //         min: 0.5,
        //         max: 1.5,
        //         value: player.speed,
        //         stream: player.speedStream,
        //         onChanged: player.setSpeed,
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

class AudioMetadata {
  final String album;
  final String title;
  final String artwork;

  AudioMetadata({
    required this.album,
    required this.title,
    required this.artwork,
  });
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.purple.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
            RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                    .firstMatch("$_remaining")
                    ?.group(1) ??
                '$_remaining',
            style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins-Regular',
                // fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  // TODO: Replace these two by ValueStream.
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

T? ambiguate<T>(T? value) => value;
