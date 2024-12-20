import 'dart:convert';
import 'restaurant.dart';
import 'tag.dart';

// Menu menuFromJson(String str) => Menu.fromJson(json.decode(str));

// String menuToJson(Menu data) => json.encode(data.toJson());

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
    required this.image,
    required this.restaurant,
    this.tagIds,
  });

  factory MenuElement.fromJson(Map<String, dynamic> json) => MenuElement(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        image: json["image"],
        restaurant: Restaurant.fromJson(json["restaurant"]),
        tagIds: json["tags"] != null
            ? List<int>.from(json["tags"].map((x) => x["id"]))
            : null,
      );

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
