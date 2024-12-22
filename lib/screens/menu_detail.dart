// lib/screens/menu_detail_page.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/menu.dart';
import 'package:goyang_lidah_jogja/models/review.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';
import 'package:goyang_lidah_jogja/models/wishlist.dart';
import 'package:goyang_lidah_jogja/screens/submit_review.dart';
import 'package:goyang_lidah_jogja/screens/edit_review.dart'; // Import halaman Edit Review
import 'package:goyang_lidah_jogja/screens/restaurant_detail_menu.dart';
import 'package:goyang_lidah_jogja/services/restaurant_service.dart';
import 'package:goyang_lidah_jogja/services/review_service.dart';
import 'package:goyang_lidah_jogja/services/wishlist_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuElement menu;
  final String username;
  final WishlistService wishlistService;
  final Map<int, int> wishlistIds;
  final Function refreshWishlist;
  final UserProfile? userProfile;

  const MenuDetailPage({
    Key? key,
    required this.menu,
    required this.username,
    required this.wishlistService,
    required this.wishlistIds,
    required this.refreshWishlist,
    this.userProfile,
  }) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  late RestaurantService restaurantService;
  late ReviewService reviewService;
  List<ReviewElement> reviews = [];
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.wishlistIds.containsKey(widget.menu.id);

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
      ScaffoldMessenger.of(context).clearSnackBars();
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
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detail restoran tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail restoran: $e')),
      );
    }
  }

  MenuItem menuElementToMenuItem(MenuElement menuElement) {
    return MenuItem(
      id: menuElement.id,
      name: menuElement.name,
      description: menuElement.description,
      price: menuElement.price.toDouble(),
      image: menuElement.image ?? '',
      restaurantName: menuElement.restaurant.name,
    );
  }

  Future<void> _toggleWishlist() async {
    try {
      if (_isInWishlist) {
        final wishlistId = widget.wishlistIds[widget.menu.id];
        if (wishlistId != null) {
          await widget.wishlistService.deleteWishlist(
              wishlistId, widget.wishlistService.request);
          setState(() {
            _isInWishlist = false;
            widget.wishlistIds.remove(widget.menu.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.menu.name} dihapus dari wishlist.')),
          );
        }
      } else {
        final wishlistId = await widget.wishlistService.createWishlist(
          WishlistElement(
            id: 0,
            menu: menuElementToMenuItem(widget.menu),
            catatan: '',
            status: 'BELUM',
          ),
        );
        setState(() {
          _isInWishlist = true;
          widget.wishlistIds[widget.menu.id] = wishlistId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.menu.name} ditambahkan ke wishlist.')),
        );
      }
      widget.refreshWishlist();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
          if (widget.userProfile != null &&
              widget.userProfile!.role == Role.CUSTOMER &&
              widget.wishlistService.request.loggedIn)
            IconButton(
              icon: Icon(
                _isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _toggleWishlist,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.menu.image ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.menu.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
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
            SizedBox(height: 8.0),
            Text(
              'Rp ${widget.menu.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              widget.menu.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
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
            SizedBox(height: 16.0),
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
                    SizedBox(height: 8.0),
                    Text(
                      widget.menu.restaurant.address,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
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
                    SizedBox(height: 16.0),
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
                                if (review.lastEdited != null)
                                  Text(
                                    'Diedit pada: ${review.lastEdited!.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                else
                                  Text(
                                    'Dibuat pada: ${review.createdAt.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: (widget.username == review.user)
                                ? IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditReviewPage(
                                            reviewId: review.id,
                                            menuId: widget.menu.id,
                                            initialRating: review.rating,
                                            initialComment: review.comment,
                                            onReviewEdited: _fetchReviews,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          ))
                    else
                      const Text(
                        'Belum ada ulasan.',
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.username == "GUEST") {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Anda harus login untuk memberikan ulasan.'),
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
                      _fetchReviews();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
