// // lib/screens/edit_review.dart

// import 'package:flutter/material.dart';
// import 'package:goyang_lidah_jogja/services/review_service.dart';
// import 'package:goyang_lidah_jogja/models/review.dart';
// import 'package:provider/provider.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';

// class EditReviewPage extends StatefulWidget {
//   final ReviewElement review;

//   const EditReviewPage({
//     Key? key,
//     required this.review,
//   }) : super(key: key);

//   @override
//   State<EditReviewPage> createState() => _EditReviewPageState();
// }

// class _EditReviewPageState extends State<EditReviewPage> {
//   final _formKey = GlobalKey<FormState>();
//   late int _rating;
//   late String _comment;
//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _rating = widget.review.rating;
//     _comment = widget.review.comment;
//   }

//   void _editReview() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       setState(() {
//         _isSubmitting = true;
//       });

//       final request = Provider.of<CookieRequest>(context, listen: false);
//       final baseUrl = 'http://10.0.2.2:8000'; // Ganti sesuai lingkungan Anda
//       final reviewService = ReviewService(request, baseUrl);

//       try {
//         final response = await reviewService.editReview(widget.review.id, _rating, _comment);
//         if (response['message'] != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(response['message'])),
//           );
//           Navigator.pop(context, true); // Kembali dan refresh
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(response['error'] ?? 'Terjadi kesalahan')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal mengedit ulasan: $e')),
//         );
//       } finally {
//         setState(() {
//           _isSubmitting = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Ulasan'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isSubmitting
//             ? Center(child: CircularProgressIndicator())
//             : Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Rating Dropdown
//                     DropdownButtonFormField<int>(
//                       decoration: InputDecoration(
//                         labelText: 'Rating',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _rating,
//                       items: List.generate(5, (index) {
//                         int value = index + 1;
//                         return DropdownMenuItem(
//                           value: value,
//                           child: Text(value.toString()),
//                         );
//                       }),
//                       onChanged: (value) {
//                         setState(() {
//                           _rating = value ?? 5;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value < 1 || value > 5) {
//                           return 'Pilih rating antara 1 hingga 5';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     // Comment TextField
//                     TextFormField(
//                       initialValue: _comment,
//                       decoration: InputDecoration(
//                         labelText: 'Komentar',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLines: 5,
//                       onSaved: (value) {
//                         _comment = value ?? '';
//                       },
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Komentar tidak boleh kosong';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 24),
//                     // Submit Button
//                     ElevatedButton(
//                       onPressed: _editReview,
//                       child: Text('Simpan Perubahan'),
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         textStyle: TextStyle(fontSize: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
