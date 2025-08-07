import 'package:flutter/material.dart';

class NewLeadEntryScreen extends StatefulWidget {
  const NewLeadEntryScreen({super.key});

  @override
  State<NewLeadEntryScreen> createState() => _NewLeadEntryScreenState();
}

class _NewLeadEntryScreenState extends State<NewLeadEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController productLineController = TextEditingController();
  final TextEditingController turnOverController = TextEditingController();
  final TextEditingController employeeStrengthController =
      TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController industryTypeController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    designationController.dispose();
    mobileController.dispose();
    emailController.dispose();
    locationController.dispose();
    remarksController.dispose();
    divisionController.dispose();
    productLineController.dispose();
    turnOverController.dispose();
    employeeStrengthController.dispose();
    companyNameController.dispose();
    industryTypeController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Submitting lead...')));
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        validator:
            (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 New Lead Entry'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Left Panel (Form)
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField('Company Name', companyNameController),
                    buildTextField('Industry Type', industryTypeController),
                    buildTextField('HR Name', nameController),
                    buildTextField('Designation', designationController),
                    buildTextField(
                      'Mobile Number',
                      mobileController,
                      inputType: TextInputType.phone,
                    ),
                    buildTextField(
                      'Email',
                      emailController,
                      inputType: TextInputType.emailAddress,
                    ),
                    buildTextField('Current Location', locationController),
                    buildTextField('Remarks', remarksController, maxLines: 2),
                    const Divider(height: 30),
                    buildTextField('Division', divisionController),
                    buildTextField('Product Line', productLineController),
                    buildTextField('Turn Over', turnOverController),
                    buildTextField(
                      'Employee Strength',
                      employeeStrengthController,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: handleSubmit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Panel (Dynamic Data Placeholder)
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text(
                  '📊 Dynamic Data Will Appear Here',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
