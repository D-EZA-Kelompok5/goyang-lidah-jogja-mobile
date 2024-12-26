// To parse this JSON data, do:
//
//     final review = reviewFromJson(jsonString);

import 'dart:convert';

Review reviewFromJson(String str) => Review.fromJson(json.decode(str));

String reviewToJson(Review data) => json.encode(data.toJson());

class Review {
  List<ReviewElement> reviews;

  Review({
    required this.reviews,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        reviews: List<ReviewElement>.from(
            json["reviews"].map((x) => ReviewElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
      };
}

class ReviewElement {
  int id;
  String user; // Mengubah user menjadi String
  int rating;
  String comment;
  DateTime createdAt;
  DateTime? lastEdited;

  ReviewElement({
    required this.id,
    required this.user, // User adalah String
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.lastEdited,
  });

  factory ReviewElement.fromJson(Map<String, dynamic> json) => ReviewElement(
        id: json["id"],
        user: json["user"], // Ambil langsung sebagai String
        rating: json["rating"],
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
        lastEdited: json["last_edited"] != null
            ? DateTime.parse(json["last_edited"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user, // User langsung berupa String
        "rating": rating,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
      };
}
