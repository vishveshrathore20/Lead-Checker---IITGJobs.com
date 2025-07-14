import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Leads extends StatefulWidget {
  const Leads({super.key});

  @override
  State<Leads> createState() => _LeadsState();
}

class _LeadsState extends State<Leads> {
  List<dynamic> leads = [];
  List<dynamic> industries = [];
  List<String> designations = [];

  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;

  String? selectedIndustryId;
  String? selectedDesignation;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIndustries();
    fetchLeads();
  }

  Future<void> _loadIndustries() async {
    industries = await AdminService.getIndustries();
    setState(() {});
  }

  Future<void> fetchLeads() async {
    setState(() => isLoading = true);
    try {
      final data = await AdminService.getFilteredLeads(
        page: currentPage,
        industryId: selectedIndustryId,
        designation: selectedDesignation,
        search: _searchController.text,
        startDate: startDate,
        endDate: endDate,
      );

      leads = data['leads'];
      totalPages = (data['total'] / 10).ceil();
      designations =
          leads
              .map<String>((e) => e['designation']?.toString() ?? '')
              .where((d) => d.isNotEmpty)
              .toSet()
              .toList();
    } catch (e) {
      debugPrint("Error fetching leads: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      startDate = picked.start;
      endDate = picked.end;
      currentPage = 1;
      await fetchLeads();
    }
  }

  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Leads'];
    sheet.appendRow([
      "Name",
      "Designation",
      "Mobile",
      "Email",
      "Location",
      "Company",
      "Industry",
      "Date",
    ]);
    for (var lead in leads) {
      final mobile =
          lead['mobile'] is List
              ? (lead['mobile'] as List).join(', ')
              : lead['mobile'] ?? '';
      sheet.appendRow([
        lead['name'] ?? '',
        lead['designation'] ?? '',
        mobile,
        lead['email'] ?? '',
        lead['location'] ?? '',
        lead['company']?['name'] ?? '',
        lead['industry']?['name'] ?? '',
        DateFormat.yMd().format(DateTime.parse(lead['createdAt'])),
      ]);
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/leads.xlsx');
    await file.writeAsBytes(excel.encode()!);
    Share.shareXFiles([XFile(file.path)], text: 'Exported Leads Excel');
  }

  void _clearFilters() {
    setState(() {
      selectedIndustryId = null;
      selectedDesignation = null;
      startDate = null;
      endDate = null;
      _searchController.clear();
      currentPage = 1;
    });
    fetchLeads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Leads"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportExcel,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // 🔍 Filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedIndustryId,
                            decoration: const InputDecoration(
                              labelText: 'Industry',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                industries.map<DropdownMenuItem<String>>((
                                  industry,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: industry['_id'],
                                    child: Text(industry['name']),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedIndustryId = val;
                                currentPage = 1;
                              });
                              fetchLeads();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedDesignation,
                            decoration: const InputDecoration(
                              labelText: 'Designation',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                designations.map((d) {
                                  return DropdownMenuItem<String>(
                                    value: d,
                                    child: Text(d),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedDesignation = val;
                                currentPage = 1;
                              });
                              fetchLeads();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          tooltip: "Date Range",
                          onPressed: _selectDateRange,
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: "Clear Filters",
                          onPressed: _clearFilters,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search by Name,Mobile .... ",
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        currentPage = 1;
                        fetchLeads();
                      },
                    ),
                    const SizedBox(height: 10),

                    // 📋 Table-like Data
                    Expanded(
                      child:
                          leads.isEmpty
                              ? const Center(child: Text("No leads found."))
                              : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('SN')),
                                    DataColumn(label: Text('Name')),
                                    DataColumn(label: Text('Designation')),
                                    DataColumn(label: Text('Mobile')),
                                    DataColumn(label: Text('Email')),
                                    DataColumn(label: Text('Location')),
                                    DataColumn(label: Text('Industry')),
                                    DataColumn(label: Text('Company')),
                                    DataColumn(label: Text('Date')),
                                  ],
                                  rows: List.generate(leads.length, (index) {
                                    final lead = leads[index];
                                    final mobile =
                                        lead['mobile'] is List
                                            ? (lead['mobile'] as List).join(
                                              ', ',
                                            )
                                            : lead['mobile'] ?? '';
                                    return DataRow(
                                      cells: [
                                        DataCell(Text('${index + 1}')),
                                        DataCell(Text(lead['name'] ?? '')),
                                        DataCell(
                                          Text(lead['designation'] ?? ''),
                                        ),
                                        DataCell(Text(mobile)),
                                        DataCell(Text(lead['email'] ?? '')),
                                        DataCell(Text(lead['location'] ?? '')),
                                        DataCell(
                                          Text(lead['industry']?['name'] ?? ''),
                                        ),
                                        DataCell(
                                          Text(lead['company']?['name'] ?? ''),
                                        ),
                                        DataCell(
                                          Text(
                                            DateFormat.yMMMd().format(
                                              DateTime.parse(lead['createdAt']),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                    ),

                    // 📄 Pagination
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              currentPage > 1
                                  ? () {
                                    setState(() => currentPage--);
                                    fetchLeads();
                                  }
                                  : null,
                          child: const Text("Previous"),
                        ),
                        Text("Page $currentPage of $totalPages"),
                        TextButton(
                          onPressed:
                              currentPage < totalPages
                                  ? () {
                                    setState(() => currentPage++);
                                    fetchLeads();
                                  }
                                  : null,
                          child: const Text("Next"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
