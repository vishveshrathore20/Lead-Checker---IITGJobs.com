import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/hr_service.dart';

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
  List<dynamic> hrList = [];

  final hrName = TextEditingController();
  final hrDesignation = TextEditingController();
  final hrMobile = TextEditingController();
  final hrEmail = TextEditingController();
  final hrRemarks = TextEditingController();

  bool isLoading = true;
  bool isHrLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      industries = await HrService.fetchIndustries();
    } catch (_) {
      _showSnackbar("Failed to load industries", isError: true);
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchCompanies(String industryId) async {
    try {
      companies = await HrService.fetchCompanies(industryId);
      setState(() {});
    } catch (_) {
      _showSnackbar("Failed to load companies", isError: true);
    }
  }

  Future<void> _fetchHRList(String industryId, String companyId) async {
    setState(() => isHrLoading = true);
    try {
      hrList = await HrService.fetchHrList(industryId, companyId);
    } catch (_) {
      _showSnackbar("Failed to fetch HR data", isError: true);
    }
    setState(() => isHrLoading = false);
  }

  Future<void> _submitHR() async {
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

    try {
      final response = await HrService.submitHr(payload);
      if (response.statusCode == 201) {
        _showSnackbar("✅ HR Added Successfully");
        _clearForm();
      } else {
        final body = jsonDecode(response.body);
        if (body['message']?.toLowerCase().contains("already exists") == true) {
          _showDuplicateModal();
        } else {
          _showSnackbar("❌ Failed to add HR", isError: true);
        }
      }
    } catch (_) {
      _showSnackbar("❌ Something went wrong", isError: true);
    }
  }

  void _clearForm() {
    hrName.clear();
    hrDesignation.clear();
    hrMobile.clear();
    hrEmail.clear();
    hrRemarks.clear();
    setState(() {
      selectedIndustryId = null;
      selectedCompanyId = null;
      companies.clear();
      hrList.clear();
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDuplicateModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Duplicate HR Entry",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "An HR with this mobile number already exists.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("OK", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(color: Colors.indigo),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.indigo),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        floatingLabelStyle: const TextStyle(color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.indigo),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildHRCardGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hrList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final hr = hrList[index];
        final name = hr['name'] ?? 'No Name';
        final designation = hr['designation'] ?? 'No Designation';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      designation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "New Lead Entry",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedIndustryId,
                      decoration: _dropdownDecoration("Select Industry"),
                      items:
                          industries
                              .map<DropdownMenuItem<String>>(
                                (industry) => DropdownMenuItem<String>(
                                  value: industry['_id'] as String,
                                  child: Text(industry['name']),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedIndustryId = val;
                          selectedCompanyId = null;
                          companies.clear();
                          hrList.clear();
                        });
                        if (val != null) _fetchCompanies(val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCompanyId,
                      decoration: _dropdownDecoration("Select Company"),
                      items:
                          companies
                              .map<DropdownMenuItem<String>>(
                                (company) => DropdownMenuItem<String>(
                                  value: company['_id'] as String,
                                  child: Text(company['name']),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() => selectedCompanyId = val);
                        if (selectedIndustryId != null && val != null) {
                          _fetchHRList(selectedIndustryId!, val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField("HR Name", hrName),
                    const SizedBox(height: 12),
                    _buildTextField("Designation", hrDesignation),
                    const SizedBox(height: 12),
                    _buildTextField(
                      "Mobile",
                      hrMobile,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      "Email",
                      hrEmail,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Remarks", hrRemarks),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _submitHR,
                        icon: const Icon(Icons.add),
                        label: const Text("Add HR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isHrLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (hrList.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            "No HR data available for selected Industry & Company.",
                          ),
                        ),
                      )
                    else
                      _buildHRCardGrid(),
                  ],
                ),
              ),
    );
  }
}
