import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';
import '../models/tag.dart';
import 'dart:convert';

class UserService {
  final CookieRequest request;
  static const baseUrl = 'https://vissuta-gunawan-goyanglidahjogja.pbp.cs.ui.ac.id';

  UserService(this.request);

  Future<UserProfile> fetchUserProfile() async {
    try {
      print('Fetching user profile from: $baseUrl/auth/profile/');
      
      // Menggunakan get karena ini endpoint GET
      final response = await request.get(
        '$baseUrl/auth/profile/',
      );

      print('Response: $response'); // Debug log

      if (response == null) {
        throw Exception('Empty response received');
      }

      // Tambahkan debug log untuk melihat struktur response
      print('Response type: ${response.runtimeType}');
      print('Response content: $response');

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Full error details: $e');
      if (e is FormatException) {
        // Cek apakah user sudah login
        if (!request.loggedIn) {
          throw Exception('User not logged in. Please login first.');
        }
      }
      rethrow;
    }
  }

  // Fungsi helper untuk mengecek login status
  bool get isLoggedIn => request.loggedIn;

  Future<void> updateUserProfile({
    required String username,
    required String bio,
    required String profilePicture,
    String? password,
  }) async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final data = {
      'username': username,
      'bio': bio,
      'profile_picture': profilePicture,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    final response = await request.post(
      '$baseUrl/edit_profile/json/',
      jsonEncode(data),
    );

    if (response == null || response['status'] != 'success') {
      throw Exception(response?['message'] ?? 'Failed to update profile');
    }
  }

  Future<List<TagElement>> fetchUserPreferences() async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final response = await request.get(
      '$baseUrl/userPreferences/api/preferences/',
    );

    if (response != null && response['status'] == 'success') {
      List<dynamic> data = response['data'];
      return data.map((json) => TagElement.fromJson(json)).toList();
    } else {
      throw Exception(response?['message'] ?? 'Failed to load user preferences');
    }
  }

  Future<void> updateUserPreferences(List<dynamic> selectedTagIds) async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final response = await request.post(
      '$baseUrl/userPreferences/api/preferences/',
      jsonEncode({
        'tag_ids': selectedTagIds,
      }),
    );

    if (response == null || response['status'] != 'success') {
      throw Exception(response?['message'] ?? 'Failed to update preferences');
    }
  }

  Future<List<TagElement>> fetchAllTags() async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final response = await request.get(
      '$baseUrl/userPreferences/api/tags/',
    );

    if (response != null && response['tags'] != null) {
      List<dynamic> tags = response['tags'];
      return tags.map((json) => TagElement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }
}