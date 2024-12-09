// user_profile.dart
// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

// import 'dart:convert';
import 'tag.dart';

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
