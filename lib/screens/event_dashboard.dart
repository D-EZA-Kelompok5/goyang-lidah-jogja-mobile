// screens/event_dashboard.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/user_profile.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({super.key});

  @override
  _EventDashboardState createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  String _filter = 'all';
  Event _eventData = Event(events: [
    EventElement(
      id: 1,
      title: 'Music Concert',
      description: 'A great music concert.',
      date: DateTime(2023, 10, 10),
      time: '18:00',
      location: 'Jakarta',
      entranceFee: 50.0,
      image: null,
      createdBy: UserProfile(
        userId: 1,
        username: 'event_manager',
        email: 'manager@example.com',
        role: Role.EVENT_MANAGER, // Menggunakan enum Role
        bio: 'Managing awesome events!',
        reviewCount: 10,
        level: Level.GOLD, // Menggunakan enum Level
        preferences: null,
      ),
    ),
    EventElement(
      id: 2,
      title: 'Art Exhibition',
      description: 'Exhibition of modern art.',
      date: DateTime(2023, 11, 5),
      time: '10:00',
      location: 'Bandung',
      entranceFee: null,
      image: null,
      createdBy: UserProfile(
        userId: 2,
        username: 'artist_owner',
        email: 'owner@example.com',
        role: Role.EVENT_MANAGER, // Menggunakan enum Role
        bio: 'Passionate about art.',
        reviewCount: 5,
        level: Level.SILVER, // Menggunakan enum Level
        preferences: null,
      ),
    ),
    // Tambahkan lebih banyak data dummy sesuai kebutuhan
  ]);

  List<EventElement> get _filteredEvents {
    if (_filter == 'free') {
      return _eventData.events.where((event) => event.entranceFee == null).toList();
    } else if (_filter == 'paid') {
      return _eventData.events.where((event) => event.entranceFee != null).toList();
    }
    return _eventData.events;
  }

  void _openCreateModal() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Create New Event'),
          content: Text('Event creation form goes here.'),
        );
      },
    );
  }

  void _handleEdit(EventElement event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event: ${event.title}'),
          content: const Text('Event editing form goes here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete(EventElement event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Event: ${event.title}?'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _eventData.events.remove(event);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventRow(EventElement event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${event.date.toLocal().toIso8601String().split('T')[0]} at ${event.time}'),
            Text(event.location),
            Text(event.entranceFee != null ? 'Rp${event.entranceFee}' : 'Free'),
            Text('Created by: ${event.createdBy.username}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.indigo),
              onPressed: () => _handleEdit(event),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _handleDelete(event),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with filter and create button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Filter by Price: '),
                    DropdownButton<String>(
                      value: _filter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Events')),
                        DropdownMenuItem(value: 'free', child: Text('Free Events')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid Events')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filter = value!;
                        });
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _openCreateModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Create New Event'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Events List
            Expanded(
              child: _filteredEvents.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        return _buildEventRow(_filteredEvents[index]);
                      },
                    )
                  : const Center(child: Text('No events found. Click "Create New Event" to add one.')),
            ),
          ],
        ),
      ),
    );
  }
}