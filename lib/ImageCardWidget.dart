
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:images_fetcher/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'FileSaver.dart';

const dummyImagePath = 'images/dummy.png';

class ImageCardWidget extends StatefulWidget {
  final String preferencesKey;
  final StreamController refreshBus;

  ImageCardWidget({Key key,  this.preferencesKey, this.refreshBus}): super(key: key);


  @override
  State<StatefulWidget> createState() => ImageCardWidgetState(this.refreshBus);
}

class ImageCardWidgetState extends State<ImageCardWidget> {
  var image = Image.asset(dummyImagePath);
  var isLoading = false;
  var isEditing = false;
  Preferences preferences;
  final StreamController refreshStream;

  ImageCardWidgetState(this.refreshStream) : super() {
    this.refreshStream.stream.listen(this.fetchImage);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Form(
        key: _formKey,
        child: FlatButton(
            onPressed: () {
              isEditing = !isEditing;
            },
            child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isEditing ? getEditingWidgets() : getViewWidgets(),
                //                Text('Last update: ${preferences.lastUpdated}')
                ),
            )
        )

    );
  }

  List<Widget> getEditingWidgets() {
    return <Widget>[
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
        onPressed: () => setState(() {
          isEditing = false;
        })
      ),
    ];
  }

  List<Widget> getViewWidgets() {
    return <Widget>[
      Card(
        borderOnForeground: true,
        child: InkWell(
          child: Opacity(
            opacity: isLoading ? 0.5 : 1,
            child: image,
          ),
          onTap: () => setState(() {
            isEditing = true;
          })
        ),
        color: Colors.blueGrey,
      )
    ];
  }

  @override
  void initState() {
    setState(() {
      isEditing = this.isEditing;
    });

    preferences = Preferences(widget.preferencesKey);
    preferences.fetch().then((Preferences prefs) {
      setState(() {
        preferences = prefs;
      });
    });

    var fs = FileSaver(widget.preferencesKey);
    print('Initialization');
    fs.requestPermissions(PermissionGroup.storage).then((st) {
      fs.localFile.then((File file) {
        if (file != null) {
          var now = DateTime.now();
          setState(() {
            image = file.existsSync() ?
              Image.file(
                file,
                key: Key('${now.millisecondsSinceEpoch}')
              )
            :
              Image.asset(dummyImagePath);
          });
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
        image = file.existsSync() ?
          Image.file(
            file,
            key: Key('${now.millisecondsSinceEpoch}')
          )
        :
          Image.asset(dummyImagePath);
        preferences.lastUpdated = now;
        isLoading = false;
      });
      preferences.save();
    }).catchError((error) {
      print('Error fetching/saving an image: $error');
      setState(() {
        isLoading = false;
      });
    });
  }
}
