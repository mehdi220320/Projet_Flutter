import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:levelup/models/environnement.dart';
import 'package:levelup/models/internship_demand.dart';
import 'package:levelup/services/authentication.dart';

class InternshipDemandService {
  final String _baseUrl = Environnement().url;
  final http.Client client;

  InternshipDemandService({http.Client? client})
    : client = client ?? http.Client();

  Future<List<InternshipDemand>> getMyDemands() async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.get(
        Uri.parse('$_baseUrl/internship-demands/my_demands'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => InternshipDemand.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint not found');
      } else {
        throw Exception('Failed to load demands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // NEW: Create demand with just application_id
  Future<InternshipDemand> createSimpleDemand({
    required int applicationId,
  }) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.post(
        Uri.parse('$_baseUrl/internship-demands/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: json.encode({'application_id': applicationId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InternshipDemand.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        throw Exception(
          'Bad request: Invalid application ID or already exists',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Application not found');
      } else {
        throw Exception('Failed to create demand: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Keep the old method for backward compatibility
  Future<InternshipDemand> createDemand({
    required String university,
    required int applicationId,
    required String offerTitle,
  }) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.post(
        Uri.parse('$_baseUrl/internship-demands/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          'application_id': applicationId,
          // Include other fields if needed by your backend
          'university': university,
          'offer_title': offerTitle,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InternshipDemand.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: Invalid data');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to create demand: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> requestAttestation(int demandId) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.post(
        Uri.parse(
          '$_baseUrl/internship-demands/$demandId/request_attestation/',
        ),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Cannot request attestation for this demand');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == 404) {
        throw Exception('Demand not found');
      } else {
        throw Exception(
          'Failed to request attestation: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<InternshipDemand> updateDemandStatus(
    int demandId,
    String status,
  ) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.patch(
        Uri.parse('$_baseUrl/internship-demands/$demandId/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InternshipDemand.fromJson(jsonData);
      } else {
        throw Exception('Failed to update demand: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteDemand(int demandId) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.delete(
        Uri.parse('$_baseUrl/internship-demands/$demandId/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete demand: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  void dispose() {
    client.close();
  }
  // Add these methods to InternshipDemandService class

  Future<void> generateConvention(int demandId) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.post(
        Uri.parse(
          '$_baseUrl/internship-demands/$demandId/generate_convention/',
        ),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - convention generated
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Cannot generate convention for this demand');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Demand not found');
      } else {
        throw Exception(
          'Failed to generate convention: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> generateLetter(int demandId) async {
    try {
      final token = await AuthService().getAccessToken();

      final response = await client.post(
        Uri.parse('$_baseUrl/internship-demands/$demandId/generate_letter/'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success - letter generated
        return;
      } else if (response.statusCode == 400) {
        throw Exception('Cannot generate letter for this demand');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Demand not found');
      } else {
        throw Exception('Failed to generate letter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
