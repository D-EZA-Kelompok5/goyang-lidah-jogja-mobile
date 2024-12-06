// To parse this JSON data, do
//
//     final announcement = announcementFromJson(jsonString);

import 'dart:convert';

Announcement announcementFromJson(String str) => Announcement.fromJson(json.decode(str));

String announcementToJson(Announcement data) => json.encode(data.toJson());

class Announcement {
    List<AnnouncementElement> announcements;

    Announcement({
        required this.announcements,
    });

    factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        announcements: List<AnnouncementElement>.from(json["announcements"].map((x) => AnnouncementElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "announcements": List<dynamic>.from(announcements.map((x) => x.toJson())),
    };
}

class AnnouncementElement {
    int id;
    String title;
    String message;
    Restaurant restaurant;

    AnnouncementElement({
        required this.id,
        required this.title,
        required this.message,
        required this.restaurant,
    });

    factory AnnouncementElement.fromJson(Map<String, dynamic> json) => AnnouncementElement(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        restaurant: Restaurant.fromJson(json["restaurant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
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
