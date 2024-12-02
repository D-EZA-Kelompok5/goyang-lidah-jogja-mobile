import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'announcement_provider.dart';
import 'announcement.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
 // Pastikan ini benar sesuai lokasi file model Announcement Anda.


class AnnouncementPage extends StatefulWidget {
  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AnnouncementProvider>(context, listen: false);
    provider.fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.announcements.isEmpty) {
            return Center(child: Text("No announcements found."));
          }
          return ListView.builder(
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = provider.announcements[index];
              return AnnouncementTile(announcement: announcement);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModal(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showModal(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Announcement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              Provider.of<AnnouncementProvider>(context, listen: false)
                  .addAnnouncement(titleController.text, messageController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
