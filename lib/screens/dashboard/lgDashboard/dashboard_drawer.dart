import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/authscreen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/dashboard/lgDashboard/profile_screen_app_bar.dart';
import 'new_leads_screen.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  Widget buildItem(
    BuildContext context,
    IconData icon,
    String label,
    Widget destination,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx); // Close dialog
                  await AuthService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF293B5F),
        child: Column(
          children: [
            const SizedBox(height: 60),
            buildItem(context, Icons.person, 'Profile', const ProfileScreen()),
            buildItem(
              context,
              Icons.assignment,
              'Leads Generation UI',
              const NewLeadsScreen(),
            ),
            const Spacer(),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => _handleLogout(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
