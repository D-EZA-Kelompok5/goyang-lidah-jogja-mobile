// To parse this JSON data, do
//
//     final tag = tagFromJson(jsonString);

import 'dart:convert';

Tag tagFromJson(String str) => Tag.fromJson(json.decode(str));

String tagToJson(Tag data) => json.encode(data.toJson());

class Tag {
    List<TagElement> tags;

    Tag({
        required this.tags,
    });

    factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        tags: List<TagElement>.from(json["tags"].map((x) => TagElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "tags": List<dynamic>.from(tags.map((x) => x.toJson())),
    };
}

class TagElement {
    int id;
    String name;

    TagElement({
        required this.id,
        required this.name,
    });

    factory TagElement.fromJson(Map<String, dynamic> json) => TagElement(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
