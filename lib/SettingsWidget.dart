import 'package:flutter/material.dart';
import 'ImageCardWidget.dart';

class SettingsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  var isLoading = false;

  @override
  Scaffold build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Web Images'),
        ),
        persistentFooterButtons: [
          FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.plus_one),
          )
        ],
        body: ListView(
          children: ['webImage', 'w1', 'w2'].map((key) {
            return Container(
              height: 400.0,
              child: ImageCardWidget(
                preferencesKey: key
              )
            );
          }).toList(),
        )
    );
  }

  @override
  initState() {
    super.initState();


  }



}