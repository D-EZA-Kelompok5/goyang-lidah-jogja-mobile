// lib/screens/edit_profile.dart

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/screens/edit_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  late CookieRequest request;
  late UserService userService;

  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request = Provider.of<CookieRequest>(context, listen: false);
    userService = UserService(request);
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    
    try {
      UserProfile userProfile = await userService.fetchUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _usernameController.text = _userProfile!.username;
          _bioController.text = _userProfile!.bio;
          _profilePictureController.text = _userProfile!.profilePicture ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userProfile = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _profilePictureController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await userService.updateUserProfile(
        username: _usernameController.text,
        bio: _bioController.text,
        profilePicture: _profilePictureController.text,
        password:
            _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      // Periksa apakah widget masih mounted sebelum memanggil setState dan Navigator.pop
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, true); // Kirim hasil sukses ke halaman sebelumnya
    } catch (e) {
      // Periksa apakah widget masih mounted sebelum memanggil setState
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      readOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Gagal memuat profil.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserProfile,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Text(
              'Edit Profile',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Profile Form
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Current Profile Picture Preview
                    Center(
                      child: Column(
                        children: [
                          if (_profilePictureController.text.isNotEmpty)
                            CircleAvatar(
                              radius: 48,
                              backgroundImage:
                                  NetworkImage(_profilePictureController.text),
                            )
                          else
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                _userProfile!.username
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                            ),
                          const SizedBox(height: 8),
                          const Text(
                            'Current Profile Picture',
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Username
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        labelStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Profile Picture URL
                    TextField(
                      controller: _profilePictureController,
                      decoration: const InputDecoration(
                        labelText: 'Profile Picture URL',
                        labelStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                        helperText:
                            'Enter a valid image URL (e.g., https://example.com/image.jpg)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        labelStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Bio
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        labelStyle:
                            TextStyle(fontWeight: FontWeight.bold),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Role (Read-only)
                    _buildReadOnlyField('Role', _userProfile!.roleDisplay),
                    const SizedBox(height: 16),
                    // Level (For Customers)
                    if (_userProfile!.role == Role.CUSTOMER) ...[
                      _buildReadOnlyField(
                          'Level', _userProfile!.levelDisplay),
                      const SizedBox(height: 16),
                    ],
                    // Restaurant Information (For Restaurant Owners)
                    if (_userProfile!.role == Role.RESTAURANT_OWNER &&
                        _userProfile!.ownedRestaurant != null) ...[
                      _buildReadOnlyField('Owned Restaurant',
                          _userProfile!.ownedRestaurant!.name),
                      const SizedBox(height: 16),
                    ],
                    // Edit Preferences and Save Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditPreferencesScreen()),
                            );
                          },
                          child: const Text('Edit Preferences'),
                        ),
                        ElevatedButton(
                          onPressed: _updateUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}