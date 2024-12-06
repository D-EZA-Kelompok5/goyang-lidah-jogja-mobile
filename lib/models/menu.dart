// To parse this JSON data, do
//
//     final menu = menuFromJson(jsonString);

import 'dart:convert';

Menu menuFromJson(String str) => Menu.fromJson(json.decode(str));

String menuToJson(Menu data) => json.encode(data.toJson());

class Menu {
    List<MenuElement> menus;

    Menu({
        required this.menus,
    });

    factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        menus: List<MenuElement>.from(json["menus"].map((x) => MenuElement.fromJson(x))),
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
    String image;
    Restaurant restaurant;

    MenuElement({
        required this.id,
        required this.name,
        required this.description,
        required this.price,
        required this.image,
        required this.restaurant,
    });

    factory MenuElement.fromJson(Map<String, dynamic> json) => MenuElement(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        image: json["image"],
        restaurant: Restaurant.fromJson(json["restaurant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image": image,
        "restaurant": restaurant.toJson(),
    };
}

class Restaurant {
    int id;
    String name;

    Restaurant({
        required this.id,
        required this.name,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
