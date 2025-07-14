import 'package:flutter/material.dart';
import 'package:frontend/services/admin_service.dart';

class AddIndustry extends StatefulWidget {
  const AddIndustry({super.key});

  @override
  State<AddIndustry> createState() => _AddIndustryState();
}

class _AddIndustryState extends State<AddIndustry> {
  final TextEditingController _industryController = TextEditingController();
  List<dynamic> industries = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchIndustries();
  }

  Future<void> fetchIndustries() async {
    setState(() => isLoading = true);
    final result = await AdminService.getIndustries();
    setState(() {
      industries = result;
      isLoading = false;
    });
  }

  Future<void> addIndustry() async {
    final name = _industryController.text.trim();
    if (name.isEmpty) return;

    final success = await AdminService.addIndustry(name);
    if (success) {
      _industryController.clear();
      fetchIndustries();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Industry added")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed or already exists")));
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
        title: const Text('Add Industry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Industry Input Field
            TextField(
              controller: _industryController,
              decoration: InputDecoration(
                labelText: 'Industry Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Submit Button
            ElevatedButton(
              onPressed: addIndustry,
              child: const Text('Add Industry'),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Existing Industries:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Industry List
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: industries.length,
                        itemBuilder: (context, index) {
                          final industry = industries[index];
                          return ListTile(
                            leading: const Icon(Icons.business),
                            title: Text(industry['name']),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
