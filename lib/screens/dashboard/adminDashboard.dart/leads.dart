import 'package:flutter/material.dart';

class LeadsDashboardScreen extends StatelessWidget {
  const LeadsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(
        title: 'All Leads',
        icon: Icons.leaderboard,
        color: Colors.indigo,
        onTap: () => Navigator.pushNamed(context, '/all-leads'),
      ),
      _DashboardItem(
        title: 'Bulk Lead Upload',
        icon: Icons.upload_file,
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, '/bulklead'),
      ),
      _DashboardItem(
        title: 'Raw Leads',
        icon: Icons.data_object,
        color: Colors.orange,
        onTap: () => Navigator.pushNamed(context, '/raw-leads'),
      ),
      _DashboardItem(
        title: 'Single Lead Entry',
        icon: Icons.note_add_rounded,
        color: Colors.deepPurple,
        onTap: () => Navigator.pushNamed(context, '/singlelead'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads Dashboard'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: items.map((item) => _buildCard(context, item)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _DashboardItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 300,
        height: 120,
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: item.color,
              radius: 28,
              child: Icon(item.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 28, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
