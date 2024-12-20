import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';
import 'dart:convert';

class UserService {
  final CookieRequest request;

  UserService(this.request);

  Future<UserProfile> fetchUserProfile() async {
    final response = await request.get('http://127.0.0.1:8000/edit_profile/json/');

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
      'http://127.0.0.1:8000/edit_profile/json/',
      jsonEncode({
        'data': data,
        'headers': {'Content-Type': 'application/json'},
      }),
    );

    if (response['status'] != 'success') {
      throw Exception(response['message'] ?? 'Gagal memperbarui profil');
    }
  }
}