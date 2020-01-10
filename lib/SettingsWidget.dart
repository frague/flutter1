import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'FileSaver.dart';
import 'preferences.dart';

class SettingsWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingsWidgetState();
  }
}

class SettingsWidgetState extends State<SettingsWidget> {
  var image = Image.asset(
      'images/dummy.png'
  );
  final preferencesKey = 'webImage';
  var preferences = Preferences();
  var isLoading = false;

  @override
  Scaffold build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
        appBar: AppBar(
          title: Text('Web Image Widget Settings'),
        ),
        body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                    Center(
                        child: isLoading ?
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: CircularProgressIndicator(),
                        ):
                        Card(
                          child: image,
                          color: Colors.blueGrey,
                        )
                    ),
                    MaterialButton(
                      child: Text('Fetch'),
                      color: Colors.amber,
                      onPressed: isLoading ?
                      null:
                          () {
                        var fs = FileSaver();
                        var now = DateTime.now();
                        setState(() {
                          isLoading = true;
                        });
                        fs.fetch(preferences.url).then((File file) {
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
                      },
                    ),
                    Spacer(
                        flex: 1
                    ),
                    Text('Last update: ${preferences.lastUpdated}')
                  ]
              )
              ,
            )

        )
    );
  }

  @override
  initState() {
    super.initState();

    var fs = FileSaver();
    print('Initialization');
    fs.requestPermissions(PermissionGroup.storage).then((st) {
      fs.localFile.then((File file) {
        if (file != null) {
          setState(() {
            image = Image.file(file);
          });
        }
      }).catchError((error) => print('Initialization error: $error'));

      preferences.fetch().then((Preferences prefs) {
        setState(() {
          preferences = prefs;
        });
      });
    });
  }

}