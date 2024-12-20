import 'dart:convert';
import 'restaurant.dart';
import 'tag.dart';

class Menu {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'] ?? '',
    );
  }
}
