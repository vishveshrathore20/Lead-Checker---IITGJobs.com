import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/hr_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodayLeadsScreen extends StatefulWidget {
  const TodayLeadsScreen({super.key});

  @override
  State<TodayLeadsScreen> createState() => _TodayLeadsScreenState();
}

class _TodayLeadsScreenState extends State<TodayLeadsScreen> {
  List<Map<String, dynamic>> leads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTodayLeads();
  }

  Future<void> loadTodayLeads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final userId = token != null ? parseUserIdFromJWT(token) : null;

      if (userId != null) {
        final data = await HrService.fetchTodayLeads(userId);
        setState(() {
          leads = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching today leads: $e');
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

  void _showEditDialog(BuildContext context, Map<String, dynamic> lead) {
    final nameController = TextEditingController(text: lead['name']);
    final designationController = TextEditingController(
      text: lead['designation'],
    );
    final mobileController = TextEditingController(
      text:
          (lead['mobile'] is List)
              ? (lead['mobile'] as List).join(', ')
              : lead['mobile'] ?? '',
    );
    final emailController = TextEditingController(text: lead['email']);
    final locationController = TextEditingController(
      text: lead['location'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Edit Lead"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: designationController,
                    decoration: const InputDecoration(labelText: 'Designation'),
                  ),
                  TextField(
                    controller: mobileController,
                    decoration: const InputDecoration(
                      labelText: 'Mobile (comma separated)',
                    ),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updated = {
                    'name': nameController.text.trim(),
                    'designation': designationController.text.trim(),
                    'mobile':
                        mobileController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                    'email': emailController.text.trim(),
                    'location': locationController.text.trim(),
                  };

                  await HrService.updateLead(lead['_id'], updated);
                  Navigator.of(ctx).pop();
                  loadTodayLeads();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Leads"),
        backgroundColor: const Color(0xFF3E4455),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : leads.isEmpty
              ? const Center(child: Text('No leads found for today.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(50),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                            4: FlexColumnWidth(2),
                            5: FlexColumnWidth(2),
                            6: FlexColumnWidth(2),
                            7: FlexColumnWidth(2),
                            8: FixedColumnWidth(60),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder.all(color: Colors.grey.shade300),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFF3E4455),
                              ),
                              children: const [
                                _HeaderCell('SN'),
                                _HeaderCell('Name'),
                                _HeaderCell('Designation'),
                                _HeaderCell('Mobile'),
                                _HeaderCell('Email'),
                                _HeaderCell('Location'),
                                _HeaderCell('Industry'),
                                _HeaderCell('Company'),
                                _HeaderCell('Edit'),
                              ],
                            ),
                            ...leads.asMap().entries.map((entry) {
                              final index = entry.key;
                              final lead = entry.value;
                              final industryName =
                                  lead['industry']?['name'] ?? 'N/A';
                              final companyName =
                                  lead['company']?['name'] ?? 'N/A';
                              final mobileFormatted =
                                  lead['mobile'] is List
                                      ? (lead['mobile'] as List).join(', ')
                                      : lead['mobile'] ?? '';

                              return TableRow(
                                children: [
                                  _BodyCell('${index + 1}'),
                                  _BodyCell(lead['name'] ?? ''),
                                  _BodyCell(lead['designation'] ?? ''),
                                  _BodyCell(mobileFormatted),
                                  _BodyCell(lead['email'] ?? ''),
                                  _BodyCell(lead['location'] ?? 'N/A'),
                                  _BodyCell(industryName),
                                  _BodyCell(companyName),
                                  Center(
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      ),
                                      onPressed:
                                          () => _showEditDialog(context, lead),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  const _BodyCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
