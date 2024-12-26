import 'package:flutter/material.dart';
import '../models/tag.dart';
import '../services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditPreferencesScreen extends StatefulWidget {
  final List<int?> initialTags;
  
  const EditPreferencesScreen({
    Key? key, 
    required this.initialTags,
  }) : super(key: key);

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
    _selectedTags = List.from(widget.initialTags);
    _fetchTagsAndPreferences();
  }

  Future<void> _fetchTagsAndPreferences() async {
    request = Provider.of<CookieRequest>(context, listen: false);
    userService = UserService(request);
    try {
      List<TagElement> tags = await userService.fetchAllTags();
      setState(() {
        _allTags = tags;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tags: $e')),
        );
      }
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
      Navigator.pop(context, _selectedTags);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating preferences: $e')),
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
      appBar: AppBar(
        title: const Text('Edit Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePreferences,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Select your food preferences:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._allTags.map((tag) {
                  return Card(
                    child: CheckboxListTile(
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
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                ),
                onPressed: _updatePreferences,
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}