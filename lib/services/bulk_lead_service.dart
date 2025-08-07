import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

class BulkLeadService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<Map<String, dynamic>> uploadLeads(PlatformFile file) async {
    final uri = Uri.parse('$baseUrl/api/admin/leads/bulk');

    final request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      if (file.bytes == null) {
        throw Exception('File data is missing');
      }
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
        contentType: MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
      request.files.add(multipartFile);
    } else {
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path!,
        contentType: MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Upload failed');
    }
  }
}
