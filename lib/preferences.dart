import 'package:shared_preferences/shared_preferences.dart';

const prefsIdsKey = 'allImages';

class Preferences {
  String prefix;
  String url = '';
  int refreshMinutes = 60;
  DateTime lastUpdated = DateTime(0);
  final imgUrl =
      'http://rasterizer.herokuapp.com/?url=https%3A%2F%2Fwww.gismeteo.ru%2Fweather-saratov-5032%2Fweekly%2F&selector=div%5Bdata-widget-id%3D%22forecast%22%5D%3Ediv%3Ediv&brightness=0&contrast=100%25&grayscale=100%25&invert=100%25&css=*%3Anot%28.w_prec__icon%29+%7Bbackground%3A+transparent+%21important%7D%0D%0Adiv%3Anth-child%282%29+div+span+svg+%7Bwidth%3A+70px%3Bheight%3A70px%7D%0D%0Adiv%3Anth-child%284%29%3A%3Aafter%2C+div%3Anth-child%286%29%3A%3Aafter+%7Bborder%3Anone%7D%0D%0Adiv%3Anth-child%285%29+div+%7Bfont-style%3Anormal%7D%0D%0A';

  Preferences(String prefix) {
    this.prefix = prefix;
  }

  static Future<List<String>> fetchIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> a = List.from((prefs.getString(prefsIdsKey) ?? '').split(','));
    print('Getting all images ids: $a');
    return a;
  }

  static Future<void> saveIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(prefsIdsKey, ids.join(','));
    print('Setting all images ids: $ids');
  }

  Future<Preferences> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    this.url = prefs.getString('${prefix}_url') ?? imgUrl;
    this.refreshMinutes = prefs.getInt('${prefix}_refresh') ?? 60;
    try {
      this.lastUpdated =
          DateTime.tryParse(prefs.getString('${prefix}_updated'));
    } catch (e) {
      this.lastUpdated = DateTime(2019, 11, 10);
    }

    print('Prefs fetched ${this.lastUpdated}');
    return this;
  }

  save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${prefix}_url', this.url);
    prefs.setInt('${prefix}_refresh', this.refreshMinutes);
    var updated = '';
    try {
      updated = this.lastUpdated.toIso8601String();
    } catch (e) {
      updated = '';
    }
    prefs.setString('${prefix}_updated', updated);
    print('Prefs saved ${this.url}');
  }
}
