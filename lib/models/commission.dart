class Commission {
  int id;
  int orderId;
  double admin;
  double vendor;
  double driver;

  Commission({
    required this.id,
    required this.orderId,
    required this.admin,
    required this.vendor,
    required this.driver,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    print("Commission JSON Data: $json");
    final category = Commission(
      id: json["id"],
      orderId: json["order_id"],
      admin: null != json["admin_commission"]
          ? double.parse(json["admin_commission"].toString())
          : 0.0,
      vendor: null != json["vendor_commission"]
          ? double.parse(json["vendor_commission"].toString())
          : 0.0,
      driver: null != json["driver_commission"]
          ? double.parse(json["driver_commission"].toString())
          : 0.0,
    );
    return category;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "admin": admin,
        "vendor": vendor,
        "driver": driver,
      };
}
