import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyService {
  static const String baseUrl =
      'http://localhost:3000/api/admin'; // Update as needed

  static Future<Map<String, dynamic>> getCompanies({
    required int page,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/companies?page=$page&limit=$limit'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load companies');
    }
  }

  static Future<int> getCompanyCount() async {
    final response = await http.get(Uri.parse('$baseUrl/companies/count'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['count'];
    } else {
      throw Exception('Failed to get count');
    }
  }

  static Future<List<dynamic>> searchCompanies(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/companies/search?query=$query'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Search failed');
    }
  }

  static Future<Map<String, dynamic>> addCompany(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/companies'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add company');
    }
  }

  static Future<void> updateCompany(String id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/companies/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update company');
    }
  }

  static Future<void> deleteCompany(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/companies/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete company');
    }
  }
}
