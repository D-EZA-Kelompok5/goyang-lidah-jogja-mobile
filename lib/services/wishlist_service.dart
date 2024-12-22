import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/wishlist.dart';

class WishlistService {
  final CookieRequest request;

  WishlistService(this.request);

  Future<List<WishlistElement>> fetchWishlists(CookieRequest request) async {
    final response = await request.get('https://127.0.0.1:8000/wishlist/json');

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to load wishlists: response is invalid');
    }

    if (!response.containsKey('wishlists')) {
      throw Exception('Response does not contain "wishlists" key');
    }

    // Parse wishlists
    List<dynamic> wishlistsData = response['wishlists'];
    return wishlistsData.map((data) => WishlistElement.fromJson(data)).toList();
  }


  Future<int> createWishlist(WishlistElement wishlist) async {
    final data = {
      "menu_id": wishlist.menu.id,
      "catatan": wishlist.catatan,
      "status": wishlist.status,
    };

    final response = await request.postJson(
      'https://127.0.0.1:8000/wishlist/create-wishlist-flutter/',
      jsonEncode(data),
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Failed to create wishlist: invalid response');
    }

    if (response['status'] != 'success') {
      throw Exception(
          'Failed to create wishlist: ${response['message'] ?? 'unknown error'}');
    }
    return response['id'];
  }

  Future<void> updateWishlist(WishlistElement wishlist) async {
    final data = {
      "menu_id": wishlist.menu.id,
      "catatan": wishlist.catatan,
      "status": wishlist.status,
    };

    final url =
        'https://127.0.0.1:8000/wishlist/update-wishlist-flutter/${wishlist.id}/';
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

  Future<void> deleteWishlist(int wishlistId, CookieRequest request) async {
    final url =
        'https://127.0.0.1:8000/wishlist/delete-wishlist-flutter/$wishlistId/';

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
