import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HRService {
  static const String baseUrl = 'http://localhost:3000/api';

  // ================= Get Industries =================
  static Future<List<dynamic>> getIndustries() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/industries'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Failed to fetch industries');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============== Get Companies By Industry ============
  static Future<List<dynamic>> getCompanies(String industryId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/companies/$industryId'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Failed to fetch companies');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ================= Get HRs by Company =================
  static Future<List<dynamic>> getHrsByCompany(String companyId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/hrs/company/$companyId'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Failed to fetch HRs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ================= Add HR =================
  static Future<bool> addHr({
    required String name,
    required String designation,
    required String mobile,
    required String email,
    required String remarks,
    required String industryId,
    required String companyId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('User not authenticated');

      final res = await http.post(
        Uri.parse('$baseUrl/hr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'designation': designation,
          'mobile': mobile,
          'email': email,
          'remarks': remarks,
          'industryId': industryId,
          'companyId': companyId,
        }),
      );

      if (res.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['error'] ?? 'Failed to add HR');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ================= Check Duplicate Mobile =================
  static Future<bool> isDuplicateMobile(String mobile) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/hrs/all'));
      if (res.statusCode == 200) {
        final hrs = jsonDecode(res.body) as List;
        return hrs.any((hr) => hr['mobile'] == mobile);
      } else {
        throw Exception('Failed to check duplicates');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
