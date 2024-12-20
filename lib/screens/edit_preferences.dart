import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditPreferencesScreen extends StatefulWidget {
  const EditPreferencesScreen({Key? key}) : super(key: key);

  @override
  _EditPreferencesScreenState createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends State<EditPreferencesScreen> {
  List<TagElement> _allTags = [];
  List<int?> _selectedTags = [];
  bool _isLoading = true;
  late CookieRequest request;
  late UserService userService;

  @override
  void initState() {
    super.initState();
    _fetchTagsAndPreferences();
  }

  Future<void> _fetchTagsAndPreferences() async {
    request = Provider.of<CookieRequest>(context, listen: false);
    userService = UserService(request);
    try {
      List<TagElement> tags = await userService.fetchAllTags();
      List<TagElement> userPreferences =
          await userService.fetchUserPreferences();
      setState(() {
        _allTags = tags;
        _selectedTags = userPreferences.map((tag) => tag.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await userService.updateUserPreferences(_selectedTags);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Preferences')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ..._allTags.map((tag) {
            return CheckboxListTile(
              title: Text(tag.name),
              value: _selectedTags.contains(tag.id),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedTags.add(tag.id);
                  } else {
                    _selectedTags.remove(tag.id);
                  }
                });
              },
            );
          }).toList(),
          ElevatedButton(
            onPressed: _updatePreferences,
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}
