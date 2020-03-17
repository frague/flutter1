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
  var reorderingKey;

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
        body: ReorderableListView(
          onReorder: (int oldPosition, int newPosition) {
            print('$oldPosition -> $newPosition, $imagesIds');
          },
          children: List<Widget>.from(
              imagesIds.map((key) {
//                return SizedBox(
//                  key: ValueKey(key),
//                  height: 50.0,
//                  width: 100.0,
//                  child: Text('dddd'),
//                );
            return ImageCardWidget(
              key: ValueKey(key),
              preferencesKey: key,
              refreshBus: refreshBus,
              reorderingKey: reorderingKey,
            );
          })),
        ));
  }

  @override
  initState() {
    getImagesIds();
    super.initState();
  }

  @override
  deactivate() {
    refreshBus.close();
    super.deactivate();
  }

  Future<void> getImagesIds() async {
    var ids = (await Preferences.fetchIds()).where((key) => key.isNotEmpty).toList();
    setState(() {
      imagesIds = ids;
    });
    print('$imagesIds !!');
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
