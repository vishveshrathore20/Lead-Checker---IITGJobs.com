import 'package:flutter/material.dart';
import 'package:frontend/services/company_service.dart';

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  List<dynamic> companies = [];
  int currentPage = 1;
  int totalCount = 0;
  final int limit = 10;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String? animatedCompanyId;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies({bool reset = false}) async {
    if (reset) currentPage = 1;
    setState(() => isLoading = true);

    try {
      final data = await CompanyService.getCompanies(
        page: currentPage,
        limit: limit,
      );
      final count = await CompanyService.getCompanyCount();

      setState(() {
        companies = data['companies'];
        totalCount = count;
      });
    } catch (e) {
      showSnackbar('Error: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> searchCompanies() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      fetchCompanies(reset: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final results = await CompanyService.searchCompanies(query);
      setState(() {
        companies = results;
        totalCount = results.length;
      });
    } catch (e) {
      showSnackbar('Search failed: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> addCompany() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final newCompany = await CompanyService.addCompany(name);
      showSnackbar('✅ Company added!');
      nameController.clear();

      animatedCompanyId = newCompany['_id'];
      fetchCompanies(reset: true);
    } catch (e) {
      showSnackbar('Add failed: $e');
    }
  }

  Future<void> updateCompany(String id, String currentName) async {
    final controller = TextEditingController(text: currentName);

    final updatedName = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('✏️ Edit Company'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Update'),
              ),
            ],
          ),
    );

    if (updatedName != null && updatedName.trim().isNotEmpty) {
      try {
        await CompanyService.updateCompany(id, updatedName.trim());
        showSnackbar('✅ Updated successfully');
        fetchCompanies();
      } catch (e) {
        showSnackbar('Update failed: $e');
      }
    }
  }

  Future<void> deleteCompany(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('🗑 Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this company?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await CompanyService.deleteCompany(id);
        showSnackbar('🗑 Deleted successfully');
        fetchCompanies();
      } catch (e) {
        showSnackbar('Delete failed: $e');
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void goToPage(int page) {
    setState(() => currentPage = page);
    fetchCompanies();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / limit).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏢 Company Management'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search companies...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: searchCompanies,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    searchController.clear();
                    fetchCompanies(reset: true);
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: "Reset",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'New Company Name',
                      prefixIcon: const Icon(Icons.business_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: addCompany,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📊 Total Companies: $totalCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: companies.length,
                        itemBuilder: (_, index) {
                          final company = companies[index];
                          final isNew = company['_id'] == animatedCompanyId;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isNew ? Colors.green[100] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(company['name']),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => updateCompany(
                                          company['_id'],
                                          company['name'],
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => deleteCompany(company['_id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),

            // Pagination
            if (!isLoading && totalPages > 1)
              Wrap(
                spacing: 6,
                children: List.generate(totalPages, (i) {
                  final page = i + 1;
                  return ElevatedButton(
                    onPressed: () => goToPage(page),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          currentPage == page
                              ? Colors.deepPurple
                              : Colors.grey[300],
                      foregroundColor:
                          currentPage == page ? Colors.white : Colors.black,
                    ),
                    child: Text('$page'),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
