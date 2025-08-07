import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000';

  // Create a singleton instance of FlutterSecureStorage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/api/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _secureStorage.write(key: 'authToken', value: data['token']);
        await _secureStorage.write(key: 'userRole', value: data['role'] ?? '');
        await _secureStorage.write(key: 'userEmail', value: email);

        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'role': data['role'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/api/verify-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'token': data['token'],
          'role': data['role'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  static Future<void> logout() async {
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'userRole');
    await _secureStorage.delete(key: 'userEmail');
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  static Future<String?> getUserRole() async {
    return await _secureStorage.read(key: 'userRole');
  }
}
