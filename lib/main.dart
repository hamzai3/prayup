import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terry/constants.dart';
import 'package:terry/home.dart';
import 'package:terry/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';

AndroidNotificationChannel channel = const AndroidNotificationChannel(
  'prayup', // id
  'prayup_by_allied', // title
  // description
  importance: Importance.high,
);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey =
  //     'pk_test_51LqJSeLJDPAQV3CJBZijW1rN1zLfpGI92p4cp2lPXwHEkcsJW5Lr5JbVqm8AN1GfnVFrIr57Sp5kOeY0xoIqAT7O00CymHtH1u';

  //! Stripe
  Stripe.publishableKey =
      "pk_test_51IpelUA14Rd2Y1Tv4pkvVmSAius5o0rtaMY8JTLTqZbN1dfflfRvg43iGYhmr4wTdw8RFM2bTfgIqtdcQ8pvthVB00GjFqS5Zs";

  Stripe.merchantIdentifier = 'merchant.prayup';
  await Firebase.initializeApp();
  await Stripe.instance.applySettings();
  await Permission.storage.request();
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(channel);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  Constants c = Constants();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pray Up',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          fontFamily: c.fontFamily(),
          radioTheme: RadioThemeData(
            // checkColor: MaterialStateProperty.all(Colors.white),
            fillColor: MaterialStateProperty.all(Colors.purple),
          )),
      // theme: ThemeData(
      //   primarySwatch: Colors.grey,
      // ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Constants c = Constants();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    c.getshared("UserName").then((value) {
      if (value != "null") {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.push(context, CupertinoPageRoute(builder: (_) => Home()));
        });
      } else {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.push(context, CupertinoPageRoute(builder: (_) => Login()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c.blackColor(opc: 0.4),
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
          child: Center(
            child: Image.asset("assets/logo.gif"),
          ),
        ));
  }
}
