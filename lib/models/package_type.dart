import 'dart:convert';

PackageType packageTypeFromJson(String str) =>
    PackageType.fromJson(json.decode(str));

String packageTypeToJson(PackageType data) => json.encode(data.toJson());

class PackageType {
  PackageType({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.photo,
    this.packageTypePricingCount = 0,
    this.driverVerifyStops = false,
  });

  int id;
  String name;
  String description;
  bool driverVerifyStops;
  int isActive;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String photo;
  int packageTypePricingCount;

  factory PackageType.fromJson(dynamic json) {
    return PackageType(
      id: json["id"],
      name: json["name"],
      description: json["description"] ?? "",
      isActive: int.tryParse(json["is_active"].toString()) ?? 0,
      driverVerifyStops: json["driver_verify_stops"] == null
          ? false
          : (int.parse(json["driver_verify_stops"].toString()) == 1),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      formattedDate:
          json["formatted_date"],
      photo: json["photo"],
      packageTypePricingCount: json['package_type_pricings_count'] ?? 0);
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "driver_verify_stops": driverVerifyStops ? 1 : 0,
        "is_active": isActive,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "photo": photo,
        "package_type_pricings_count": packageTypePricingCount,
      };
}
