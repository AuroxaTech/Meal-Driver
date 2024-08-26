import 'dart:convert';

import 'package:intl/intl.dart';

import 'zone.dart';

Shift shiftFromJson(String str) => Shift.fromJson(json.decode(str));

String shiftToJson(Shift data) => json.encode(data.toJson());

class Shift {
  Shift(
      {required this.id,
      required this.zoneId,
      required this.date,
      required this.startAt,
      required this.endAt,
      required this.quota,
      required this.zone,
      this.shiftRequestStatus = -1});

  int id;
  int zoneId;
  String date;
  String startAt;
  String endAt;
  int quota;
  Zone zone;
  int shiftRequestStatus;

  factory Shift.fromJson(Map<String, dynamic> json) {
    String date = json['date'] ?? "";
    if (date.isNotEmpty) {
      date = DateFormat("dd MMM").format(DateFormat("yyyy-MM-dd").parse(date));
    }

    String startAt = json['start_at'] ?? "";
    if (startAt.isNotEmpty) {
      startAt =
          DateFormat("hh:mm a").format(DateFormat("hh:mm:ss").parse(startAt));
    }

    String endAt = json['end_at'] ?? "";
    if (endAt.isNotEmpty) {
      endAt =
          DateFormat("hh:mm a").format(DateFormat("hh:mm:ss").parse(endAt));
    }

    return Shift(
      id: json["id"],
      zoneId: json["zone_id"],
      date: date,
      startAt: startAt,
      endAt: endAt,
      quota: json["quota"],
      zone: Zone.fromJson(json["zone"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "zone_id": zoneId,
        "date": date,
        "start_at": startAt,
        "end_at": endAt,
        "quota": quota,
        "zone": zoneToJson(zone),
      };
}
