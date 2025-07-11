import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProtectedRoute extends StatefulWidget {
  final Widget child;
  final String requiredRole;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.requiredRole,
  });

  @override
  State<ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<ProtectedRoute> {
  bool isLoading = true;
  bool isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('Stored token: $token');

    if (token != null) {
      try {
        final payload = _parseJwt(token);
        print("JWT Payload: $payload");
        print("Required role: ${widget.requiredRole}");

        final userRole = payload['role']?.toString().toLowerCase();

        if (userRole == widget.requiredRole.toLowerCase()) {
          setState(() {
            isAuthorized = true;
          });
        }
      } catch (e) {
        print("Error parsing JWT: $e");
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid token');

    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return jsonDecode(decoded);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isAuthorized) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return widget.child;
  }
}
