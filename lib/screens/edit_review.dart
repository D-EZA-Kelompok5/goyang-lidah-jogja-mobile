// lib/screens/edit_review.dart

import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/services/review_service.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditReviewPage extends StatefulWidget {
  final int reviewId;
  final int menuId;
  final int initialRating;
  final String initialComment;
  final Function onReviewEdited;

  const EditReviewPage({
    Key? key,
    required this.reviewId,
    required this.menuId,
    required this.initialRating,
    required this.initialComment,
    required this.onReviewEdited,
  }) : super(key: key);

  @override
  _EditReviewPageState createState() => _EditReviewPageState();
}

class _EditReviewPageState extends State<EditReviewPage> {
  final _formKey = GlobalKey<FormState>();
  late int _rating;
  late String _comment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _comment = widget.initialComment;
  }

  Future<void> _submitEditReview() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final request = Provider.of<CookieRequest>(context, listen: false);
      final reviewService = ReviewService(request, 'https://127.0.0.1:8000/'); // Ganti sesuai dengan baseUrl Anda

      try {
        final response = await reviewService.editReview(widget.reviewId, _rating, _comment);
        if (response.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ulasan berhasil diperbarui!')),
          );
          widget.onReviewEdited(); // Memanggil callback untuk refresh ulasan
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? 'Gagal mengedit ulasan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Ulasan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Rating Field
                    DropdownButtonFormField<int>(
                      value: _rating,
                      decoration: InputDecoration(
                        labelText: 'Rating',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(5, (index) {
                        int value = index + 1;
                        return DropdownMenuItem(
                          value: value,
                          child: Text('$value'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _rating = value ?? 1;
                        });
                      },
                      validator: (value) {
                        if (value == null || value < 1 || value > 5) {
                          return 'Pilih rating antara 1 hingga 5';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Comment Field
                    TextFormField(
                      initialValue: _comment,
                      decoration: InputDecoration(
                        labelText: 'Komentar',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      onSaved: (value) {
                        _comment = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Komentar tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitEditReview,
                      child: Text('Perbarui Ulasan'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
