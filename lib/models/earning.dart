import 'dart:convert';

Earning earningFromJson(String str) => Earning.fromJson(json.decode(str));

String earningToJson(Earning data) => json.encode(data.toJson());

class Earning {
  Earning({
    required this.id,
    required this.amount,
    this.userId,
    this.vendorId,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.formattedUpdatedDate,
    required this.pending,
    required this.available,
  });

  int id;
  dynamic amount;
  int? userId;
  dynamic vendorId;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String formattedUpdatedDate;
  double pending;
  double available;

  factory Earning.fromJson(Map<String, dynamic> json) {
    print("JSON Data: $json"); // This will print the entire JSON object
    double parsedAmount = json["amount"] != null
        ? (json["amount"] is int ? json["amount"].toDouble() : json["amount"])
        : 0.0;
    print("Parsed Amount: $parsedAmount"); // This will show the amount after parsing

    return Earning(
        id: json["id"],
        amount: parsedAmount,
        userId: json["user_id"],
        vendorId: json["vendor_id"],
        createdAt: json["created_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? DateTime.now()
            : DateTime.parse(json["updated_at"]),
        formattedDate: json["formatted_date"],
        formattedUpdatedDate: json["formatted_updated_date"],
        pending: double.parse("${json["pending"] ?? 0.0}".toString()),
        available: double.parse("${json["available"] ?? 0.0}".toString()));
  }


  Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "user_id": userId,
        "vendor_id": vendorId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "formatted_updated_date": formattedUpdatedDate,
        "pending": pending,
        "available": available
      };
}
