import 'package:flutter/material.dart';
import 'package:frontend/screens/dashboard/lgDashboard/new_leads_screen.dart';
import 'dashboard_drawer.dart';
import 'dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const List<Map<String, String>> tableData = [
    {
      "name": "John Doe",
      "designation": "HR Manager",
      "mobile": "9876543210",
      "email": "john@example.com",
    },
    {
      "name": "Jane Smith",
      "designation": "Recruiter",
      "mobile": "9876543211",
      "email": "jane@example.com",
    },
    {
      "name": "Bob Johnson",
      "designation": "Talent Lead",
      "mobile": "9876543212",
      "email": "bob@example.com",
    },
    {
      "name": "Alice Williams",
      "designation": "HR Executive",
      "mobile": "9876543213",
      "email": "alice@example.com",
    },
  ];

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
              const Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      title: 'Today Lead Generated',
                      amount: '32',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DashboardCard(title: 'This Month', amount: '39'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DashboardCard(title: 'Till Date', amount: '231'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const _SectionTitle(title: 'Recent Lead Generated'),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildRecentLeadsTable()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildActionGrid(context)),
                ],
              ),
              const SizedBox(height: 24),
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

  static Widget _buildRecentLeadsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1000),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF293B5F)),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          columns: const [
            DataColumn(label: Text('SN')),
            DataColumn(label: Text('HR Name')),
            DataColumn(label: Text('Designation')),
            DataColumn(label: Text('Mobile')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Action')),
          ],
          rows:
              tableData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(data['name'] ?? '')),
                    DataCell(Text(data['designation'] ?? '')),
                    DataCell(Text(data['mobile'] ?? '')),
                    DataCell(Text(data['email'] ?? '')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () {
                          // Add edit logic
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  static Widget _buildActionGrid(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        "icon": Icons.assignment,
        "label": "For Lead Generation Click Here",
        "onTap":
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewLeadsScreen()),
            ),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 12,
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
                colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
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
