import 'dart:async';

import 'package:flutter/material.dart';
import 'package:images_fetcher/utils.dart';
import 'ImageCardWidget.dart';

import 'package:images_fetcher/preferences.dart';

class SettingsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  var isLoading = false;
  List<ImageCardWidget> imagesWidgets = [];
  List<String> imagesIds = [];
  final StreamController ctrl = StreamController.broadcast();

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Web Images'),
        ),
        persistentFooterButtons: [
          FloatingActionButton(
            onPressed: refreshImages,
            backgroundColor: Colors.amber,
            child: Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: pushImage,
            child: Icon(Icons.plus_one),
          )
        ],
        body: ListView(
          children: List<ImageCardWidget>.from(
              imagesIds
                .where((key) => key.isNotEmpty)
                .map((key) {
                  print('Create widget $key');
                  return ImageCardWidget(
                      preferencesKey: key,
                      refreshStream: ctrl,
                  );
                })
          ),
        )
    );
  }

  @override
  initState() {
    super.initState();
  }

  @override
  deactivate() {
    ctrl.close();
    super.deactivate();
  }

  refreshImages() {
    print('Fetching all images');
    this.imagesWidgets.forEach((ImageCardWidget widget) {
      print('Fetch ${widget.preferencesKey}');
      ctrl.sink.add(true);
    });
  }

  pushImage() {
    final String name = Utils.createRandomString(10);
    final widget = ImageCardWidget(preferencesKey: name,);

    setState(() {
      imagesIds.add(name);
      this.imagesWidgets.add(widget);
    });

    print('Added ${widget.preferencesKey}');
  }

}