import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/auth_service.dart';

class HrService {
  static const baseUrl = 'http://localhost:3000/api';

  // Cache for industries and companies
  static final Map<String, List<Map<String, dynamic>>> _companyCache = {};

  // ✅ Fetch industries
  static Future<List<dynamic>> fetchIndustries() async {
    final response = await http.get(Uri.parse('$baseUrl/industries'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load industries');
    }
  }

  // ✅ Fetch companies by industry (with caching)
  static Future<List<Map<String, dynamic>>> fetchCompanies(
    String industryId,
  ) async {
    if (_companyCache.containsKey(industryId)) {
      return _companyCache[industryId]!;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/companies/$industryId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      final companies = List<Map<String, dynamic>>.from(decoded);
      _companyCache[industryId] = companies;
      return companies;
    } else {
      throw Exception('Failed to load companies');
    }
  }

  // ✅ Fetch HRs by industry and company
  static Future<List<dynamic>> fetchHrList(
    String industryId,
    String companyId,
  ) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/hr/$industryId/$companyId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch HR list');
    }
  }

  // ✅ Submit new HR data
  static Future<http.Response> submitHr(Map<String, dynamic> payload) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/hr'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    return response;
  }

  // ✅ Fetch user stats (today, month, total)
  static Future<Map<String, dynamic>> fetchUserStats(String userId) async {
    final url = Uri.parse('$baseUrl/hr/stats/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Expected keys: today, month, total
    } else {
      throw Exception('Failed to fetch user statistics');
    }
  }

  static Future<List<dynamic>> fetchTodayLeads(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/hr/today/$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['leads']; // ✅ CORRECT KEY based on your API response
    } else {
      throw Exception('Failed to load today\'s leads');
    }
  }

  static Future<void> updateLead(
    String id,
    Map<String, dynamic> updatedData,
  ) async {
    final token = await AuthService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/hr/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update lead');
    }
  }
}
