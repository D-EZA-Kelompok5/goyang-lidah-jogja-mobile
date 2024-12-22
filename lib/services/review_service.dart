// lib/services/review_service.dart

import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/models/review.dart'; // Pastikan path ini sesuai
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  final CookieRequest request;
  final String baseUrl;

  ReviewService(this.request, this.baseUrl);

  /// Mengirim ulasan baru
  Future<Map<String, dynamic>> submitReview(int menuId, int rating, String comment) async {
    final url = '$baseUrl/ulasGoyangan/submit_review/$menuId/';
    final response = await request.post(
      url,
      {
        'rating': rating.toString(), // Pastikan rating dikirim sebagai string
        'comment': comment,
      },
    );

    if (response.containsKey('message')) {
      return response;
    } else {
      throw Exception(response['error'] ?? 'Gagal mengirim ulasan');
    }
  }

  /// Mengambil daftar ulasan untuk sebuah menu
  Future<List<ReviewElement>> fetchReviews(int menuId) async {
    final url = '$baseUrl/ulasGoyangan/menu/$menuId/comments/';
    final response = await request.get(url);

    if (response.containsKey('reviews')) {
      List<dynamic> reviewsJson = response['reviews'];
      List<ReviewElement> reviews = reviewsJson.map((json) => ReviewElement.fromJson(json)).toList();
      return reviews;
    } else {
      throw Exception(response['error'] ?? 'Gagal mengambil ulasan');
    }
  }

   /// Mengedit ulasan yang sudah ada menggunakan POST dengan form-encoded data
  Future<Map<String, dynamic>> editReview(int reviewId, int rating, String comment) async {
    final url = '$baseUrl/ulasGoyangan/edit_review/$reviewId/';
    
    final response = await request.post(
      url,
      {
        'rating': rating.toString(),
        'comment': comment,
      },
    );

    if (response.containsKey('message')) {
      return response;
    } else {
      throw Exception(response['error'] ?? 'Gagal mengedit ulasan');
    }
  }
}
