import 'package:flutter/material.dart';
import 'package:frontend/services/industry_service.dart';

class IndustryScreen extends StatefulWidget {
  const IndustryScreen({super.key});

  @override
  State<IndustryScreen> createState() => _IndustryScreenState();
}

class _IndustryScreenState extends State<IndustryScreen> {
  List<dynamic> industries = [];
  int currentPage = 1;
  int totalCount = 0;
  final int limit = 10;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String? animatedIndustryId;

  @override
  void initState() {
    super.initState();
    fetchIndustries();
  }

  Future<void> fetchIndustries({bool reset = false}) async {
    if (reset) currentPage = 1;
    setState(() => isLoading = true);

    try {
      final data = await AdminService.getIndustries(
        page: currentPage,
        limit: limit,
      );
      final count = await AdminService.getIndustryCount();

      setState(() {
        industries = data['industries'];
        totalCount = count;
      });
    } catch (e) {
      showSnackbar('Error: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> searchIndustries() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      fetchIndustries(reset: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final results = await AdminService.searchIndustries(query);
      setState(() {
        industries = results;
        totalCount = results.length;
      });
    } catch (e) {
      showSnackbar('Search failed: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> addIndustry() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final newIndustry = await AdminService.addIndustry(name);
      showSnackbar('✅ Industry added!');
      nameController.clear();

      animatedIndustryId = newIndustry['_id'];
      fetchIndustries(reset: true);
    } catch (e) {
      showSnackbar('Add failed: $e');
    }
  }

  Future<void> updateIndustry(String id, String currentName) async {
    final controller = TextEditingController(text: currentName);

    final updatedName = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('✏️ Edit Industry'),
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
        await AdminService.updateIndustry(id, updatedName.trim());
        showSnackbar('✅ Updated successfully');
        fetchIndustries();
      } catch (e) {
        showSnackbar('Update failed: $e');
      }
    }
  }

  Future<void> deleteIndustry(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('🗑 Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this industry?',
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
        await AdminService.deleteIndustry(id);
        showSnackbar('🗑 Deleted successfully');
        fetchIndustries();
      } catch (e) {
        showSnackbar('Delete failed: $e');
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void goToPage(int page) {
    setState(() => currentPage = page);
    fetchIndustries();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalCount / limit).ceil();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.factory, color: Colors.indigo),
            const SizedBox(width: 10),
            const Text(
              'Industry Manager',
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.indigo),
            onPressed: () => fetchIndustries(reset: true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => searchIndustries(),
                    decoration: InputDecoration(
                      hintText: 'Search industries...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Add
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter new industry name',
                      prefixIcon: const Icon(Icons.add_business),
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
                  onPressed: addIndustry,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📊 Total Industries: $totalCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: industries.length,
                        itemBuilder: (_, index) {
                          final industry = industries[index];
                          final isNew = industry['_id'] == animatedIndustryId;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isNew ? Colors.green[50] : Colors.white,
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
                              title: Text(industry['name'] ?? ''),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed:
                                        () => updateIndustry(
                                          industry['_id'],
                                          industry['name'],
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => deleteIndustry(industry['_id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),
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
                              ? Colors.indigo
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
