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
  List<String> imagesIds = [];
  final StreamController refreshBus = StreamController.broadcast();

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
            backgroundColor: Colors.teal,
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
                      refreshBus: refreshBus,
                  );
              })
          ),
        )
    );
  }

  @override
  initState() {
    super.initState();
    getImagesIds();
  }

  @override
  deactivate() {
    refreshBus.close();
    super.deactivate();
  }

  Future<void> getImagesIds() async {
    var ids = await Preferences.fetchIds();
    setState(() {
      imagesIds = ids;
    });
  }

  void refreshImages() {
    print('Fetching all images');
    refreshBus.sink.add(true);
  }

  void pushImage() {
    final String name = Utils.createRandomString(10);

    setState(() {
      imagesIds.add(name);
    });

    Preferences.saveIds(imagesIds);
    print('Added $name');
  }

}