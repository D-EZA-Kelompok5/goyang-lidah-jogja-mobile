import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/ulasGoyangan.dart'; // Import UlasGoyanganPage
import 'package:goyang_lidah_jogja/models/menu.dart';
import 'package:goyang_lidah_jogja/screens/restaurant_dashboard.dart';

class MenuDetailPage extends StatefulWidget {
  final MenuElement menu;

  const MenuDetailPage({Key? key, required this.menu}) : super(key: key);

  @override
  _MenuDetailPageState createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  bool isWishlisted = false; // Toggle for love icon
  double averageRating = 3.0; // Example rating
  final List<String> tags = ['Local Indonesian', 'Poultry']; // Example tags
  final String restaurantName = 'Kesuma Restaurant'; // Example restaurant name
  final String restaurantAddress = 'Gang Sartono, 829 Mantrijeron III, Yogyakarta 55143 Indonesia'; // Address

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
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isWishlisted = !isWishlisted; // Toggle wishlist state
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris utama: Gambar di kiri, info di kanan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Makanan
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.menu.image ?? '',
                    width: 120, // Ukuran kecil
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
                SizedBox(width: 16.0),

                // Informasi di kanan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Menu
                      Text(
                        widget.menu.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),

                      // Nama Restoran
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDashboardPage(),
                            ),
                          );
                        },
                        child: Text(
                          restaurantName,
                          style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 8.0),

                      // Harga
                      Text(
                        'Rp ${widget.menu.price.toStringAsFixed(2)}',
                        style: TextStyle(
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
            SizedBox(height: 16.0),

            // Deskripsi
            Text(
              widget.menu.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Tags
            Wrap(
              spacing: 8.0,
              children: tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(color: Colors.black),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),

            // Informasi Restoran
            Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penilaian dan Ulasan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 24,
                        );
                      }),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Rating: $averageRating',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Lokasi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      restaurantAddress,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

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
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
