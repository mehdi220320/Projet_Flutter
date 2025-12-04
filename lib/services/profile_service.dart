import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:levelup/models/certification.dart';
import 'package:levelup/models/profile.dart';
import 'package:levelup/models/environnement.dart';
import 'package:levelup/models/skill.dart';
import 'package:levelup/services/authentication.dart';

class ProfileService {
  final String baseUrl = Environnement().url;

  Future<Profile> getMyProfile() async {
    final url = Uri.parse('$baseUrl/profiles/my-profile/');
    final token = await AuthService().getAccessToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Profile.fromJson(responseBody);
    } else {
      throw Exception(responseBody['detail'] ?? 'Failed to fetch profile');
    }
  }

  Future<Profile> updateProfile({
    String? fieldOfStudy,
    List<String>? skills,
    List<String>? certifications,
  }) async {
    final url = Uri.parse('$baseUrl/profiles/update-my-profile/');
    final token = await AuthService().getAccessToken();

    final Map<String, dynamic> data = {};
    if (fieldOfStudy != null) data['field_of_study'] = fieldOfStudy;
    if (skills != null) data['skills'] = skills;
    if (certifications != null) data['certifications'] = certifications;

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Profile.fromJson(responseBody);
    } else {
      throw Exception(responseBody['detail'] ?? 'Failed to update profile');
    }
  }

  Future<List<Skill>> getAllSkills() async {
    final url = Uri.parse('$baseUrl/skills/');
    final token = await AuthService().getAccessToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> skillsJson = responseBody;
      return skillsJson.map((json) => Skill.fromJson(json)).toList();
    } else {
      throw Exception(responseBody['detail'] ?? 'Failed to fetch skills');
    }
  }

  Future<List<Certification>> getAllCertifications() async {
    final url = Uri.parse('$baseUrl/certifications/');
    final token = await AuthService().getAccessToken();

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> certsJson = responseBody;
      return certsJson.map((json) => Certification.fromJson(json)).toList();
    } else {
      throw Exception(
        responseBody['detail'] ?? 'Failed to fetch certifications',
      );
    }
  }
}
