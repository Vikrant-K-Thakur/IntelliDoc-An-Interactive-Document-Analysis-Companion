import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:docuverse/models/document_model.dart';
import 'package:docuverse/models/flashcard_model.dart';
import 'package:docuverse/models/study_plan_model.dart';

class ApiService {
  static final String? _baseUrl = dotenv.env['API_BASE_URL'];

  static Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Future<Document> uploadDocument(File file, String title) async {
    final uri = Uri.parse('$_baseUrl/documents/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['title'] = title;

    final headers = await _getHeaders();
    request.headers.addAll(headers);

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return Document.fromMap(jsonResponse['data']);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to upload document');
    }
  }

  static Future<String> summarizeDocument(String documentId) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId/summarize');
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonResponse['data']['summary'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to summarize document');
    }
  }

  static Future<String> chatWithDocument(String documentId, String question) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId/chat');
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'question': question}),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonResponse['data']['answer'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to get answer');
    }
  }

  static Future<List<Flashcard>> generateFlashcards(String documentId) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId/flashcards');
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (jsonResponse['data'] as List)
          .map((item) => Flashcard.fromMap(item))
          .toList();
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to generate flashcards');
    }
  }

  static Future<String> getVoiceSummary(String documentId, String language) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId/voice-summary');
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'language': language}),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonResponse['data']['audioUrl'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to generate voice summary');
    }
  }

  static Future<StudyPlan> generateStudyPlan(String documentId) async {
    final uri = Uri.parse('$_baseUrl/documents/$documentId/study-plan');
    final headers = await _getHeaders();

    final response = await http.get(uri, headers: headers);
    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return StudyPlan.fromMap(jsonResponse['data']);
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to generate study plan');
    }
  }

  static Future<String> translateText(String text, String targetLanguage) async {
    final uri = Uri.parse('$_baseUrl/translate');
    final headers = await _getHeaders();

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'text': text,
        'target_language': targetLanguage,
      }),
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonResponse['data']['translated_text'];
    } else {
      throw Exception(jsonResponse['message'] ?? 'Failed to translate text');
    }
  }
}