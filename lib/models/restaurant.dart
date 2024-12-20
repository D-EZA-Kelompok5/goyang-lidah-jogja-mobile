// restaurant.dart

// import 'dart:convert';
import 'user_profile.dart';

enum PriceRange { DOLLAR, DOLLAR_DOLLAR, DOLLAR_DOLLAR_DOLLAR }

final priceRangeValues = EnumValues({
  "\$": PriceRange.DOLLAR,
  "\$\$": PriceRange.DOLLAR_DOLLAR,
  "\$\$\$": PriceRange.DOLLAR_DOLLAR_DOLLAR,
});

class Owner {
  final int id;
  final String username;

  Owner({
    required this.id,
    required this.username,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        id: json["id"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
      };
}

class Restaurant {
  int id;
  String name;
  String description;
  String address;
  String category;
  PriceRange priceRange;
  String? image;
  Owner owner;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.category,
    required this.priceRange,
    this.image,
    required this.owner,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Add debug print
    print('Processing JSON: $json');
    try {
      return Restaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        address: json["address"],
        category: json["category"],
        priceRange: priceRangeValues.map[json["price_range"]]!,
        image: json["image"],
        owner: Owner.fromJson(json["owner"]),
      );
    } catch (e) {
      print('Error parsing Restaurant: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "address": address,
        "category": category,
        "price_range": priceRangeValues.reverse[priceRange],
        "image": image,
        "owner": owner.toJson(),
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
