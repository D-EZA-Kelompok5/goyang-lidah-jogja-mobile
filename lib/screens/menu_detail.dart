// lib/screens/menu_detail_page.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/menu.dart';
import 'package:goyang_lidah_jogja/models/review.dart';
import 'package:goyang_lidah_jogja/screens/submit_review.dart'; // Import halaman Submit Review
import 'package:goyang_lidah_jogja/screens/restaurant_detail_menu.dart';
import 'package:goyang_lidah_jogja/services/restaurant_service.dart';
import 'package:goyang_lidah_jogja/services/review_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuElement menu;
  final String username;

  const MenuDetailPage({
    Key? key,
    required this.menu,
    required this.username,
  }) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  late RestaurantService restaurantService;
  late ReviewService reviewService;
  List<ReviewElement> reviews = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi RestaurantService dan ReviewService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final baseUrl = 'http://127.0.0.1:8000/'; // Ganti sesuai lingkungan Anda
      setState(() {
        restaurantService = RestaurantService(request);
        reviewService = ReviewService(request, baseUrl);
      });
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews() async {
    try {
      final reviewsData = await reviewService.fetchReviews(widget.menu.id);
      setState(() {
        reviews = reviewsData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars(); // Hapus SnackBar lama
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ulasan: $e')),
      );
    }
  }

  Future<void> _navigateToRestaurant(BuildContext context) async {
    try {
      final restaurant =
          await restaurantService.fetchRestaurantDetail(widget.menu.restaurant.id);
      if (restaurant != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailPage(
              restaurantId: restaurant.id,
              isOwner: false,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars(); // Hapus SnackBar lama
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detail restoran tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars(); // Hapus SnackBar lama
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail restoran: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Menu: ${widget.menu.name}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              // Wishlist logic placeholder
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Details Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.menu.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.menu.image!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.menu.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      InkWell(
                        onTap: () => _navigateToRestaurant(context),
                        child: Text(
                          widget.menu.restaurant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Rp ${widget.menu.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Description Section
            Text(
              widget.menu.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),

            // Tags Section
            if (widget.menu.tagIds != null && widget.menu.tagIds!.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: widget.menu.tagIds!.map((tagId) {
                  return Chip(
                    label: Text('Tag ID: $tagId'),
                    backgroundColor: Colors.grey[200],
                    labelStyle: const TextStyle(color: Colors.black),
                  );
                }).toList(),
              )
            else
              const Text(
                'No tags available',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 16.0),

            // Restaurant Information Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.menu.restaurant.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Reviews Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ulasan Pengguna',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (reviews.isNotEmpty)
                      ...reviews.map((review) => ListTile(
                            leading: CircleAvatar(
                              child: Text(review.user.isNotEmpty
                                  ? review.user[0].toUpperCase()
                                  : '?'),
                            ),
                            title: Text(review.user),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rating: ${review.rating}'),
                                Text(review.comment),
                                Text(
                                  'Dibuat pada: ${review.createdAt.toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                if (review.lastEdited != null)
                                  Text(
                                    'Diedit pada: ${review.lastEdited!.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ))
                    else
                      const Text(
                        'Belum ada ulasan.',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Submit Review Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.username == "GUEST") {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anda harus login untuk memberikan ulasan.'),
                      ),
                    );
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitReviewPage(
                          menuId: widget.menu.id,
                          username: widget.username,
                        ),
                      ),
                    );

                    if (result == true) {
                      // Jika ulasan berhasil dikirim, fetch ulang ulasan
                      _fetchReviews();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Ulas Goyangan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
