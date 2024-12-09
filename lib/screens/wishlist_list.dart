// lib/screens/wishlist_list.dart

import 'package:flutter/material.dart';

class WishlistList extends StatefulWidget {
  const WishlistList({Key? key}) : super(key: key);

  @override
  _WishlistListState createState() => _WishlistListState();
}

class _WishlistListState extends State<WishlistList> {
  late Future<List<WishlistItem>> futureWishlist;

  @override
  void initState() {
    super.initState();
    futureWishlist = fetchWishlist();
  }

  Future<List<WishlistItem>> fetchWishlist() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      WishlistItem(
        username: "JohnDoe",
        email: "john@example.com",
        role: "CUSTOMER",
        bio: "Food lover",
        profilePicture: null,
        reviewCount: 5,
        level: "SILVER",
        preferences: [],
        menuTitle: "Nasi Goreng",
        menuDescription: "Delicious fried rice",
        price: 15000,
        image: null, 
        restaurantName: "Jogja Food Place",
        tagIds: [1, 2],
        catatan: "Tolong pedas",
        status: "BELUM",
      ),
      WishlistItem(
        username: "JaneSmith",
        email: "jane@example.com",
        role: "CUSTOMER",
        bio: "Enjoys spicy food",
        profilePicture: null,
        reviewCount: 3,
        level: "GOLD",
        preferences: [],
        menuTitle: "Sate Ayam",
        menuDescription: "Grilled chicken satay",
        price: 20000,
        image: null, 
        restaurantName: "Ayam Sate House",
        tagIds: [3],
        catatan: "Tanpa kacang",
        status: "SUDAH",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Wishlist'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: FutureBuilder<List<WishlistItem>>(
        future: futureWishlist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your wishlist is empty.'));
          } else {
            final wishlists = snapshot.data!;
            return ListView.builder(
              itemCount: wishlists.length,
              itemBuilder: (context, index) {
                final item = wishlists[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                item.username.isNotEmpty
                                    ? item.username[0].toUpperCase()
                                    : '?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.username,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Menu: ${item.menuTitle}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Description: ${item.menuDescription}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Price: Rp${item.price}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Restaurant: ${item.restaurantName}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 5),
                        // Bagian Catatan dan Status
                        Text(
                          'Catatan: ${item.catatan}',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Status: ${item.status}',
                          style: TextStyle(
                            fontSize: 14,
                            color: item.status.toLowerCase() == 'belum'
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        SizedBox(height: 10),
                        // Tombol Select
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Selected: ${item.menuTitle} by ${item.username}"),
                                ),
                              );
                            },
                            child: Text('Select'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class WishlistItem {
  final String username;
  final String email;
  final String role;
  final String bio;
  final String? profilePicture;
  final int reviewCount;
  final String level;
  final List<dynamic>? preferences;
  final String menuTitle;
  final String menuDescription;
  final int price;
  final String? image;
  final String restaurantName;
  final List<int> tagIds;
  final String catatan;
  final String status;

  WishlistItem({
    required this.username,
    required this.email,
    required this.role,
    required this.bio,
    this.profilePicture,
    required this.reviewCount,
    required this.level,
    this.preferences,
    required this.menuTitle,
    required this.menuDescription,
    required this.price,
    this.image,
    required this.restaurantName,
    required this.tagIds,
    required this.catatan,
    required this.status,
  });
}
