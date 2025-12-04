import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:levelup/models/university.dart';
import 'package:levelup/models/environnement.dart';

class UniversityService {
  final String baseUrl = Environnement().url;

  Future<List<University>> getAllUniversities() async {
    final url = Uri.parse('$baseUrl/universities/');

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> universitiesJson = responseBody;
      return universitiesJson.map((json) => University.fromJson(json)).toList();
    } else {
      throw Exception(responseBody['detail'] ?? 'Failed to fetch universities');
    }
  }
}
