// lib/services/auth_service.dart

import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/user_profile.dart';

class AuthService {
  final CookieRequest request;

  AuthService(this.request);

  Future<UserProfile?> getUserProfile() async {
    final response = await request.get("http://10.0.2.2:8000/auth/profile/");
    if (response != null && response['user_id'] != null) {
      return UserProfile.fromJson(response);
    } else {
      // Handle error, misalnya tampilkan pesan atau log
      return null;
    }
  }
}
