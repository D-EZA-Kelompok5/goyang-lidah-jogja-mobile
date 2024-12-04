import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/widgets/product_card.dart';
import 'package:goyang_lidah_jogja/widgets/wishlist_card.dart';

class WishlistList extends StatelessWidget {
  WishlistList({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data produk pada wishlist.
    final List<ItemHomepage> wishlistItems = [
      ItemHomepage("Wishlist Item 1", Icons.favorite, Colors.red),
      ItemHomepage("Wishlist Item 2", Icons.favorite, Colors.blue),
      ItemHomepage("Wishlist Item 3", Icons.favorite, Colors.green),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Wishlist'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: ListView.builder(
        itemCount: wishlistItems.length,
        itemBuilder: (context, index) {
          return WishlistCard(wishlistItems[index]);
        },
      ),
    );
  }
}
