import 'tag.dart';
import 'restaurant.dart';

enum Level { BEGINNER, BRONZE, SILVER, GOLD }

final levelValues = EnumValues({
  "BEGINNER": Level.BEGINNER,
  "BRONZE": Level.BRONZE,
  "SILVER": Level.SILVER,
  "GOLD": Level.GOLD,
});

enum Role { EVENT_MANAGER, RESTAURANT_OWNER, CUSTOMER }

final roleValues = EnumValues({
  "EVENT_MANAGER": Role.EVENT_MANAGER,
  "RESTAURANT_OWNER": Role.RESTAURANT_OWNER,
  "CUSTOMER": Role.CUSTOMER,
});

class UserProfile {
  int userId;
  String username;
  String email;
  Role role;
  String bio;
  String? profilePicture;
  int reviewCount;
  Level level;
  List<TagElement>? preferences;
  Restaurant? ownedRestaurant;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.bio,
    this.profilePicture,
    required this.reviewCount,
    required this.level,
    this.preferences,
    this.ownedRestaurant,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        role: roleValues.map[json["role"]]!,
        bio: json["bio"],
        profilePicture: json["profile_picture"],
        reviewCount: json["review_count"],
        level: levelValues.map[json["level"]]!,
        preferences: json["preferences"] != null
            ? List<TagElement>.from(
                json["preferences"].map((x) => TagElement.fromJson(x)))
            : null,
        ownedRestaurant: json["owned_restaurant"] != null
            ? Restaurant.fromJson(json["owned_restaurant"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "email": email,
        "role": roleValues.reverse[role],
        "bio": bio,
        "profile_picture": profilePicture,
        "review_count": reviewCount,
        "level": levelValues.reverse[level],
        "preferences": preferences != null
            ? List<dynamic>.from(preferences!.map((x) => x.toJson()))
            : null,
        "owned_restaurant": ownedRestaurant?.toJson(),
      };

  // Getter to get the display representation of Role
  String get roleDisplay =>
      roleValues.reverse[role]!.replaceAll('_', ' ').toUpperCase();

  // Getter to get the display representation of Level
  String get levelDisplay => levelValues.reverse[level]!;
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