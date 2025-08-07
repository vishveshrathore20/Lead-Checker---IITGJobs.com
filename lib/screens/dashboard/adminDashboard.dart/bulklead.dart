import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/services/bulk_lead_service.dart';

class BulkLeadUploadScreen extends StatefulWidget {
  const BulkLeadUploadScreen({super.key});

  @override
  State<BulkLeadUploadScreen> createState() => _BulkLeadUploadScreenState();
}

class _BulkLeadUploadScreenState extends State<BulkLeadUploadScreen> {
  PlatformFile? selectedFile;
  bool isUploading = false;
  String? resultMessage;
  Color? messageColor;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.single;
        resultMessage = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (selectedFile == null) return;

    setState(() {
      isUploading = true;
      resultMessage = null;
    });

    try {
      final result = await BulkLeadService.uploadLeads(selectedFile!);
      setState(() {
        resultMessage =
            '✅ Uploaded: ${result['inserted']} inserted, ${result['duplicates']} duplicates';
        messageColor = Colors.green;
        selectedFile = null;
      });
    } catch (e) {
      setState(() {
        resultMessage = '❌ Upload failed: $e';
        messageColor = Colors.red;
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📤 Bulk Lead Upload'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.upload_file_rounded,
                  size: 60,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 20),
                if (selectedFile != null)
                  Text(
                    'Selected: ${selectedFile!.name}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Pick Excel File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed:
                      selectedFile == null || isUploading ? null : _uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    disabledBackgroundColor: Colors.deepPurple.shade200,
                  ),
                  child:
                      isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Upload'),
                ),
                const SizedBox(height: 30),
                if (resultMessage != null)
                  Text(
                    resultMessage!,
                    style: TextStyle(
                      color: messageColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
