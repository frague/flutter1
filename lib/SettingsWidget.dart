import 'package:flutter/material.dart';
import 'ImageCardWidget.dart';

const images = ['webImage', 'w1', 'w2'];

class SettingsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsWidgetState();
}

class SettingsWidgetState extends State<SettingsWidget> {
  var isLoading = false;
  List<ImageCardWidget> imagesWidgets = [];

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
            onPressed: null,
            child: Icon(Icons.plus_one),
          )
        ],
        body: ListView(
          children: imagesWidgets,
        )
    );
  }

  @override
  initState() {
    imagesWidgets = images.map((key) => ImageCardWidget(
      preferencesKey: key
    )).toList();
    
    super.initState();
  }

  refreshImages() {
    print('Fetching all images');
    imagesWidgets.forEach((widget) => widget.fetchImage());
  }

}