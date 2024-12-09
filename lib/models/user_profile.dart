// models/user_profile.dart
class UserProfile {
  int userId;
  String username;
  String email;
  String role;
  String bio;
  String? profilePicture;
  int reviewCount;
  String level;
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
        role: json["role"],
        bio: json["bio"],
        profilePicture: json["profile_picture"],
        reviewCount: json["review_count"],
        level: json["level"],
        preferences: json["preferences"] != null
            ? List<TagElement>.from(
                json["preferences"].map((x) => TagElement.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "email": email,
        "role": role,
        "bio": bio,
        "profile_picture": profilePicture,
        "review_count": reviewCount,
        "level": level,
        "preferences": preferences != null
            ? List<dynamic>.from(preferences!.map((x) => x.toJson()))
            : null,
      };
}

class TagElement {
  // Define the TagElement properties based on your requirements
  String tagName;

  TagElement({
    required this.tagName,
  });

  factory TagElement.fromJson(Map<String, dynamic> json) => TagElement(
        tagName: json["tag_name"],
      );

  Map<String, dynamic> toJson() => {
        "tag_name": tagName,
      };
}