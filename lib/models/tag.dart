// tag.dart
// To parse this JSON data, do
//
//     final tag = tagFromJson(jsonString);

// import 'dart:convert';
// import 'menu.dart';

class Tag {
  List<TagElement> tags;

  Tag({
    required this.tags,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        tags: List<TagElement>.from(
            json["tags"].map((x) => TagElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
      };
}

class TagElement {
  int id;
  String name;
  List<int>? menuIds; // Menggunakan ID saja untuk menghindari dependencies yang kompleks

  TagElement({
    required this.id,
    required this.name,
    this.menuIds,
  });

  factory TagElement.fromJson(Map<String, dynamic> json) => TagElement(
        id: json["id"],
        name: json["name"],
        menuIds: json["menus"] != null
            ? List<int>.from(json["menus"].map((x) => x["id"]))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "menus": menuIds != null
            ? List<dynamic>.from(menuIds!.map((x) => {"id": x}))
            : null,
      };
}
