import 'package:flutter/material.dart';
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
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
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
              onTap: () {
                // Handle logout
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
