import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewLeadsScreen extends StatefulWidget {
  const NewLeadsScreen({super.key});

  @override
  State<NewLeadsScreen> createState() => _NewLeadsScreenState();
}

class _NewLeadsScreenState extends State<NewLeadsScreen> {
  String? selectedIndustryId;
  String? selectedCompanyId;

  List<dynamic> industries = [];
  List<dynamic> companies = [];

  final hrName = TextEditingController();
  final hrDesignation = TextEditingController();
  final hrMobile = TextEditingController();
  final hrEmail = TextEditingController();
  final hrRemarks = TextEditingController();

  String token = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadToken();
    await _fetchIndustries();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('authToken') ?? '';
    print("🔑 Loaded Token: $token");
  }

  Future<void> _fetchIndustries() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/industries'),
    );
    if (response.statusCode == 200) {
      setState(() {
        industries = json.decode(response.body);
      });
    } else {
      print("❌ Failed to fetch industries");
    }
  }

  Future<void> _fetchCompanies(String industryId) async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/companies/$industryId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        companies = json.decode(response.body);
      });
    } else {
      print("❌ Failed to fetch companies");
    }
  }

  Future<void> _submitHR() async {
    if (token.isEmpty) {
      await _loadToken(); // Ensure token is available
      if (token.isEmpty) {
        _showSnackbar("Token not found. Please log in again.", isError: true);
        return;
      }
    }

    if (selectedIndustryId == null || selectedCompanyId == null) {
      _showSnackbar("Please select Industry and Company", isError: true);
      return;
    }

    final payload = {
      "name": hrName.text,
      "designation": hrDesignation.text,
      "mobile": hrMobile.text,
      "email": hrEmail.text,
      "remarks": hrRemarks.text,
      "industryId": selectedIndustryId,
      "companyId": selectedCompanyId,
    };

    print("📤 Sending HR Data: ${jsonEncode(payload)}");
    print("🔑 Token: $token");

    final response = await http.post(
      Uri.parse("http://localhost:3000/api/hr"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      _showSnackbar("✅ HR Added Successfully");
      hrName.clear();
      hrDesignation.clear();
      hrMobile.clear();
      hrEmail.clear();
      hrRemarks.clear();
      setState(() {
        selectedIndustryId = null;
        selectedCompanyId = null;
        companies.clear();
      });
    } else {
      print("❌ Failed: ${response.statusCode} - ${response.body}");
      _showSnackbar("❌ Failed to add HR", isError: true);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Lead Entry",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedIndustryId,
              decoration: _dropdownDecoration("Select Industry"),
              items:
                  industries.map<DropdownMenuItem<String>>((industry) {
                    return DropdownMenuItem(
                      value: industry['_id'],
                      child: Text(industry['name']),
                    );
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedIndustryId = val;
                  selectedCompanyId = null;
                  companies.clear();
                });
                if (val != null) _fetchCompanies(val);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCompanyId,
              decoration: _dropdownDecoration("Select Company"),
              items:
                  companies.map<DropdownMenuItem<String>>((company) {
                    return DropdownMenuItem(
                      value: company['_id'],
                      child: Text(company['name']),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => selectedCompanyId = val),
            ),
            const SizedBox(height: 16),
            _buildTextField("HR Name", hrName),
            const SizedBox(height: 12),
            _buildTextField("Designation", hrDesignation),
            const SizedBox(height: 12),
            _buildTextField("Mobile", hrMobile, type: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField("Email", hrEmail, type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField("Remarks", hrRemarks),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add HR"),
              onPressed: _submitHR,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
