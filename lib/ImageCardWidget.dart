import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:images_fetcher/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'FileSaver.dart';

const dummyImagePath = 'images/dummy.png';

class ImageCardWidget extends StatefulWidget {
  final String preferencesKey;
  final StreamController refreshBus;
  final String reorderingKey;

  ImageCardWidget(
      {Key key, this.preferencesKey, this.refreshBus, this.reorderingKey})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageCardWidgetState();
}

class ImageCardWidgetState extends State<ImageCardWidget> {
  var image = Image.asset(dummyImagePath);
  var isLoading = false;
  var isEditing = false;
  var renderAsBorder = false;
  var height = 200;
  Preferences preferences;

  bool get isOutlined =>
      widget.reorderingKey != null &&
      widget.reorderingKey != widget.preferencesKey;

  @override
  Widget build(BuildContext context) {
    return isEditing ? getEditingWidget() : getViewWidget();
  }

  Widget getEditingWidget() {
    final _formKey = GlobalKey<FormState>();
    return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Image URL',
            ),
            initialValue: preferences.url,
            onChanged: (value) {
              preferences.url = value;
              preferences.save();
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Refresh interval (min.)',
            ),
            initialValue: preferences.refreshMinutes.toString(),
            onChanged: (value) {
              preferences.refreshMinutes = int.parse(value) ?? 60;
              preferences.save();
            },
            keyboardType: TextInputType.number,
          ),
          MaterialButton(
            child: Text('OK'),
            color: Colors.amber,
            onPressed: () => setState(() => isEditing = false),
          ),
        ]));
  }

  Widget getViewWidget() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: 4.0,
          style: isOutlined ? BorderStyle.solid : BorderStyle.none,
          color: Colors.blueGrey,
        ),
      ),
      child: Card(
        borderOnForeground: true,
        child: InkWell(
          child: AnimatedOpacity(
            opacity: isOutlined ? 0 : (isLoading ? 0.5 : 1),
            duration: Duration(seconds: 5),
            child: Container(
              constraints: BoxConstraints(
                minWidth: double.infinity,
                maxHeight: height.toDouble(),
              ),
              child: image,
            ),
          ),
          onTap: () => setState(() => isEditing = true),
        ),
        color: isOutlined ? Colors.transparent : Colors.blueGrey,
      ),
    );
  }

  List<Widget> getBorderWidgets() {
    return <Widget>[
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.0,
            style: BorderStyle.solid,
            color: Colors.red,
          ),
        ),
        child: SizedBox(
          height: 100.0,
        ),
      )
    ];
  }

  @override
  void initState() {
    this.widget.refreshBus.stream.listen(this.fetchImage);

    preferences = Preferences(widget.preferencesKey);
    preferences.fetch().then((Preferences prefs) {
      setState(() => preferences = prefs);
    });

    var fs = FileSaver(widget.preferencesKey);
    print('Initialization');
    fs.requestPermissions(PermissionGroup.storage).then((st) {
      fs.localFile.then((File file) {
        if (file != null) {
          var now = DateTime.now();
          setState(() {
            image = file.existsSync()
                ? Image.file(file, key: Key('${now.millisecondsSinceEpoch}'))
                : Image.asset(dummyImagePath);
          });
          updateImageHeight();
        }
      }).catchError((error) => print('Initialization error: $error'));
    });

    super.initState();
  }

  void fetchImage([flag]) async {
    print('Fetching for ${preferences.prefix}');
    var fs = FileSaver(widget.preferencesKey);
    var now = DateTime.now();
    setState(() {
      isLoading = true;
      isEditing = false;
    });
    fs.fetch(preferences.url).then((File file) {
      imageCache.clear();
      setState(() {
        image = file.existsSync()
            ? Image.file(file, key: Key('${now.millisecondsSinceEpoch}'))
            : Image.asset(dummyImagePath);
        preferences.lastUpdated = now;
        isLoading = false;
      });
      preferences.save();
      updateImageHeight();
    }).catchError((error) {
      print('Error fetching/saving an image: $error');
      setState(() => isLoading = false);
    });
  }

  void updateImageHeight() {
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image.resolve(new ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          height = info.image.height;
        });
        print('Height $height');
        return completer.complete(info.image);
      }),
    );
  }
}
