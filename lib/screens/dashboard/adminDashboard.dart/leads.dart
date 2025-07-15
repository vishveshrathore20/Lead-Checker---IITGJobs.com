import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/services/admin_service.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            tooltip: "Export to Excel",
            onPressed: () {
              AdminService.downloadExcel(
                context: context,
                industryId: selectedIndustryId,
                designation: selectedDesignation,
                search: _searchController.text,
                startDate: startDate,
                endDate: endDate,
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // 🔍 Filters Section
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: isWide ? 200 : double.infinity,
                                maxWidth: isWide ? 250 : double.infinity,
                              ),
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
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: isWide ? 200 : double.infinity,
                                maxWidth: isWide ? 250 : double.infinity,
                              ),
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
                            ElevatedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: const Text("Date Range"),
                              onPressed: _selectDateRange,
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.clear),
                              label: const Text("Clear"),
                              onPressed: _clearFilters,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 🔎 Search
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: "Search by Name, Mobile ...",
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) {
                            currentPage = 1;
                            fetchLeads();
                          },
                        ),
                        const SizedBox(height: 10),

                        // 📋 Data Table
                        Expanded(
                          child:
                              leads.isEmpty
                                  ? const Center(child: Text("No leads found."))
                                  : Scrollbar(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('SN')),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(
                                            label: Text('Designation'),
                                          ),
                                          DataColumn(label: Text('Mobile')),
                                          DataColumn(label: Text('Email')),
                                          DataColumn(label: Text('Location')),
                                          DataColumn(label: Text('Industry')),
                                          DataColumn(label: Text('Company')),
                                          DataColumn(label: Text('Date')),
                                        ],
                                        rows: List.generate(leads.length, (
                                          index,
                                        ) {
                                          final lead = leads[index];
                                          final mobile =
                                              lead['mobile'] is List
                                                  ? (lead['mobile'] as List)
                                                      .join(', ')
                                                  : lead['mobile'] ?? '';
                                          return DataRow(
                                            cells: [
                                              DataCell(Text('${index + 1}')),
                                              DataCell(
                                                Text(lead['name'] ?? ''),
                                              ),
                                              DataCell(
                                                Text(lead['designation'] ?? ''),
                                              ),
                                              DataCell(Text(mobile)),
                                              DataCell(
                                                Text(lead['email'] ?? ''),
                                              ),
                                              DataCell(
                                                Text(lead['location'] ?? ''),
                                              ),
                                              DataCell(
                                                Text(
                                                  lead['industry']?['name'] ??
                                                      '',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  lead['company']?['name'] ??
                                                      '',
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  DateFormat.yMMMd().format(
                                                    DateTime.parse(
                                                      lead['createdAt'],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
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
                  );
                },
              ),
    );
  }
}
