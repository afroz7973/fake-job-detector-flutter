import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/job_prediction.dart';

class ApiService {
  static const String _tokenKey = 'access_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> get _headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> register(
    String email,
    String name,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'name': name, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['access'] != null) {
      await saveToken(data['access']);
      return true;
    }
    return false;
  }

  Future<AnalysisResult> analyzePost(
    String title,
    String content,
    String source,
  ) async {
    final headers = await _headers;
    final response = await http.post(
      Uri.parse(ApiConstants.analyze),
      headers: headers,
      body: jsonEncode({'title': title, 'content': content, 'source': source}),
    );
    if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    }
    return AnalysisResult.fromJson(jsonDecode(response.body));
  }

  Future<List<dynamic>> fetchHistory() async {
    final headers = await _headers;
    final response = await http.get(
      Uri.parse(ApiConstants.history),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
