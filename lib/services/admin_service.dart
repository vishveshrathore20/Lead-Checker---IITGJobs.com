import 'package:flutter/material.dart';

Future<List<Map<String, dynamic>>> fetchAdminStats() async {
  // Simulated dynamic data
  await Future.delayed(Duration(seconds: 1));
  return [
    {"label": "Total Users", "value": 142, "color": Colors.blue},
    {"label": "Total Leads", "value": 88, "color": Colors.orange},
    {"label": "Companies", "value": 26, "color": Colors.teal},
    {"label": "Industries", "value": 14, "color": Colors.indigo},
    {"label": "Monthly Stats", "value": 102, "color": Colors.deepPurple},
    {"label": "Active Users", "value": 58, "color": Colors.green},
    {"label": "Pending Leads", "value": 12, "color": Colors.red},
    {"label": "Closed Deals", "value": 34, "color": Colors.cyan},
    {"label": "Visits Today", "value": 21, "color": Colors.pink},
    {"label": "Revenue", "value": "\$12.5k", "color": Colors.brown},
  ];
}
