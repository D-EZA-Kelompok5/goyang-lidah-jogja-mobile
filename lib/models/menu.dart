// menu.dart
// To parse this JSON data, do
//
//     final menu = menuFromJson(jsonString);

import 'dart:convert';
import 'restaurant.dart';
import 'tag.dart';

class Menu {
  List<MenuElement> menus;

  Menu({
    required this.menus,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        menus: List<MenuElement>.from(
            json["menus"].map((x) => MenuElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "menus": List<dynamic>.from(menus.map((x) => x.toJson())),
      };
}

class MenuElement {
  int id;
  String name;
  String description;
  int price;
  String? image;
  Restaurant restaurant;
  List<int>?
      tagIds; // Menggunakan ID saja untuk menghindari dependencies yang kompleks

  MenuElement({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.restaurant,
    this.tagIds,
  });

  factory MenuElement.fromJson(Map<String, dynamic> json) {
    try {
      String name = json["name"]?.toString() ?? ""; // Convert to string first
      name = name.replaceAll("<!-- -->", '').trim();
      if (name.isEmpty) name = "Untitled Menu";
      return MenuElement(
        id: json["id"],
        name: name,
        description: json["description"] ?? "",
        price: json["price"] ?? 0,
        image: json["image"]?.toString(),
        restaurant: Restaurant.fromJson(json["restaurant"]),
        tagIds: json["tags"] != null
            ? List<int>.from(json["tags"].map((x) => x["id"]))
            : null,
      );
    } catch (e) {
      print('Error parsing MenuElement: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "restaurant": restaurant.toJson(),
        "tags": tagIds != null
            ? List<dynamic>.from(tagIds!.map((x) => {"id": x}))
            : null,
      };
}
