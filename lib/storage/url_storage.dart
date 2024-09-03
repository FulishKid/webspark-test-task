import 'package:shared_preferences/shared_preferences.dart';

class URLStorage {
  static const _urlKey = 'base_api_url';

  static Future<void> saveURL(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
  }

  static Future<String?> loadURL() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey);
  }
}
