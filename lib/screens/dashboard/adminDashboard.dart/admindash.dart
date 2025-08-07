import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.indigo,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Panels",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // ✅ Admin Panel Grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    _dashboardItems.map((item) {
                      return _buildTile(
                        context,
                        item['icon'],
                        item['title'],
                        item['color'],
                        item['route'],
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 22,
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _dashboardItems => [
    {
      "icon": Icons.house,
      "title": "Add Industry",
      "color": Colors.blue,
      "route": '/industry',
    },
    {
      "icon": Icons.business,
      "title": "Add Companies",
      "color": Colors.teal,
      "route": '/companies',
    },
    {
      "icon": Icons.assignment,
      "title": "Leads",
      "color": Colors.orange,
      "route": '/lead',
    },
  ];
}
