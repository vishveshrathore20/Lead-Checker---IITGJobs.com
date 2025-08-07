import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final _storage = const FlutterSecureStorage();
  bool _authorized = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final role = await _storage.read(key: 'userRole');
    final token = await _storage.read(key: 'authToken');

    if (token != null &&
        role?.toLowerCase() == widget.requiredRole.toLowerCase()) {
      setState(() {
        _authorized = true;
        _checking = false;
      });
    } else {
      setState(() {
        _authorized = false;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_authorized) {
      return widget.child;
    } else {
      Future.microtask(
        () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/auth', (r) => false),
      );
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
