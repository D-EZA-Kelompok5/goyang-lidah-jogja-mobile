// lib/screens/menu_detail.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/screens/ulasGoyangan.dart'; // Import UlasGoyanganPage
import 'package:goyang_lidah_jogja/models/menu.dart';

class MenuDetailPage extends StatelessWidget {
  final MenuElement menu;

  const MenuDetailPage({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menu.name),
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
                menu.image ?? '',
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

            // Nama Menu
            Text(
              menu.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),

            // Harga
            Text(
              'Rp ${menu.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16.0),

            // Deskripsi
            Text(
              menu.description,
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
