import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class Constants {
  fontFamily({type = "regular"}) {
    return type == 'regular' ? 'Poppins-Regular' : 'Poppins-SemiBold';
  }

  deviceWidth(context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
  }

  deviceHeight(context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
  }

  redColor() {
    return Color(0xC4F04444);
  }

  primaryColor() {
    return const Color(0xff552198);
  }

  secondaryColor() {
    return const Color(0xffF42B5B);
  }

  tertiaryColor() {
    return const Color(0xffB9B9B9);
  }

  capitalize(str) {
    return "${str[0].toUpperCase()}${str.substring(1)}";
  }

  whiteColor() {
    return const Color(0xffffffff);
  }

  blackColor({opc = 1.0}) {
    return const Color(0xff0B0C0E).withOpacity(opc);
  }

  containerGradient() {
    return LinearGradient(
        colors: [
          const Color(0xFF280F48),
          const Color(0xFF51002E),
          // linear-gradient(180deg, #280F48 0%, #51002E 100%)
        ],
        begin: const FractionalOffset(2.0, 0.0),
        end: const FractionalOffset(0.0, 5.0),
        stops: [0.0, 2.0],
        tileMode: TileMode.clamp);
  }

  buttonGradient() {
    return LinearGradient(
        colors: [
          const Color(0xFF552198),
          const Color(0xFF720041),
          //inear-gradient(180deg, #552198 0%, #720041 100%)
        ],
        begin: const FractionalOffset(1.0, 0.0),
        end: const FractionalOffset(1.0, 1.0),
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp);
  }

  backgroundColor() {
    return const Color(0xff808080);
  }

  bgColor() {
    return const Color(0xff170A27);
  }

  getFontSizeMedium(context) {
    return deviceHeight(context) * 0.018;
  }

  getFontSize(context) {
    return deviceHeight(context) * 0.018;
  }

  getFontSizeSmall(context) {
    return deviceHeight(context) * 0.02;
  }

  getFontSizeXS(context) {
    return deviceHeight(context) * 0.017;
  }

  getFontSizeLabel(context) {
    return deviceHeight(context) * 0.021;
  }

  getFontSizeLarge(context) {
    return deviceHeight(context) * 0.035;
  }

  filename(str) {
    // print("\n\n$str\nn");
    if (str.toString().toLowerCase().contains("birthday")) {
      return 'birthday.png';
    } else if (str.toString().toLowerCase().contains("church")) {
      return 'church.png';
    } else if (str.toString().toLowerCase().contains("faith")) {
      return 'faith.png';
    } else if (str.toString().toLowerCase().contains("family")) {
      return 'family.png';
    } else if (str.toString().toLowerCase().contains("healing")) {
      return 'healing.png';
    } else if (str.toString().toLowerCase().contains("health")) {
      return 'health.png';
    } else if (str.toString().toLowerCase().contains("home")) {
      return 'home.png';
    } else if (str.toString().toLowerCase().contains("husband")) {
      return 'husband.png';
    } else if (str.toString().toLowerCase().contains("marriage")) {
      return 'marriage.png';
    } else if (str.toString().toLowerCase().contains("pastor")) {
      return 'pastor.png';
    } else if (str.toString().toLowerCase().contains("promotion")) {
      return 'promotion.png';
    } else if (str.toString().toLowerCase().contains("son")) {
      return 'son.png';
    } else if (str.toString().toLowerCase().contains("studies")) {
      return 'studies.png';
    } else if (str.toString().toLowerCase().contains("wife")) {
      return 'wife.png';
    } else {
      return 'faith.png';
    }
  }

  getColor(str) {
    if (str == 'green') {
      return Colors.green;
    } else if (str == 'red') {
      return Colors.red;
    } else if (str == 'yellow') {
      return Colors.yellow;
    } else if (str == 'blue') {
      return Colors.blue;
    } else if (str == 'orange') {
      return Colors.orange;
    } else if (str == 'pink') {
      return Colors.pink;
    } else if (str == 'grey') {
      return const Color(0xffBDBDBD);
    } else if (str == 'light_grey') {
      return Color(0xFFE0DADA);
    } else if (str == 'black') {
      return const Color(0xff252525);
    } else if (str == 'light_black') {
      return const Color(0xff808080);
    } else if (str == 'light_blue') {
      return const Color(0xffDAF1FF);
    } else if (str == 'dark_blue') {
      return const Color(0xff407BFF);
    }
  }

  getURL() {
    return 'https://prayup.alliedtechnologies.co/';
  }

  getPink() {
    return const Color(0xffFE2DA3);
  }

  getAppBar(title, context, {transition = false}) {
    return CupertinoNavigationBar(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),

      // backgroundColor:  getBrownColor(),
      // actionsForegroundColor: getWhit  eColor(),
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,

      transitionBetweenRoutes: transition,

      middle: Text(
        title,
        style: TextStyle(
            fontFamily: fontFamily(),
            letterSpacing: 1.1,
            color: Colors.black,
            // fontWeight: FontWeight.bold,
            fontSize: getFontSizeSmall(context)),
      ),
    );
  }

  getDivider(height) {
    return Divider(
      height: height,
      color: Colors.transparent,
    );
  }

  showInSnackBar(context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future download1(Dio dio, String url, savePath) async {
    getshared("FreeDownload").then((value) {
      setshared("FreeDownload", (int.parse(value) - 1).toString());
      // setshared("FreeDownload", (2).toString());
    });
    Directory appDocDir = await getTemporaryDirectory();
    String appDocPath = appDocDir.path + savePath;
    var cancelToken = CancelToken();
    try {
      await dio.download(
        url,
        appDocPath,
        onReceiveProgress: showDownloadProgress,
        cancelToken: cancelToken,
      );
      return appDocPath;
    } catch (e) {
      print(e);
    }
  }

  Future isUpdated(useremail) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List

    List allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (int s = 0; s < allData.length; s++) {
      if (allData[s]['email'] == useremail) {
        return allData[s];
      }
    }
    return false;
  }

  Future updatedPlay(count, mydoc_id) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    // QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List

    await _collectionRef
        .doc(mydoc_id)
        .update({'play': count}); // <-- Updated data
    return false;
  }

  Future updatedRecord(count, node, mydoc_id) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    // QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List

    await _collectionRef
        .doc(mydoc_id)
        .update({node: count}); // <-- Updated data
    return false;
  }

  Future updatedPremium(mydoc_id) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    // QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List

    await _collectionRef
        .doc(mydoc_id)
        .update({'premium': "YES"}); // <-- Updated data
    return false;
  }

  Future updatedDownload(count, mydoc_id) async {
    CollectionReference _collectionRef =
        FirebaseFirestore.instance.collection('users');
    // QuerySnapshot querySnapshot = await _collectionRef.get();
    // Get data from docs and convert map to List

    await _collectionRef
        .doc(mydoc_id)
        .update({'download': count}); // <-- Updated data
    return false;
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  Future<bool> setshared(String name, String value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(name, value);
    return true;
  }

  Future<String> getshared(String skey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(skey).toString();
  }

  Future clearShared() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
