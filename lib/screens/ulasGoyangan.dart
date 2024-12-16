// lib/screens/ulasGoyangan.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UlasGoyanganPage extends StatefulWidget {
  @override
  _UlasGoyanganPageState createState() => _UlasGoyanganPageState();
}

class _UlasGoyanganPageState extends State<UlasGoyanganPage> {
  final _formKey = GlobalKey<FormState>();
  String _review = '';
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ulas Goyangan'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tulis Ulasan Anda',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan ulasan Anda di sini...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ulasan tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _review = value!;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Berikan Rating Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.0),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Implementasikan logika penyimpanan ulasan di sini
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ulasan berhasil dikirim!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Kirim Ulasan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700], // Perbaiki di sini
                    padding: EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 15.0),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
