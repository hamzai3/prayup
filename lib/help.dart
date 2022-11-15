import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:terry/constants.dart';
import 'package:terry/home.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Constants c = new Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.blackColor(),
      body: Column(
        children: [
          Image.asset(
            "assets/intro.gif",
            height: c.deviceHeight(context) * 0.92,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.push(
                  context, CupertinoPageRoute(builder: (_) => Home()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Skip   ",
                    style: TextStyle(
                        fontSize: c.getFontSizeLabel(context),
                        color: c.primaryColor()),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
