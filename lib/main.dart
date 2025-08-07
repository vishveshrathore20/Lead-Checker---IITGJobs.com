import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/screens/auth/authscreen.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/admindash.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/bulklead.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/company.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/industry.dart';
import 'package:frontend/screens/dashboard/adminDashboard.dart/leads.dart';
import 'package:frontend/screens/dashboard/lgDashboard/dashboard_screen.dart';
import 'package:frontend/screens/dashboard/utils/single_Lead_Generation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'authToken');
  final role = (await storage.read(key: 'userRole'))?.toLowerCase();

  String initialRoute = '/auth';
  if (token != null && role != null) {
    if (role == 'admin') {
      initialRoute = '/adminDashboard';
    } else if (role == 'lg') {
      initialRoute = '/lgDashboard';
    }
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IITGJobs.com',
      initialRoute: initialRoute,
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/adminDashboard': (_) => const AdminDashboard(),
        '/lgDashboard': (_) => const DashboardScreen(),
        '/industry': (_) => IndustryScreen(),
        '/companies': (_) => CompanyScreen(),
        '/lead': (_) => LeadsDashboardScreen(),
        '/bulklead': (_) => BulkLeadUploadScreen(),
        '/singlelead': (_) => NewLeadEntryScreen(),
      },
    );
  }
}
