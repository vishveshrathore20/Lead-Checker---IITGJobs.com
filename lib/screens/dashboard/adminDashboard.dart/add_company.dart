import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({super.key});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? selectedIndustryId;
  List<Map<String, dynamic>> industries = [];
  List<Map<String, dynamic>> companies = [];
  List<Map<String, dynamic>> filteredCompanies = [];
  bool isLoading = false;
  int currentPage = 0;
  final int perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadIndustries();
    _searchController.addListener(_filterCompanies);
  }

  Future<void> _loadIndustries() async {
    setState(() => isLoading = true);
    industries = await AdminService.getIndustries();

    if (industries.length == 1) {
      selectedIndustryId = industries.first['_id'];
      await _loadCompanies();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-selected Industry: ${industries.first['name']}'),
        ),
      );
    } else if (selectedIndustryId == null && industries.isNotEmpty) {
      selectedIndustryId = industries.first['_id'];
      await _loadCompanies();
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadCompanies() async {
    if (selectedIndustryId != null) {
      companies = await AdminService.getCompanies(); // All companies
      _filterCompanies();
    }
  }

  void _filterCompanies() {
    final query = _searchController.text.toLowerCase();
    filteredCompanies =
        companies.where((company) {
          final name = company['name']?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
    currentPage = 0;
    setState(() {});
  }

  List<Map<String, dynamic>> get paginatedCompanies {
    final start = currentPage * perPage;
    final end = (start + perPage).clamp(0, filteredCompanies.length);
    return filteredCompanies.sublist(start, end);
  }

  Future<void> _addCompany() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || selectedIndustryId == null) return;

    final success = await AdminService.addCompany(name, selectedIndustryId!);
    if (success) {
      _nameController.clear();
      await _loadCompanies();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Company added")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed or duplicate company")),
      );
    }
  }

  Future<void> _deleteCompany(String id) async {
    final success = await AdminService.deleteCompany(id);
    if (success) {
      await _loadCompanies();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("🗑️ Company deleted")));
    }
  }

  void _editCompanyDialog(Map<String, dynamic> company) {
    final controller = TextEditingController(text: company['name']);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Company"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "New Company Name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final updated = controller.text.trim();
                  if (updated.isNotEmpty) {
                    final success = await AdminService.updateCompany(
                      company['_id'],
                      updated,
                    );
                    if (success) {
                      Navigator.pop(context);
                      await _loadCompanies();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✏️ Company updated")),
                      );
                    }
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group paginated companies
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var company in paginatedCompanies) {
      final industry = company['industry']?['name'] ?? 'Unknown';
      grouped.putIfAbsent(industry, () => []).add(company);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Company"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/adminDashboard');
          },
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Add company input
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Industry dropdown
                    DropdownButtonFormField<String>(
                      value: selectedIndustryId,
                      decoration: const InputDecoration(
                        labelText: 'Select Industry',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          industries.map((industry) {
                            return DropdownMenuItem<String>(
                              value: industry['_id'],
                              child: Text(industry['name']),
                            );
                          }).toList(),
                      onChanged: (value) async {
                        selectedIndustryId = value;
                        await _loadCompanies();
                      },
                    ),
                    const SizedBox(height: 12),

                    // Add button
                    ElevatedButton.icon(
                      onPressed: _addCompany,
                      icon: const Icon(Icons.add_business),
                      label: const Text("Add Company"),
                    ),

                    const Divider(),

                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search companies...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grouped paginated companies
                    Expanded(
                      child:
                          grouped.isEmpty
                              ? const Center(child: Text("No companies found."))
                              : ListView(
                                children:
                                    grouped.entries.map((entry) {
                                      return ExpansionTile(
                                        title: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        children:
                                            entry.value.map((company) {
                                              return ListTile(
                                                leading: const CircleAvatar(
                                                  child: Icon(Icons.apartment),
                                                ),
                                                title: Text(company['name']),
                                                subtitle: Text(
                                                  'Industry: ${company['industry']?['name'] ?? 'Unknown'}',
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                      onPressed:
                                                          () =>
                                                              _editCompanyDialog(
                                                                company,
                                                              ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed:
                                                          () => _deleteCompany(
                                                            company['_id'],
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      );
                                    }).toList(),
                              ),
                    ),

                    // Pagination controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed:
                              currentPage > 0
                                  ? () => setState(() => currentPage--)
                                  : null,
                          child: const Text('Previous'),
                        ),
                        Text('Page ${currentPage + 1}'),
                        TextButton(
                          onPressed:
                              (currentPage + 1) * perPage <
                                      filteredCompanies.length
                                  ? () => setState(() => currentPage++)
                                  : null,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
