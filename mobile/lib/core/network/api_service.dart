import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'response': 'Server Error (${response.statusCode}): Could not process message.'
        };
      }
    } catch (e) {
      return {
        'response': 'Connection Error: Unable to connect to FastAPI backend.'
      };
    }
  }

  Future<Map<String, dynamic>> triggerEmergencyContact({
    required String patientId,
    required String logId,
    required String contactNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/emergency-trigger'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'patient_id': patientId,
          'log_id': logId,
          'contact_number': contactNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'status': 'ERROR',
          'message': 'Failed to send alert via server (${response.statusCode}).'
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Network Error: Backend unreachable.'
      };
    }
  }

  // Fetch all chat logs from SQLite DB via FastAPI
  Future<List<dynamic>> fetchChatLogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ai/logs'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  // Fetch all escalation records from SQLite DB via FastAPI
  Future<List<dynamic>> fetchEscalationLogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ai/escalations'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }
}