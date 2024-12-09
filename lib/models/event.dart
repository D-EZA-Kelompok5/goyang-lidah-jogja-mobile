// models/event.dart
import 'user_profile.dart';

class Event {
  List<EventElement> events;

  Event({
    required this.events,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        events: List<EventElement>.from(
            json["events"].map((x) => EventElement.fromJson(x))),
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
  double? entranceFee;
  String? image;
  UserProfile createdBy;

  EventElement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.entranceFee,
    this.image,
    required this.createdBy,
  });

  factory EventElement.fromJson(Map<String, dynamic> json) => EventElement(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        date: DateTime.parse(json["date"]),
        time: json["time"],
        location: json["location"],
        entranceFee: json["entrance_fee"] != null
            ? double.parse(json["entrance_fee"])
            : null,
        image: json["image"],
        createdBy: UserProfile.fromJson(json["created_by"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "time": time,
        "location": location,
        "entrance_fee": entranceFee?.toString(),
        "image": image,
        "created_by": createdBy.toJson(),
      };
}