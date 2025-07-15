import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html; // Only for web

class AdminService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Fetch admin dashboard stats
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

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse("0x$hexColor"));
  }

  /// Add Industry
  static Future<bool> addIndustry(String name) async {
    final url = Uri.parse('$baseUrl/industries');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error adding industry: $e");
      return false;
    }
  }

  /// Get Industries
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

  /// Add Company
  static Future<bool> addCompany(String name, String industryId) async {
    final url = Uri.parse('$baseUrl/companies');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'industryId': industryId}),
    );
    return response.statusCode == 201;
  }

  /// Get Companies by Industry
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

  /// Get All Companies
  static Future<List<Map<String, dynamic>>> getCompanies() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/getcompany'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      return [];
    }
  }

  /// Delete Company
  static Future<bool> deleteCompany(String companyId) async {
    final url = Uri.parse('$baseUrl/admin/companies/$companyId');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }

  /// Update Company
  static Future<bool> updateCompany(String companyId, String newName) async {
    final url = Uri.parse('$baseUrl/admin/companies/$companyId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );
    return response.statusCode == 200;
  }

  /// Get Filtered Leads
  static Future<Map<String, dynamic>> getFilteredLeads({
    int page = 1,
    String? industryId,
    String? designation,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
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
    print("📤 Fetching leads with: $queryParams");

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("❌ Lead fetch error: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to fetch leads');
    }
  }

  static Future<void> downloadExcel({
    required BuildContext context,
    String? industryId,
    String? designation,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = {
        if (industryId != null) 'industryId': industryId,
        if (designation != null) 'designation': designation,
        if (search != null && search.isNotEmpty) 'search': search,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final uri = Uri.parse(
        '$baseUrl/admin/export/leads',
      ).replace(queryParameters: query);

      // 👉 Use browser window to download
      html.AnchorElement anchor =
          html.AnchorElement(href: uri.toString())
            ..target = 'blank'
            ..download = 'leads.xlsx';
      anchor.click();
    } catch (e) {
      debugPrint("Excel download error (Web): $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to download Excel: $e")));
    }
  }
}
