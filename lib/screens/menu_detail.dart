import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/user_profile.dart';
import 'package:goyang_lidah_jogja/models/wishlist.dart';
import 'package:goyang_lidah_jogja/screens/ulasGoyangan.dart'; // Import UlasGoyanganPage
import 'package:goyang_lidah_jogja/models/menu.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:goyang_lidah_jogja/services/wishlist_service.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuElement menu;
  final WishlistService wishlistService;
  final Map<int, int> wishlistIds;
  final Function refreshWishlist;
  final UserProfile? userProfile;

  const MenuDetailPage({
    Key? key,
    required this.menu,
    required this.wishlistService,
    required this.wishlistIds,
    required this.refreshWishlist,
    required this.userProfile,
  }) : super(key: key);

  @override
    _MenuDetailPageState createState() => _MenuDetailPageState();
  }

class _MenuDetailPageState extends State<MenuDetailPage> {
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.wishlistIds.containsKey(widget.menu.id);
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
          await widget.wishlistService.deleteWishlist(wishlistId, widget.wishlistService.request);
          setState(() {
            _isInWishlist = false;
            widget.wishlistIds.remove(widget.menu.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.menu.name} removed from wishlist.')),
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
          SnackBar(content: Text('${widget.menu.name} added to wishlist.')),
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
        title: Text(widget.menu.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Menu
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.menu.image ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child:
                      Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 16.0),

            // Nama Menu dan Wishlist Button
             Row(
              children: [
                Text(
                  widget.menu.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                if (widget.userProfile != null && widget.userProfile!.role == Role.CUSTOMER && widget.wishlistService.request.loggedIn)
                  Padding(
                    padding: EdgeInsets.only(left: 4.0),
                      child: IconButton(
                        icon: Icon(
                          _isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: _isInWishlist ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleWishlist,
                    ),
                  ),
                ],
              ),

            // Harga
            Text(
              'Rp ${widget.menu.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16.0),

            // Deskripsi
            Text(
              widget.menu.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Tombol Ulas Goyangan
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UlasGoyanganPage(),
                    ),
                  );
                },
                child: Text('Ulas Goyangan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
