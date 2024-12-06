// To parse this JSON data, do
//
//     final wishlist = wishlistFromJson(jsonString);

import 'dart:convert';

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
    int user;
    int menu;
    String catatan;
    String status;

    Fields({
        required this.user,
        required this.menu,
        required this.catatan,
        required this.status,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        menu: json["menu"],
        catatan: json["catatan"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "menu": menu,
        "catatan": catatan,
        "status": status,
    };
}
