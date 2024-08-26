import 'dart:convert';

import 'shift.dart';

Zone zoneFromJson(String str) => Zone.fromJson(json.decode(str));

String zoneToJson(Zone data) => json.encode(data.toJson());

class Zone {
  Zone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.photo,
    this.shifts = const {},
  });

  int id;
  String name;
  String latitude;
  String longitude;
  int isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String photo;
  Map<String,List<Shift>> shifts;

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
        id: json["id"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        isActive: json["is_active"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        formattedDate: json["formatted_date"],
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "photo": photo,
      };
}
