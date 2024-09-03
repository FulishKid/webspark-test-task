import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  static const String correctBaseUrl =
      'https://flutter.webspark.dev/flutter/api';

  final String baseUrl;

  APIService(this.baseUrl);

  bool isValidURL() {
    return baseUrl == correctBaseUrl;
  }

  Future<List<dynamic>> fetchTasks() async {
    if (!isValidURL()) {
      throw Exception('Invalid URL. Please use the correct API URL.');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> sendResults(List<Map<String, dynamic>> results) async {
    if (!isValidURL()) {
      throw Exception('Invalid URL. Please use the correct API URL.');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(results),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send results');
    }

    print('Results sent successfully: ${response.body}');
  }
}
