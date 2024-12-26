import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/wishlist.dart';
import '../services/wishlist_service.dart';
import 'wishlist_edit.dart';

class WishlistList extends StatefulWidget {
  final VoidCallback onWishlistChanged;

  const WishlistList({Key? key, required this.onWishlistChanged})
      : super(key: key);

  @override
  _WishlistListState createState() => _WishlistListState();
}

class _WishlistListState extends State<WishlistList> {
  late Future<List<WishlistElement>> futureWishlists;
  late WishlistService wishlistService;
  String sortOption = 'lowest'; // 'lowest' or 'highest'
  String priceRange = 'All'; // specific range or 'all'
  double minPrice = 0.0;
  double maxPrice = 1000000.0;

  List<Map<String, dynamic>> priceRanges = [
    {'label': 'All', 'min': 0.0, 'max': 1000000.0},
    {'label': '<20.000', 'min': 0.0, 'max': 20000.0},
    {'label': '20.000 - 40.000', 'min': 20000.0, 'max': 40000.0},
    {'label': '40.000 - 60.000', 'min': 40000.0, 'max': 60000.0},
    {'label': '60.000 - 80.000', 'min': 60000.0, 'max': 80000.0},
    {'label': '80.000 - 100.000', 'min': 80000.0, 'max': 100000.0},
    {'label': '100.000 - 150.000', 'min': 100000.0, 'max': 150000.0},
    {'label': '150.000 - 200.000', 'min': 150000.0, 'max': 200000.0},
    {'label': '>200.000', 'min': 200000.0, 'max': 1000000.0},
  ];

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    wishlistService = WishlistService(request);
    futureWishlists = wishlistService.fetchWishlists(request);
  }

  List<WishlistElement> applyFilters(List<WishlistElement> wishlists) {
    List<WishlistElement> filtered = wishlists;

    // Jika user memasukkan batas min dan max
    if (minPrice != 0.0 || maxPrice != 1000000.0) {
      filtered = filtered.where((item) {
        double price = item.menu.price.toDouble();
        return price >= minPrice && price <= maxPrice;
      }).toList();
    } else if (priceRange != 'All') {
      // Menggunakan pilihan range preset
      final selectedRange =
          priceRanges.firstWhere((range) => range['label'] == priceRange);
      double min = selectedRange['min'];
      double max = selectedRange['max'];

      filtered = filtered.where((item) {
        double price = item.menu.price.toDouble();
        return price >= min && price <= max;
      }).toList();
    }

    // Sorting
    if (sortOption == 'lowest') {
      filtered.sort((a, b) => a.menu.price.compareTo(b.menu.price));
    } else if (sortOption == 'highest') {
      filtered.sort((a, b) => b.menu.price.compareTo(a.menu.price));
    }

    return filtered;
  }

  Widget buildFilterSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: sortOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      sortOption = newValue!;
                    });
                  },
                  items: <String>['lowest', 'highest']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'lowest'
                          ? 'Harga Terendah'
                          : 'Harga Tertinggi'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  value: priceRange,
                  onChanged: (String? newValue) {
                    setState(() {
                      priceRange = newValue!;
                    });
                  },
                  items: priceRanges.map((range) {
                    return DropdownMenuItem<String>(
                      value: range['label'],
                      child: Text(range['label']),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Min'),
                  onChanged: (value) {
                    minPrice = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga Max'),
                  onChanged: (value) {
                    maxPrice = double.tryParse(value) ?? 1000000.0;
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }

  Widget buildWishlistCard(WishlistElement item, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.menu.image.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  item.menu.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.menu.restaurantName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.menu.description,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.catatan != null && item.catatan.isNotEmpty
                      ? 'Catatan: ${item.catatan}'
                      : 'Catatan: Belum ada catatan',
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp${item.menu.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Status: ${item.status == 'SUDAH' ? 'Sudah Pernah Dibeli' : 'Belum Pernah Dibeli'}',
                  style: TextStyle(
                    fontSize: 11,
                    color: item.status.toLowerCase() == 'belum'
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final request =
                              Provider.of<CookieRequest>(context, listen: false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WishlistEditPage(
                                wishlist: item,
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              futureWishlists =
                                  wishlistService.fetchWishlists(request);
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleDelete(item, context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text('Delete', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(WishlistElement item, BuildContext context) async {
    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete "${item.menu.name}" from wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await wishlistService.deleteWishlist(item.id, request);
      widget.onWishlistChanged();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${item.menu.name} deleted successfully.")),
      );

      setState(() {
        futureWishlists = wishlistService.fetchWishlists(request);
      });
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $error')),
      );
    }
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
          }

          final wishlists = snapshot.data!;
          final filteredWishlists = applyFilters(wishlists);

          return Column(
            children: [
              buildFilterSection(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Ubah kolom grid secara responsif
                    final crossAxisCount = constraints.maxWidth > 1200
                        ? 3
                        : constraints.maxWidth > 800
                            ? 2
                            : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        // Atur aspect ratio kartu supaya tidak terlalu tinggi/lebar
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredWishlists.length,
                      itemBuilder: (context, index) {
                        return buildWishlistCard(filteredWishlists[index], context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}