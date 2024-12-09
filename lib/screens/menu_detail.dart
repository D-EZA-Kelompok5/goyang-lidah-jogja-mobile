// lib/screens/menu_detail.dart 

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/ulasGoyangan.dart'; // Import UlasGoyanganPage

class MenuDetailPage extends StatefulWidget {
  @override
  _MenuDetailPageState createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  bool isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    // Data Menu Statis
    final Map<String, dynamic> menu = {
      'id': 1,
      'name': 'Nasi Goreng Spesial',
      'image': 'assets/images/nasigorengspecial.jpeg', // Path aset yang benar
      'price': 25000.00,
      'description':
          'Nasi goreng spesial dengan campuran ayam, telur, dan sayuran segar.',
      'average_rating': 4.5,
      'review_count': 20,
      'tags': ['Pedas', 'Populer', 'Khas'],
      'restaurant': {
        'id': 1,
        'name': 'Warung Maknyus',
        'address': 'Jl. Merdeka No. 10, Jakarta'
      },
      'is_wishlisted': isWishlisted,
    };

    // Data Ulasan Statis
    final List<Map<String, dynamic>> reviews = [
      {
        'user': 'User A',
        'rating': 5.0,
        'comment': 'Enak sekali!',
        'date': '2024-04-01',
      },
      {
        'user': 'User B',
        'rating': 4.0,
        'comment': 'Sedikit pedas tapi mantap.',
        'date': '2024-03-28',
      },
      // Tambahkan ulasan lainnya sesuai kebutuhan
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Menu'),
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
              color: isWishlisted ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isWishlisted = !isWishlisted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isWishlisted
                      ? 'Ditambahkan ke wishlist'
                      : 'Dihapus dari wishlist'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Menu
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                menu['image'], // Menggunakan Image.asset dengan path yang benar
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.0),

            // Nama Menu
            Text(
              menu['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),

            // Nama Restoran
            GestureDetector(
              onTap: () {
                // Implementasikan navigasi ke detail restoran di masa depan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigasi ke detail restoran'),
                  ),
                );
              },
              child: Text(
                menu['restaurant']['name'],
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 8.0),

            // Rating dan Ulasan
            Row(
              children: [
                _buildStarRating(menu['average_rating']),
                SizedBox(width: 8.0),
                Text('(${menu['average_rating']})'),
                SizedBox(width: 8.0),
                Text('(${menu['review_count']} ulasan)'),
              ],
            ),
            SizedBox(height: 8.0),

            // Harga
            Text(
              'Rp ${menu['price'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16.0),

            // Deskripsi
            Text(
              menu['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Tags
            Wrap(
              spacing: 8.0,
              children: (menu['tags'] as List<dynamic>)
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.green[100],
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.0),

            // Lokasi
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    menu['restaurant']['address'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),

            // Tombol Ulas Goyangan
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UlasGoyanganPage()),
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
            SizedBox(height: 24.0),

            // Bagian Ulasan Pengguna
            Text(
              'Ulasan Pengguna',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),

            // Filter dan Sorting (Saat ini hanya tampilan, tanpa fungsi)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Rating
                DropdownButton<String>(
                  hint: Text('Filter Rating'),
                  items: [
                    DropdownMenuItem(
                      child: Text('Semua Bintang'),
                      value: '',
                    ),
                    DropdownMenuItem(
                      child: Text('5 Bintang'),
                      value: '5',
                    ),
                    DropdownMenuItem(
                      child: Text('4 Bintang'),
                      value: '4',
                    ),
                    DropdownMenuItem(
                      child: Text('3 Bintang'),
                      value: '3',
                    ),
                    DropdownMenuItem(
                      child: Text('2 Bintang'),
                      value: '2',
                    ),
                    DropdownMenuItem(
                      child: Text('1 Bintang'),
                      value: '1',
                    ),
                  ],
                  onChanged: (value) {
                    // Implementasikan fungsi filter jika diperlukan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filter Rating: ${value ?? 'Semua'}'),
                      ),
                    );
                  },
                ),
                // Sort By
                DropdownButton<String>(
                  hint: Text('Sort By'),
                  items: [
                    DropdownMenuItem(
                      child: Text('Rating Tertinggi'),
                      value: 'highest',
                    ),
                    DropdownMenuItem(
                      child: Text('Rating Terendah'),
                      value: 'lowest',
                    ),
                    DropdownMenuItem(
                      child: Text('Terbaru'),
                      value: 'latest',
                    ),
                    DropdownMenuItem(
                      child: Text('Terlama'),
                      value: 'oldest',
                    ),
                  ],
                  onChanged: (value) {
                    // Implementasikan fungsi sort jika diperlukan
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sort By: ${value ?? ''}'),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Daftar Ulasan
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Ulasan: Nama dan Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              review['user'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStarRating(review['rating']),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        // Komentar Ulasan
                        Text(
                          review['comment'],
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8.0),
                        // Tanggal Ulasan
                        Text(
                          review['date'],
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Membuat widget bintang rating secara manual
  Widget _buildStarRating(double rating) {
    // Membulatkan rating ke angka terdekat
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == fullStars && halfStar) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }
}
