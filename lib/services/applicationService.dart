import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:levelup/models/environnement.dart';
import 'package:levelup/services/authentication.dart';
import 'package:levelup/models/application.dart';

class Applicationservice {
  final String baseUrl = Environnement().url;

  Future<Map<String, dynamic>> register({required String offer_id}) async {
    final token = await AuthService().getAccessToken();

    final url = Uri.parse('$baseUrl/applications/');
    final body = jsonEncode({"offer_id": offer_id});

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: body,
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final message = responseBody['message'];
      final user = responseBody['user'];
      final offer = responseBody['offer'];
      final predicted_fit = responseBody['predicted_fit'];

      return {
        "message": message,
        "user": user,
        "offer": offer,
        "predicted_fit": predicted_fit,
      };
    } else {
      throw Exception(responseBody['detail'] ?? 'Application failed');
    }
  }

  Future<List<Application>> getMyApplications() async {
    final token = await AuthService().getAccessToken();
    final url = Uri.parse('$baseUrl/applications/my_applications');

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> applicationsJson = jsonDecode(response.body);
      final List<Application> applications = applicationsJson
          .map((json) => Application.fromJson(json))
          .toList();

      return applications;
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['detail'] ?? 'Get Applications failed');
    }
  }
}
