import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResultStorage {
  static const String _resultKey = 'saved_results';

  Future<void> saveResults(
    List<Map<String, dynamic>> results,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final String encodedData = json.encode(results);
    await prefs.setString(_resultKey, encodedData);
  }

  Future<List<Map<String, dynamic>>> loadResults() async {
    final prefs = await SharedPreferences.getInstance();

    final String? encodedData = prefs.getString(_resultKey);
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData);
    return decodedData.cast<Map<String, dynamic>>();
  }
}
