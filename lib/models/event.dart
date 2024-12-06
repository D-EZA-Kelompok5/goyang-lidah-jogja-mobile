// To parse this JSON data, do
//
//     final event = eventFromJson(jsonString);

import 'dart:convert';

Event eventFromJson(String str) => Event.fromJson(json.decode(str));

String eventToJson(Event data) => json.encode(data.toJson());

class Event {
    List<EventElement> events;

    Event({
        required this.events,
    });

    factory Event.fromJson(Map<String, dynamic> json) => Event(
        events: List<EventElement>.from(json["events"].map((x) => EventElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
    };
}

class EventElement {
    int id;
    String title;
    String description;
    DateTime date;
    String time;
    String location;
    String entranceFee;
    String image;
    CreatedBy createdBy;

    EventElement({
        required this.id,
        required this.title,
        required this.description,
        required this.date,
        required this.time,
        required this.location,
        required this.entranceFee,
        required this.image,
        required this.createdBy,
    });

    factory EventElement.fromJson(Map<String, dynamic> json) => EventElement(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        date: DateTime.parse(json["date"]),
        time: json["time"],
        location: json["location"],
        entranceFee: json["entrance_fee"],
        image: json["image"],
        createdBy: CreatedBy.fromJson(json["created_by"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "location": location,
        "entrance_fee": entranceFee,
        "image": image,
        "created_by": createdBy.toJson(),
    };
}

class CreatedBy {
    int userId;
    String username;
    String email;
    String role;
    String bio;
    dynamic profilePicture;
    String level;

    CreatedBy({
        required this.userId,
        required this.username,
        required this.email,
        required this.role,
        required this.bio,
        required this.profilePicture,
        required this.level,
    });

    factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        role: json["role"],
        bio: json["bio"],
        profilePicture: json["profile_picture"],
        level: json["level"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "email": email,
        "role": role,
        "bio": bio,
        "profile_picture": profilePicture,
        "level": level,
    };
}
