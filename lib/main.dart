import 'package:flutter/material.dart';
import 'package:frontend/protectedroute.dart';
import 'package:frontend/screens/auth/authscreen.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/admindash.dart';
import 'package:frontend/screens/dashboard/lgDashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth',
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/lgDashboard':
            (_) => const ProtectedRoute(
              child: DashboardScreen(),
              requiredRole: 'lg', // ✅ lowercase
            ),
        '/adminDashboard':
            (_) => const ProtectedRoute(
              child: AdminDashboard(),
              requiredRole: 'admin', // ✅ lowercase
            ),
      },
    );
  }
}
