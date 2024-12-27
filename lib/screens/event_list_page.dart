// lib/screens/event_list_page.dart

import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:goyang_lidah_jogja/services/event_service.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
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
      List<Event> events = await eventService.fetchAllEvents();  // Changed to fetchAllEvents
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
  }

  List<Event> get _filteredEvents {
    if (_filter == 'free') {
      return _events.where((event) => event.entranceFee == null || event.entranceFee == 0).toList();
    } else if (_filter == 'paid') {
      return _events.where((event) => event.entranceFee != null && event.entranceFee! > 0).toList();
    }
    return _events;
  }

  Widget _buildEventCard(Event event) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Event Icon Section
          const SizedBox(
            height: 100,
            child: ColoredBox(
              color: Colors.grey,
              child: Center(
                child: Icon(Icons.event, size: 32, color: Colors.white),
              ),
            ),
          ),
          
          // Event Details Section
          // Event Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left, // Explicit left alignment
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4), // Increased spacing after title
                  
                  // Rest of the widgets with smaller text
                  Text(
                    DateFormat('MMM d').format(event.date),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  
                  Text(
                    event.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                  
                  Flexible(
                    child: Text(
                      event.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  Text(
                    event.entranceFee != null && event.entranceFee! > 0
                        ? 'Rp${event.entranceFee!.toStringAsFixed(0)}'
                        : 'Free',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
          ),
          Expanded(
            child: _filteredEvents.isNotEmpty
                ? GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      childAspectRatio: 0.7, // Adjusted ratio
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_filteredEvents[index]);
                    },
                  )
                : const Center(
                    child: Text('No events available'),
                  ),
          ),
        ],
      ),
    );
  }
}
