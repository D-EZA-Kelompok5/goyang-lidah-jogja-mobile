// lib/services/wishlist_service.dart

import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/wishlist.dart';

class WishlistService {
  final CookieRequest request;

  WishlistService(this.request);

  Future<List<WishlistElement>> fetchWishlists() async {
    final response = await request.get('http://127.0.0.1:8000/wishlist/json');

    // Cetak data yang di-fetch untuk debugging
    print("Raw response: $response");

    if (response == null) {
      throw Exception('Failed to load wishlists: response is null');
    }

    if (response is Map<String, dynamic>) {
      if (response.containsKey('wishlists')) {
        Wishlist wishlist = Wishlist.fromJson(response);
        // Cetak data setelah parsing
        print("Parsed wishlists: ${wishlist.toJson()}");
        return wishlist.wishlists;
      } else {
        throw Exception('Response does not contain "wishlists" key');
      }
    } else {
      throw Exception('Unexpected response format');
    }
  }

  Future<void> createWishlist(WishlistElement wishlist) async {
    final data = {
      "menu_id": wishlist.menu.id,
      "catatan": wishlist.catatan,
      "status": wishlist.status,
    };

    final response = await request.postJson(
      'http://127.0.0.1:8000/wishlist/create-wishlist-flutter/',
      jsonEncode(data),
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to create wishlist: invalid response');
    }

    if (response['status'] != 'success') {
      throw Exception(
          'Failed to create wishlist: ${response['message'] ?? 'unknown error'}');
    }
  }

  Future<void> updateWishlist(WishlistElement wishlist) async {
    final data = {
      "menu_id": wishlist.menu.id,
      "catatan": wishlist.catatan,
      "status": wishlist.status,
    };

    final url =
        'http://127.0.0.1:8000/wishlist/update-wishlist-flutter/${wishlist.id}/';
    final response = await request.postJson(
      url,
      jsonEncode(data),
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to update wishlist: invalid response');
    }

    if (response['status'] != 'success') {
      throw Exception(
          'Failed to update wishlist: ${response['message'] ?? 'unknown error'}');
    }
  }

  Future<void> deleteWishlist(int wishlistId) async {
    final url =
        'http://127.0.0.1:8000/wishlist/delete-wishlist-flutter/$wishlistId/';

    final data = {
      'action': 'delete',
    };

    final response = await request.postJson(
      url,
      jsonEncode(data),
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to delete wishlist: invalid response');
    }

    if (response['status'] != 'success') {
      throw Exception(
          'Failed to delete wishlist: ${response['message'] ?? 'unknown error'}');
    }
  }
}
