import 'dart:convert';

DeliveryAddress deliveryAddressFromJson(String str) =>
    DeliveryAddress.fromJson(json.decode(str));

String deliveryAddressToJson(DeliveryAddress data) =>
    json.encode(data.toJson());

class DeliveryAddress {
  DeliveryAddress({
    this.id,
    this.name,
    this.description,
    this.city,
    this.state,
    this.country,
    this.address = "Current Location",
    this.latitude,
    this.longitude,
    this.isDefault,
    this.userId,
    this.photo,
  });

  int? id;
  String? name;
  String? description;
  String? address;
  String? city;
  String? state;
  String? country;
  double? latitude;
  double? longitude;
  int? isDefault;
  int? userId;
  String? photo;

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
        id: json["id"],
        name: json["name"],
        description: json["description"] ?? '',
        address: json["address"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        latitude: double.parse(json["latitude"].toString()),
        longitude: double.parse(json["longitude"].toString()),
        //distance: json["distance"] == null ? null : double.parse(json["distance"].toString()),
        isDefault: int.parse(json["is_default"].toString()),
        userId: int.parse(json["user_id"].toString()),
        photo: json["photo"],
      );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "city": city,
        "state": state,
        "country": country,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        //"distance": distance,
        "is_default": isDefault,
        "user_id": userId,
        "photo": photo,
      };

  //
  Map<String, dynamic> toSaveJson() => {
        "name": name,
        "description": description,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "latitude": latitude,
        "longitude": longitude,
        "is_default": isDefault,
      };

  bool get defaultDeliveryAddress => isDefault == 1;
}
