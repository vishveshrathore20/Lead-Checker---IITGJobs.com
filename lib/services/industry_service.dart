import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl =
      'http://localhost:3000/api/admin'; // Replace with your API base

  static Future<Map<String, dynamic>> getIndustries({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/industries?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'industries': data['industries'],
        'totalCount': data['totalCount'],
      };
    } else {
      throw Exception('Failed to fetch industries');
    }
  }

  static Future<List<dynamic>> searchIndustries(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/industries/search?query=$query'), // 👈 Correct param!
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Search failed');
    }
  }

  static Future<int> getIndustryCount() async {
    final response = await http.get(Uri.parse('$baseUrl/industries/count'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['count'];
    } else {
      throw Exception('Failed to get count');
    }
  }

  static Future<Map<String, dynamic>> addIndustry(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/industries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body); // ✅ RETURN the created industry
    } else {
      throw Exception('Failed to add industry');
    }
  }

  static Future<void> updateIndustry(String id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/industries/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name}),
    );
    if (response.statusCode != 200) {
      throw Exception('Update failed');
    }
  }

  static Future<void> deleteIndustry(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/industries/$id'));
    if (response.statusCode != 200) {
      throw Exception('Delete failed');
    }
  }
}
