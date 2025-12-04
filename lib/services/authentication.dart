import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../models/environnement.dart';

class AuthService {
  final String baseUrl = Environnement().url;
  final _storage = const FlutterSecureStorage();

  Future<void> _saveTokens(String access, String refresh, User user) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    await _storage.write(key: 'user', value: jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user');
  }

  // In AuthService
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int universityId,
  }) async {
    final url = Uri.parse('$baseUrl/register/');
    final body = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
      "first_name": firstName,
      "last_name": lastName,
      "university_id": universityId,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final access = responseBody['access'];
      final refresh = responseBody['refresh'];

      final userJson = responseBody['user'];

      final user = User.fromJson(userJson);
      await _saveTokens(access, refresh, user);

      return responseBody;
    } else {
      throw Exception(responseBody['detail'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login/');
    final body = jsonEncode({"email": email, "password": password});

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final access = responseBody['access'];
      final refresh = responseBody['refresh'];

      final userJson = responseBody['user'];

      final user = User.fromJson(userJson);
      await _saveTokens(access, refresh, user);

      return {"user": user, "access": access, "refresh": refresh};
    } else {
      throw Exception(responseBody['detail'] ?? 'Login failed');
    }
  }
}
