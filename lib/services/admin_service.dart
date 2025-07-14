import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AdminService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Fetch admin dashboard statistics
  Future<List<Map<String, dynamic>>> fetchAdminStats() async {
    final url = Uri.parse('$baseUrl/admin/stats');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, dynamic>>((item) {
          return {
            "label": item['label'],
            "value": item['value'],
            "color": _parseColor(item['color']),
          };
        }).toList();
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print("Error fetching admin stats: $e");
      throw Exception('Network error');
    }
  }

  /// Convert color hex string like "#4caf50" to [Color]
  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // add alpha if missing
    }
    return Color(int.parse("0x$hexColor"));
  }

  /// Add a new industry
  static Future<bool> addIndustry(String name) async {
    final url = Uri.parse('$baseUrl/industries');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print("Failed to add industry: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error adding industry: $e");
      return false;
    }
  }

  /// Fetch all industries
  static Future<List<Map<String, dynamic>>> getIndustries() async {
    final url = Uri.parse('$baseUrl/industries');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print("Failed to fetch industries: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching industries: $e");
      return [];
    }
  }

  static Future<bool> addCompany(String name, String industryId) async {
    final url = Uri.parse('$baseUrl/companies');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'industryId': industryId}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('❌ Add Company Error: ${response.body}');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCompaniesByIndustry(
    String industryId,
  ) async {
    final url = Uri.parse('$baseUrl/admin/getcompany?industryId=$industryId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('❌ Get Companies Error: ${response.body}');
      return [];
    }
  }

  static Future<bool> deleteCompany(String companyId) async {
    final url = Uri.parse('$baseUrl/admin/companies/$companyId');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }

  static Future<bool> updateCompany(String companyId, String newName) async {
    final url = Uri.parse('$baseUrl/admin/companies/$companyId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );
    return response.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> getCompanies() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/getcompany'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getFilteredLeads({
    int page = 1,
    String? industryId,
    String? designation,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Build query parameters dynamically
    Map<String, String> queryParams = {
      'page': page.toString(),
      if (industryId != null && industryId.isNotEmpty) 'industryId': industryId,
      if (designation != null && designation.isNotEmpty)
        'designation': designation,
      if (search != null && search.isNotEmpty) 'search': search,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    final uri = Uri.parse(
      '$baseUrl/admin/leads',
    ).replace(queryParameters: queryParams);

    print("📤 Fetching leads with query: $queryParams"); // ✅ Debug log

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Lead fetch error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to fetch leads');
    }
  }
}
