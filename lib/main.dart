import 'package:flutter/material.dart';
import 'SettingsWidget.dart';

void main() => runApp(WebImageApp());

class WebImageApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WebImageAppState();
  }
}

class WebImageAppState extends State<WebImageApp> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        title: 'Widget App',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: SettingsWidget()
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}