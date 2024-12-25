// event_service.dart

import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';

class EventService {
  final CookieRequest request;

  EventService(this.request);

  Future<List<Event>> fetchEvents() async {
    final response = await request.get(
      'http://10.0.2.2:8000/event_manager/events_json/',
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response['status'] == 'success') {
        List<dynamic> data = response['events'];
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load events: ${response['message']}');
      }
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> createEvent(Event event) async {
    final response = await request.postJson(
      'http://10.0.2.2:8000/event_manager/create-event-flutter/',
      jsonEncode(event.toJson()),
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response['status'] != 'success') {
        throw Exception('Failed to create event: ${response['message']}');
      }
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<void> updateEvent(Event event) async {
    final response = await request.postJson(
      'http://10.0.2.2:8000/event_manager/update-event-flutter/${event.id}/',
      jsonEncode(event.toJson()),
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response['status'] != 'success') {
        throw Exception('Failed to update event: ${response['message']}');
      }
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final url = 'http://10.0.2.2:8000/event_manager/delete-event-flutter/$eventId/';

    // Prepare data to mimic DELETE action via POST
    final data = {
      'action': 'delete',
    };

    // Use postJson to send a POST request for deletion
    final response = await request.postJson(
      url,
      jsonEncode(data),
    );

    if (response != null && response is Map<String, dynamic>) {
      if (response['status'] != 'success') {
        throw Exception('Failed to delete event: ${response['message']}');
      }
    } else {
      throw Exception('Failed to delete event');
    }
  }
}