// lib/screens/wishlist_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/wishlist.dart';
import '../services/wishlist_service.dart';
import 'wishlist_edit.dart';

class WishlistList extends StatefulWidget {
  const WishlistList({Key? key}) : super(key: key);

  @override
  _WishlistListState createState() => _WishlistListState();
}

class _WishlistListState extends State<WishlistList> {
  late Future<List<WishlistElement>> futureWishlists;
  late WishlistService wishlistService;

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    wishlistService = WishlistService(request);
    futureWishlists = wishlistService.fetchWishlists(request);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wishlist'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: FutureBuilder<List<WishlistElement>>(
        future: futureWishlists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          } else {
            final wishlists = snapshot.data!;
            return ListView.builder(
              itemCount: wishlists.length,
              itemBuilder: (context, index) {
                final item = wishlists[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Menu Image
                        if (item.menu.image.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              item.menu.image,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 10),
                        // Menu Name
                        Text(
                          item.menu.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        // Restaurant Name
                        Text(
                          item.menu.restaurantName,
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 5),
                        // Description
                        Text(
                          item.menu.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        // Price
                        Text(
                          'Rp${item.menu.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        // Catatan
                        Text(
                          'Catatan: ${item.catatan.isNotEmpty ? item.catatan : 'Tidak ada catatan'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        // Status
                        Text(
                          'Status: ${item.status == 'SUDAH' ? 'Sudah Pernah Dibeli' : 'Belum Pernah Dibeli'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: item.status.toLowerCase() == 'belum' ? Colors.orange : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Aksi Edit
                                final request = Provider.of<CookieRequest>(context, listen: false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WishlistEditPage(
                                      wishlist: item,
                                    ),
                                  )
                                ). then((value) {
                                  setState((){
                                    futureWishlists = wishlistService.fetchWishlists(request);
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: const Text('Edit', style: TextStyle(color: Colors.white)),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                try {
                                  final request = Provider.of<CookieRequest>(context, listen: false);
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text('Are you sure you want to delete "${item.menu.name}" from wishlist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed:  () => Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  
                                  // Jika pengguna tidak mengonfirmasi, keluar dari aksi
                                  if (confirm != true) return;

                                  // Panggil service untuk menghapus wishlist
                                  await wishlistService.deleteWishlist(item.id, request);

                                  // Tampilkan snackbar sukses
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("${item.menu.name} deleted successfully.")),
                                  );

                                  // Perbarui daftar wishlist setelah penghapusan
                                  setState(() {
                                    futureWishlists = wishlistService.fetchWishlists(request);
                                  });
                                } catch (error) {
                                  // Tangani error dan tampilkan pesan
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete: $error')),
                                  );
                                }  
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
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
