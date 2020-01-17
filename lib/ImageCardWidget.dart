
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:images_fetcher/preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'FileSaver.dart';

class ImageCardWidget extends StatefulWidget {
  final String preferencesKey;
  ImageCardWidgetState _state;

  ImageCardWidget({Key key, this.preferencesKey}): super(key: key);

  fetchImage() {
    _state.fetchImage();
  }

  @override
  State<StatefulWidget> createState() {
    _state = new ImageCardWidgetState();
    return _state;
  }
}

class ImageCardWidgetState extends State<ImageCardWidget> {
  var image = Image.asset(
      'images/dummy.png'
  );
  var isLoading = false;
  var isEditing = false;
  Preferences preferences;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: isEditing ? getEditingWidgets() : getViewWidgets(),
//              <Widget>[

//                Center(
//                    child:
//                ),
//                MaterialButton(
//                    child: isLoading ?
//                    CircularProgressIndicator() :
//                    Text('Fetch'),
//                    color: Colors.amber,
//                    onPressed: isLoading ? null : fetchImage
//                ),
//                Spacer(
//                    flex: 1
//                ),
//                Text('Last update: ${preferences.lastUpdated}')
//              ]
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
          setState(() {
            image = Image.file(file);
          });
        }
      }).catchError((error) => print('Initialization error: $error'));
    });

    super.initState();
  }

  void fetchImage() async {
    var fs = FileSaver(widget.preferencesKey);
    var now = DateTime.now();
    setState(() {
      isLoading = true;
    });
    fs.fetch(preferences.url).then((File file) {
      imageCache.clear();
      setState(() {
        image = Image.file(
            file,
            key: Key('${now.millisecondsSinceEpoch}')
        );
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
