// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

Restaurant restaurantFromJson(String str) => Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant data) => json.encode(data.toJson());

class Restaurant {
    List<RestaurantElement> restaurants;

    Restaurant({
        required this.restaurants,
    });

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        restaurants: List<RestaurantElement>.from(json["restaurants"].map((x) => RestaurantElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
    };
}

class RestaurantElement {
    int id;
    String name;
    String description;
    String address;
    String category;
    PriceRange priceRange;
    String image;
    Owner owner;

    RestaurantElement({
        required this.id,
        required this.name,
        required this.description,
        required this.address,
        required this.category,
        required this.priceRange,
        required this.image,
        required this.owner,
    });

    factory RestaurantElement.fromJson(Map<String, dynamic> json) => RestaurantElement(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        address: json["address"],
        category: json["category"],
        priceRange: priceRangeValues.map[json["price_range"]]!,
        image: json["image"],
        owner: Owner.fromJson(json["owner"]),
    );

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

class Owner {
    int userId;
    String username;
    String email;
    Role role;
    String bio;
    dynamic profilePicture;
    Level level;

    Owner({
        required this.userId,
        required this.username,
        required this.email,
        required this.role,
        required this.bio,
        required this.profilePicture,
        required this.level,
    });

    factory Owner.fromJson(Map<String, dynamic> json) => Owner(
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        role: roleValues.map[json["role"]]!,
        bio: json["bio"],
        profilePicture: json["profile_picture"],
        level: levelValues.map[json["level"]]!,
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "email": email,
        "role": roleValues.reverse[role],
        "bio": bio,
        "profile_picture": profilePicture,
        "level": levelValues.reverse[level],
    };
}

enum Level {
    BRONZE
}

final levelValues = EnumValues({
    "BRONZE": Level.BRONZE
});

enum Role {
    RESTAURANT_OWNER
}

final roleValues = EnumValues({
    "RESTAURANT_OWNER": Role.RESTAURANT_OWNER
});

enum PriceRange {
    EMPTY,
    PRICE_RANGE
}

final priceRangeValues = EnumValues({
    "\u0024\u0024 - \u0024\u0024\u0024": PriceRange.EMPTY,
    "\u0024": PriceRange.PRICE_RANGE
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
