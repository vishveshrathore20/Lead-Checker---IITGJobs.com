import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> statTiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    try {
      final data = await AdminService().fetchAdminStats();
      setState(() {
        statTiles = data;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        statTiles = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Stats',
              onPressed: _loadStats,
            ),
          ],
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Statistics & Reports",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ✅ Stats Grid View (Wrap layout)
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              statTiles.map((item) {
                                return _buildStatTile(
                                  item['label'] ?? '',
                                  item['value'].toString(),
                                  _parseColor(item['color']),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "Panels",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ✅ Admin Panel Items
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
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
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

  Color _parseColor(dynamic color) {
    if (color is Color) return color;
    if (color is String && color.startsWith("#")) {
      return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
    }
    return Colors.grey;
  }

  List<Map<String, dynamic>> get _dashboardItems => [
    {
      "icon": Icons.house,
      "title": "Add Industry",
      "color": Colors.blue,
      "route": '/addIndustry',
    },
    {
      "icon": Icons.business,
      "title": "Add Companies",
      "color": Colors.teal,
      "route": '/addcompanies',
    },
    {
      "icon": Icons.assignment,
      "title": "All Leads",
      "color": Colors.orange,
      "route": '/leads',
    },
    {
      "icon": Icons.report_gmailerrorred,
      "title": "Detail reports on LG",
      "color": Colors.deepOrange,
      "route": '/leads', // Update with correct route if needed
    },
  ];
}
