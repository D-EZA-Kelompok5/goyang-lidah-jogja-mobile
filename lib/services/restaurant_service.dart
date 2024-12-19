// lib/services/restaurant_service.dart

import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/restaurant.dart';
import '../models/menu.dart';

class RestaurantService {
  final CookieRequest request;
  static const String baseUrl = 'http://127.0.0.1:8000/restaurant';

  RestaurantService(this.request);

  Future<List<Restaurant>> fetchUserRestaurants() async {
    try {
      final response = await request.get('$baseUrl/');
      if (response != null) {
        List<dynamic> restaurantsJson = response;
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
      final response = await request.get('$baseUrl/o/$id/');
      if (response != null) {
        return Restaurant.fromJson(response);
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
      String endpoint = '$baseUrl/o/$restaurantId/';
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
        '$baseUrl/$restaurantId/create-menu/',
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
      final response = await request.post(
        '$baseUrl/edit-menu/$menuId/',
        menuData,
      );
      return MenuElement.fromJson(response);
    } catch (e) {
      print('Error updating menu: $e');
      throw Exception('Failed to update menu: $e');
    }
  }

  Future<bool> deleteMenu(int menuId) async {
    try {
      await request.get('$baseUrl/delete-menu/$menuId/');
      return true;
    } catch (e) {
      print('Error deleting menu: $e');
      throw Exception('Failed to delete menu: $e');
    }
  }
}
