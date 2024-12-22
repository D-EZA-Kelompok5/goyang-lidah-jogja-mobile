import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/models/review.dart';

class ReviewCard extends StatelessWidget {
  final ReviewElement review;
  final bool canEdit;
  final Function() onEdit;
  final Function() onDelete;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.user,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '⭐ ${review.rating}',
                  style: TextStyle(color: Colors.amber, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Dibuat pada: ${review.createdAt.toLocal()}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8.0),
            Text(review.comment),
            if (canEdit)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    label: Text("Edit"),
                    onPressed: onEdit,
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text("Delete"),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
