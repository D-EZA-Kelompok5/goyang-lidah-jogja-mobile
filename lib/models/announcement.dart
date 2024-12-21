// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

List<AnnouncementResponse> welcomeFromJson(String str) => List<AnnouncementResponse>.from(json.decode(str).map((x) => AnnouncementResponse.fromJson(x)));

String welcomeToJson(List<AnnouncementResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AnnouncementResponse {
    String model;
    int pk;
    Announcement fields;

    AnnouncementResponse({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory AnnouncementResponse.fromJson(Map<String, dynamic> json) => AnnouncementResponse(
        model: json["model"],
        pk: json["pk"],
        fields: Announcement.fromJson(json["fields"])..pk = json["pk"],
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Announcement {
    int? pk;
    int restaurant;
    String title;
    String message;

    Announcement({
        this.pk,
        required this.restaurant,
        required this.title,
        required this.message,
    });

    factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        restaurant: json["restaurant"],
        title: json["title"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "restaurant": restaurant,
        "title": title,
        "message": message,
    };
}
