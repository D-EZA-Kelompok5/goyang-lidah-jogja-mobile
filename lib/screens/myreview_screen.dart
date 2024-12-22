import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/review.dart';
import 'package:goyang_lidah_jogja/services/review_service.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({Key? key}) : super(key: key);

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  late ReviewService reviewService;
  late CookieRequest request;
  List<ReviewElement> userReviews = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    request = Provider.of<CookieRequest>(context, listen: false);
    reviewService = ReviewService(request, 'https://vissuta-gunawan-goyanglidahjogja.pbp.cs.ui.ac.id/');
    _fetchUserReviews();
  }

  Future<void> _fetchUserReviews() async {
    try {
      final reviewResponse = await reviewService.fetchUserReviews(); // Fetch seluruh objek Review
      setState(() {
        userReviews = reviewResponse.reviews; // Ambil daftar ulasan dari Review
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ulasan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Saya'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userReviews.isEmpty
              ? const Center(child: Text('Anda belum membuat ulasan.'))
              : ListView.builder(
                  itemCount: userReviews.length,
                  itemBuilder: (context, index) {
                    final review = userReviews[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text('Review ke-${index + 1}'), // Tambahkan nomor urutan ulasan
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            Text('Rating: ${review.rating}'),
                            Text('Komentar: ${review.comment}'),
                            Text('Dibuat pada: ${review.createdAt.toIso8601String()}'),
                            if (review.lastEdited != null)
                              Text('Diedit pada: ${review.lastEdited!.toIso8601String()}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
