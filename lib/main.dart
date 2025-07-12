import 'package:flutter/material.dart';
import 'package:frontend/protectedroute.dart';
import 'package:frontend/screens/auth/authscreen.dart';
import 'package:frontend/screens/auth/otpVerification.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/admindash.dart';
import 'package:frontend/screens/dashboard/lgDashboard/dashboard_screen.dart';
import 'package:frontend/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IITGJobs Admin Panel',
      theme: AppTheme.lightTheme, // ✅ Apply global theme
      initialRoute: '/auth',
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/otp': (_) => const OTPVerificationScreen(),
        '/lgDashboard':
            (_) => const ProtectedRoute(
              child: DashboardScreen(),
              requiredRole: 'lg',
            ),
        '/adminDashboard':
            (_) => const ProtectedRoute(
              child: AdminDashboard(),
              requiredRole: 'admin',
            ),
      },
    );
  }
}
