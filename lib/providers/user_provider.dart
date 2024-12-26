import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/tag.dart';
import '../services/user_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  UserProfile? _userProfile;
  List<TagElement> _userPreferences = [];
  bool _isLoading = true;
  String? _errorMessage;

  UserProvider(CookieRequest request) : _userService = UserService(request) {
    _initializeUser();
  }

  UserProfile? get userProfile => _userProfile;
  List<TagElement> get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Getter to access CookieRequest from UserService
  CookieRequest get request => _userService.request;

  Future<void> _initializeUser() async {
    print("Initializing UserProvider...");
    try {
      if (!_userService.request.loggedIn) {
        print("User not logged in");
        _isLoading = false;
        _userProfile = null;
        notifyListeners();
        return;
      }

      _userProfile = await _userService.fetchUserProfile();
      print("UserProfile fetched: $_userProfile");
      
      _userPreferences = await _userService.fetchUserPreferences();
      print("UserPreferences fetched: $_userPreferences");
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error in _initializeUser: $e");
      _errorMessage = e.toString();
      _isLoading = false;
      _userProfile = null;
      notifyListeners();
    }
  }

  /// Method to refresh user profile and preferences
  Future<void> refreshUserProfile() async {
    await _initializeUser();
  }

  Future<void> updateUserProfile({
    required String username,
    required String bio,
    required String profilePicture,
    String? password,
  }) async {
    try {
      await _userService.updateUserProfile(
        username: username,
        bio: bio,
        profilePicture: profilePicture,
        password: password,
      );
      await _initializeUser();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserPreferences(List<int?> selectedTagIds) async {
    try {
      await _userService.updateUserPreferences(selectedTagIds);
      _userPreferences = await _userService.fetchUserPreferences();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _userService.request.logout('https://vissuta-gunawan-goyanglidahjogja.pbp.cs.ui.ac.id/auth/logout/');
      _userProfile = null;
      _userPreferences = [];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<TagElement>> fetchAllTags() async {
    try {
      return await _userService.fetchAllTags();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
}