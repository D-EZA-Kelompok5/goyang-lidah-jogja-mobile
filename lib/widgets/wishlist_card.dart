import 'package:flutter/material.dart';
import 'package:goyang_lidah_jogja/widgets/product_card.dart';

class WishlistCard extends StatelessWidget {
  final ItemHomepage item;

  const WishlistCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item.color,
      child: ListTile(
        leading: Icon(item.icon, color: Colors.white),
        title: Text(item.name, style: TextStyle(color: Colors.white)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selected: ${item.name}"))
          );
        },
      ),
    );
  }
}
