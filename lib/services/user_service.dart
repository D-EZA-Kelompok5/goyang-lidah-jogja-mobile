import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';
import '../models/tag.dart';
import 'dart:convert';

class UserService {
  final CookieRequest request;

  UserService(this.request);

  final String baseUrl = 'http://127.0.0.1:8000';

  Future<UserProfile> fetchUserProfile() async {
    final response = await request.get('$baseUrl/edit_profile/json/');

    if (response['status'] == 'success') {
      return UserProfile.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Gagal mengambil data profil');
    }
  }

  Future<void> updateUserProfile({
    required String username,
    required String bio,
    required String profilePicture,
    String? password,
  }) async {
    final data = {
      'username': username,
      'bio': bio,
      'profile_picture': profilePicture,
    };

    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }

    final response = await request.post(
      '$baseUrl/edit_profile/json/',
      jsonEncode({
        'data': data,
        'headers': {'Content-Type': 'application/json'},
      }),
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Gagal memperbarui profil');
    }
  }

  // Fetch user preferences (GET)
  Future<List<TagElement>> fetchUserPreferences() async {
    final response = await request.get('$baseUrl/userPreferences/api/preferences/');

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      return data.map((json) => TagElement.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load user preferences');
    }
  }

  // Update user preferences (POST)
  Future<void> updateUserPreferences(List<int> selectedTagIds) async {
    final data = selectedTagIds;
    final response = await request.post(
      '$baseUrl/userPreferences/api/preferences/',
      jsonEncode({
        'data': data,
        'headers': {'Content-Type': 'application/json'},
      }),
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Failed to update preferences');
    }
  }

  // Fetch all tags
  Future<List<TagElement>> fetchAllTags() async {
    final response = await request.get('$baseUrl/userPreferences/api/tags/');
    if (response['tags'] != null) {
      return List<TagElement>.from(
          response['tags'].map((x) => TagElement.fromJson(x)));
    } else {
      throw Exception('Failed to load tags');
    }
  }
}