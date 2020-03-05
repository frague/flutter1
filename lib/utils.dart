import 'dart:convert';
import 'dart:math';

class Utils {
  static final Random _random = Random.secure();

  static String createRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values).replaceAll(new RegExp('[^a-zA-Z0-9]'), '');
  }
}