import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class DetailsLGsReport extends StatefulWidget {
  const DetailsLGsReport({super.key});

  @override
  State<DetailsLGsReport> createState() => _DetailsLGsReportState();
}

class _DetailsLGsReportState extends State<DetailsLGsReport> {
  List<dynamic> userStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserStats();
  }

  Future<void> fetchUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/admin/lg-stats'),
      );

      if (response.statusCode == 200) {
        setState(() {
          userStats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load user stats');
      }
    } catch (e) {
      debugPrint("Error fetching user stats: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('User Wise report'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  double tableWidth =
                      constraints.maxWidth < 800 ? 800 : constraints.maxWidth;

                  return Center(
                    child: Container(
                      width: tableWidth,
                      padding: const EdgeInsets.all(16),
                      child:
                          userStats.isEmpty
                              ? const Center(child: Text("No data found"))
                              : Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: tableWidth,
                                      ),
                                      child: DataTable(
                                        columnSpacing: 24,
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                              Colors.blue.shade100,
                                            ),
                                        headingTextStyle: GoogleFonts.notoSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        dataTextStyle: GoogleFonts.notoSans(
                                          fontSize: 13,
                                        ),
                                        columns: const [
                                          DataColumn(label: Text("SN")),
                                          DataColumn(label: Text("Name")),
                                          DataColumn(
                                            label: Text("Total Leads ❇️"),
                                          ),
                                          DataColumn(
                                            label: Text("This Month 📆"),
                                          ),
                                          DataColumn(
                                            label: Text("This Week 📅"),
                                          ),
                                          DataColumn(label: Text("Today 🕐")),
                                        ],
                                        rows: List.generate(userStats.length, (
                                          index,
                                        ) {
                                          final user = userStats[index];
                                          return DataRow(
                                            cells: [
                                              DataCell(Text("${index + 1}")),
                                              DataCell(
                                                Text(user['name'] ?? ''),
                                              ),
                                              DataCell(
                                                Text(
                                                  "${user['totalLeads'] ?? 0}",
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  "${user['monthLeads'] ?? 0}",
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  "${user['weekLeads'] ?? 0}",
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  "${user['todayLeads'] ?? 0}",
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  );
                },
              ),
    );
  }
}
