// event.dart

class Event {
  int id;
  String title;
  String description;
  DateTime date;
  String time;
  String location;
  double? entranceFee;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.entranceFee,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      entranceFee: json['entrance_fee'] != null ? (json['entrance_fee'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // Format date as 'YYYY-MM-DD'
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'location': location,
      'entrance_fee': entranceFee,
    };
  }
}