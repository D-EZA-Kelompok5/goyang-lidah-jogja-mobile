// To parse this JSON data, do
//
//     final wishlist = wishlistFromJson(jsonString);

import 'dart:convert';
import 'user_profile.dart';
import 'Menu.dart';

Wishlist wishlistFromJson(String str) => Wishlist.fromJson(json.decode(str));

String wishlistToJson(Wishlist data) => json.encode(data.toJson());

class Wishlist {
    List<WishlistElement> wishlists;

    Wishlist({
        required this.wishlists,
    });

    factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
        wishlists: List<WishlistElement>.from(json["wishlists"].map((x) => WishlistElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "wishlists": List<dynamic>.from(wishlists.map((x) => x.toJson())),
    };
}

class WishlistElement {
    String model;
    int pk;
    Fields fields;

    WishlistElement({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory WishlistElement.fromJson(Map<String, dynamic> json) => WishlistElement(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    UserProfile user;
    MenuElement menu;
    String catatan;
    String status;

    Fields({
        required this.user,
        required this.menu,
        required this.catatan,
        required this.status,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: UserProfile.fromJson(json["user"]),
        menu: MenuElement.fromJson(json["menu"]),
        catatan: json["catatan"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "menu": menu.toJson(),
        "catatan": catatan,
        "status": status,
    };
}
