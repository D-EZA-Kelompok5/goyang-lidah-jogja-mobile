// lib/models/wishlist.dart

import 'dart:convert';

Wishlist productFromJson(String str) => Wishlist.fromJson(json.decode(str));

String productToJson(Wishlist data) => json.encode(data.toJson());

class Wishlist {
  List<WishlistElement> wishlists;

  Wishlist({
    required this.wishlists,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        wishlists: List<WishlistElement>.from(
            json["wishlists"].map((x) => WishlistElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "wishlists": List<dynamic>.from(wishlists.map((x) => x.toJson())),
      };
}

class WishlistElement {
  int id;
  String catatan;
  String status;
  MenuItem menu;

  WishlistElement({
    required this.id,
    required this.catatan,
    required this.status,
    required this.menu,
  });

  factory WishlistElement.fromJson(Map<String, dynamic> json) => WishlistElement(
        id: json["id"],
        catatan: json["catatan"] ?? '',
        status: json["status"] ?? 'BELUM',
        menu: MenuItem.fromJson(json["menu"]),
      );


  Map<String, dynamic> toJson() => {
        "id": id,
        "catatan": catatan,
        "status": status,
        "menu": menu.toJson(),
      };
}

class MenuItem {
  int id;
  String name;
  String description;
  double price;
  String image;
  String restaurantName;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.restaurantName,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: (json["price"] as num).toDouble(),
        image: json["image"],
        restaurantName: json["restaurant_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "restaurant_name": restaurantName,
      };
}
