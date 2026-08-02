import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class PredictionService {
  /// Fetches the dropdown options from the backend.
  static Future<Map<String, dynamic>> fetchOptions() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/options');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load options: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  /// Sends the car details to the backend to get a price prediction.
  static Future<Map<String, dynamic>> predictPrice(Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/predict');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to predict price: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }
}
