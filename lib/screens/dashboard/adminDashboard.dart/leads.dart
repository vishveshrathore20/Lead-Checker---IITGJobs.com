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
  List<dynamic> users = [];
  List<dynamic> companies = [];
  List<String> designations = [];

  int currentPage = 1;
  int totalPages = 1;
  bool isLoading = false;

  String? selectedIndustryId;
  String? selectedUserId;
  String? selectedCompanyId;
  String? selectedDesignation;
  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFilters();
    fetchLeads();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterScrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    industries = await AdminService.getIndustries();
    users = await AdminService.getUsers();
    companies = await AdminService.getCompanies();
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
        userId: selectedUserId,
        companyId: selectedCompanyId,
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
      selectedUserId = null;
      selectedCompanyId = null;
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
                userId: selectedUserId,
                companyId: selectedCompanyId,
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
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Filters
                        Scrollbar(
                          controller: _filterScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _filterScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildDropdown(
                                  label: "Industry",
                                  value: selectedIndustryId,
                                  items: industries,
                                  getLabel: (i) => i['name'],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedIndustryId = val;
                                      currentPage = 1;
                                    });
                                    fetchLeads();
                                  },
                                ),
                                _buildDropdown(
                                  label: "Company",
                                  value: selectedCompanyId,
                                  items: companies,
                                  getLabel: (c) => c['name'],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCompanyId = val;
                                      currentPage = 1;
                                    });
                                    fetchLeads();
                                  },
                                ),
                                _buildDropdown(
                                  label: "Lead Generator",
                                  value: selectedUserId,
                                  items: users,
                                  getLabel: (u) => u['name'],
                                  onChanged: (val) {
                                    setState(() {
                                      selectedUserId = val;
                                      currentPage = 1;
                                    });
                                    fetchLeads();
                                  },
                                ),
                                _buildSimpleDropdown(
                                  label: "Designation",
                                  value: selectedDesignation,
                                  options: designations,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedDesignation = val;
                                      currentPage = 1;
                                    });
                                    fetchLeads();
                                  },
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
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Search
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

                        // Table
                        Expanded(
                          child:
                              leads.isEmpty
                                  ? const Center(child: Text("No leads found."))
                                  : Scrollbar(
                                    controller: _tableScrollController,
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: _tableScrollController,
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

                        // Pagination
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required String Function(dynamic) getLabel,
    required void Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items:
            items.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['_id'],
                child: Text(getLabel(item), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSimpleDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items:
            options
                .map(
                  (opt) => DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
