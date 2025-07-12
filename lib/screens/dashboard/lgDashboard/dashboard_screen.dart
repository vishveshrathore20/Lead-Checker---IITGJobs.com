import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/dashboard/lgDashboard/totayleadsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/hr_service.dart';
import 'package:frontend/screens/dashboard/lgDashboard/new_leads_screen.dart';
import 'dashboard_drawer.dart';
import 'dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int today = 0;
  int month = 0;
  int total = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final userId = token != null ? parseUserIdFromJWT(token) : null;

      if (userId != null && userId.isNotEmpty) {
        final stats = await HrService.fetchUserStats(userId);
        setState(() {
          today = stats['today'];
          month = stats['month'];
          total = stats['total'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String parseUserIdFromJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return '';
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final data = jsonDecode(payload);
    return data['userId'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DashboardDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        title: const Text(
          'LG Dashboard',
          style: TextStyle(color: Colors.black87),
        ),
        actions: const [
          CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: 'Statistics & Reports'),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: 'Today Lead Generated',
                          amount: '$today',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'This Month',
                          amount: '$month',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: 'Till Date',
                          amount: '$total',
                        ),
                      ),
                    ],
                  ),
              const SizedBox(height: 32),
              const _SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 16),
              _buildActionGrid(context),
              const SizedBox(height: 32),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('© Copyright 2025 by IITGJobs.com')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        "icon": Icons.assignment,
        "label": "Generate New Lead",
        "onTap":
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewLeadsScreen()),
            ),
      },
      {
        "icon": Icons.leaderboard,
        "label": "View Today's Leads",
        "onTap":
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TodayLeadsScreen()),
            ),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: action['onTap'],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF4158D0), Color.fromARGB(255, 36, 41, 54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action["icon"], size: 30, color: Colors.white),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      action["label"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3E4455),
      ),
    );
  }
}
