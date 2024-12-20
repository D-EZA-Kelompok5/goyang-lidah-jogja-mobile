// event_dashboard.dart

import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'event_form_dialog.dart';

class EventDashboard extends StatefulWidget {
  const EventDashboard({Key? key}) : super(key: key);

  @override
  _EventDashboardState createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  String _filter = 'all';
  List<Event> _events = [];
  bool _isLoading = true;
  late EventService eventService;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    eventService = EventService(request);
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      List<Event> events = await eventService.fetchEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optional: Display error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load events: $e')),
      );
    }
  }

  List<Event> get _filteredEvents {
    if (_filter == 'free') {
      return _events.where((event) => event.entranceFee == null).toList();
    } else if (_filter == 'paid') {
      return _events.where((event) => event.entranceFee != null).toList();
    }
    return _events;
  }

  void _openCreateModal() {
    showDialog(
      context: context,
      builder: (context) {
        return EventFormDialog(
          onSubmit: () async {
            setState(() {
              _isLoading = true;
            });
            await _fetchEvents();
          },
        );
      },
    );
  }

  void _handleEdit(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return EventFormDialog(
          event: event,
          onSubmit: () async {
            setState(() {
              _isLoading = true;
            });
            await _fetchEvents();
          },
        );
      },
    );
  }

  void _handleDelete(Event event) {
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
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                try {
                  await eventService.deleteEvent(event.id);
                  await _fetchEvents();
                } catch (e) {
                  // Optional: Display error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete event: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventRow(Event event) {
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Management Dashboard'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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