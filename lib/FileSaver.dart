import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

const dcim = '/storage/emulated/0/DCIM/Web';

class FileSaver {
  static var httpClient = new HttpClient();
  String fileName;

  FileSaver(String id) {
    if (id.isEmpty) {
      throw('No file id provided');
    }
    fileName = 'image$id';
    _assureDirectory();
  }

  Future<String> get _localPath async {
//    final directory = await getApplicationDocumentsDirectory();
//    return directory.path;
    return dcim;
  }

  // Checks if the target path exists
  // Creates it if it is not
  Future<void> _assureDirectory() async {
    final targetDir = new Directory(await _localPath);
    bool dirExists = await targetDir.exists();
    print('Check if $targetDir exists: $dirExists');
    if (!dirExists) {
      print('Create target dir recursively...');
      await targetDir.create(recursive: true);
    }
  }

  // Gets local file
  Future<File> get localFile async {
    print('Getting local file:');
    try {
      final path = await _localPath + '/$fileName.jpg';
      print('$path');
      final file = File('$path');
      return file;
    } catch (e) {
      print('... failed: $e');
      return null;
    }
  }

  // Checks storage read/write permissions
  Future<bool> hasStoragePermissions(PermissionGroup area) async {
    PermissionStatus permissions = await PermissionHandler().checkPermissionStatus(area);
    final result = (permissions == PermissionStatus.granted);
    print('Checking ${area.toString()} permissions: ${result.toString()}');
    return result;
  }

  // Requests permissions from user
  Future<dynamic> requestPermissions(PermissionGroup area) async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([area]);
    print('Requesting ${area.toString()} permissions from user: ${permissions.toString()}');
    return permissions;
  }

  // Saves data into the file
  Future<File> write(List<int> data) async {
    print('Writing to file');
    final file = await localFile;
    final canWrite = await this.hasStoragePermissions(PermissionGroup.storage);
    if (!canWrite) {
      await requestPermissions(PermissionGroup.storage);
      if (!await this.hasStoragePermissions(PermissionGroup.storage)) {
        throw Exception('Unable to write to file: $file');
      }
    }
    return file.writeAsBytes(data, flush: true);
  }

  // Reads data from the file
  Future<List<int>> read() async {
    final file = await localFile;
    if (!file.existsSync()) {
      throw 'File does not exist!';
    }
    if (await this.hasStoragePermissions(PermissionGroup.storage)) {
      Uint8List contents = await file.readAsBytes();
      return contents.toList();
    } else {
      throw Exception('Unable to read from file: $file');
    }
  }

  // Fetches data from the URL provided
  // and saves it to the file
  Future<File> fetch(String url) async {
    print('Fetching $url');
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    return await write(bytes);
  }

}