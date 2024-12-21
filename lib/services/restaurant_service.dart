// lib/services/restaurant_service.dart

import 'dart:convert';

import 'package:goyang_lidah_jogja/models/announcement.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/restaurant.dart';
import '../models/menu.dart';

class RestaurantService {
  final CookieRequest request;
  static const String baseUrl = 'http://127.0.0.1:8000/restaurant';

  RestaurantService(this.request);

  Future<List<Restaurant>> fetchUserRestaurants() async {
    try {
      final response = await request.get('$baseUrl/api/');
      if (response != null && response['restaurants'] != null) {
        List<dynamic> restaurantsJson = response['restaurants'];
        return restaurantsJson
            .map((json) => Restaurant.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching restaurants: $e');
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  Future<Restaurant?> fetchRestaurantDetail(int id) async {
    try {
      final response = await request.get('$baseUrl/api/o/$id/');
      if (response != null && response['restaurant'] != null) {
        return Restaurant.fromJson(response['restaurant']);
      }
      return null;
    } catch (e) {
      print('Error fetching restaurant detail: $e');
      throw Exception('Failed to fetch restaurant detail: $e');
    }
  }

  // Menu Operations
  Future<List<MenuElement>> fetchRestaurantMenus(
      int restaurantId, String filter) async {
    try {
      String endpoint = '$baseUrl/api/o/$restaurantId/';
      if (filter != 'all') {
        endpoint += '?menu_filter=$filter';
      }
      final response = await request.get(endpoint);
      if (response != null && response['menus'] != null) {
        List<dynamic> menusJson = response['menus'];
        return menusJson.map((json) => MenuElement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching menus: $e');
      throw Exception('Failed to fetch menus: $e');
    }
  }

  Future<MenuElement> createMenu(
      int restaurantId, Map<String, dynamic> menuData) async {
    try {
      final response = await request.post(
        '$baseUrl/$restaurantId/create-menu/api/',
        menuData,
      );
      return MenuElement.fromJson(response);
    } catch (e) {
      print('Error creating menu: $e');
      throw Exception('Failed to create menu: $e');
    }
  }

  Future<MenuElement> updateMenu(
      int menuId, Map<String, dynamic> menuData) async {
    try {
      // Convert the data to JSON string
      String jsonData = json.encode(menuData);

      final response = await request.post(
        '$baseUrl/edit-menu/$menuId/api/',
        jsonData, // Send the JSON string instead of Map
      );

      if (response == null) {
        throw Exception('No response received');
      }

      if (response['status'] == 'success') {
        return MenuElement.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Failed to update menu');
      }
    } catch (e) {
      print('Error updating menu: $e');
      rethrow;
    }
  }

  Future<bool> deleteMenu(int menuId) async {
    try {
      // Use post instead of delete since CookieRequest doesn't have delete method
      final response = await request.post('$baseUrl/delete-menu/$menuId/api/',
          {'_method': 'DELETE'} // Indicate this is a DELETE request
          );

      if (response is Map<String, dynamic>) {
        return response['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error deleting menu: $e');
      throw Exception('Failed to delete menu: $e');
    }
  }

  Future<List<AnnouncementElement>> fetchAnnouncements(int restaurantId,
      {String filter = 'newest'}) async {
    try {
      String endpoint = '$baseUrl/$restaurantId/announcements/';

      // Add filter parameter
      endpoint += '?announcement_filter=$filter';

      final response = await request.get(endpoint);

      if (response != null &&
          response['status'] == 'success' &&
          response['announcements'] != null) {
        List<dynamic> announcementsJson = response['announcements'];
        return announcementsJson
            .map((json) => AnnouncementElement.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  Future<AnnouncementElement> createAnnouncement(
      int restaurantId, Map<String, dynamic> data) async {
    final jsonData =
        jsonEncode({'title': data['title'], 'message': data['message']});
    try {
      final response = await request.post(
        '$baseUrl/announcement/$restaurantId/create/',
        jsonData,
      );

      print('Created announcement: $response');

      if (response == null || !response.containsKey('announcement')) {
        throw Exception('Invalid response format');
      }

      return AnnouncementElement.fromJson(response['announcement']);
    } catch (e) {
      print('Error creating announcement: $e');
      throw Exception('Failed to create announcement: $e');
    }
  }

  Future<AnnouncementElement> updateAnnouncement(
      int announcementId, Map<String, dynamic> data) async {
    final jsonData =
        jsonEncode({'title': data['title'], 'message': data['message']});
    try {
      final response = await request.post(
          '$baseUrl/announcement/$announcementId/edit/', jsonData);

      print('Edited announcement: $response');

      if (response == null || !response.containsKey('announcement')) {
        throw Exception('Invalid response format');
      }

      return AnnouncementElement.fromJson(response['announcement']);
    } catch (e) {
      print('Error updating announcement: $e');
      throw Exception('Failed to update announcement: $e');
    }
  }

  Future<bool> deleteAnnouncement(int announcementId) async {
    try {
      final response =
          await request.get('$baseUrl/announcement/$announcementId/delete/');

      if (response == null) {
        throw Exception('No response received');
      }

      return response['status'] == 'success';
    } catch (e) {
      print('Error deleting announcement: $e');
      throw Exception('Failed to delete announcement: $e');
    }
  }
}
