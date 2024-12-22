import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/menu.dart';
import 'package:goyang_lidah_jogja/models/review.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';
import 'package:goyang_lidah_jogja/models/wishlist.dart';
import 'package:goyang_lidah_jogja/screens/submit_review.dart';
import 'package:goyang_lidah_jogja/screens/restaurant_detail_menu.dart';
import 'package:goyang_lidah_jogja/services/restaurant_service.dart';
import 'package:goyang_lidah_jogja/services/review_service.dart';
import 'package:goyang_lidah_jogja/services/wishlist_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:goyang_lidah_jogja/services/user_service.dart';
import 'package:goyang_lidah_jogja/widgets/review_card.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuElement menu;
  final WishlistService wishlistService;
  final Map<int, int> wishlistIds;
  final Function refreshWishlist;

  const MenuDetailPage({
    Key? key,
    required this.menu,
    required this.wishlistService,
    required this.wishlistIds,
    required this.refreshWishlist,
  }) : super(key: key);

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  late RestaurantService restaurantService;
  late ReviewService reviewService;
  List<ReviewElement> reviews = [];
  bool _isInWishlist = false;
  UserProfile? userProfile;
  late CookieRequest request;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.wishlistIds.containsKey(widget.menu.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request = Provider.of<CookieRequest>(context, listen: false);
    fetchUserProfile();
    restaurantService = RestaurantService(request);
    reviewService = ReviewService(request, 'http://127.0.0.1:8000/');
    _fetchReviews();
  }

  Future<void> fetchUserProfile() async {
    if (!mounted) return;

    try {
      UserProfile profile = await UserService(request).fetchUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profile;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userProfile = null;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil pengguna: $e')),
      );
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final reviewsData = await reviewService.fetchReviews(widget.menu.id);
      setState(() {
        reviews = reviewsData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat ulasan.')),
      );
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail restoran tidak ditemukan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail restoran: $e')),
      );
    }
  }

  Future<void> _reloadMenuDetail() async {
    await _fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    final username = userProfile?.username ?? 'GUEST';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Menu: ${widget.menu.name}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.menu.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: _toggleWishlist,
                ),
              ],
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
            const Text(
              'Ulasan Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...reviews.map((review) => ReviewCard(
                  review: review,
                  canEdit: username == review.user,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitReviewPage(
                          menuId: widget.menu.id,
                          username: username,
                        ),
                      ),
                    ).then((_) => _fetchReviews());
                  },
                  onDelete: () async {
                    try {
                      await reviewService.deleteReview(review.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuccessScreen(
                            onBack: () => Navigator.popUntil(context, (route) => route.isFirst),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus ulasan: $e')),
                      );
                    }
                  },
                )),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (username == "GUEST") {
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
                          username: username,
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

class SuccessScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SuccessScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hapus Berhasil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ulasan berhasil dihapus!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBack,
              child: const Text('Kembali ke Halaman Utama'),
            ),
          ],
        ),
      ),
    );
  }
}
