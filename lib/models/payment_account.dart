import 'dart:convert';
import 'package:supercharged/supercharged.dart';

PaymentAccount paymentAccountFromJson(String str) =>
    PaymentAccount.fromJson(json.decode(str));

String paymentAccountToJson(PaymentAccount data) => json.encode(data.toJson());

class PaymentAccount {
  PaymentAccount({
    required this.name,
    required this.number,
    required this.instructions,
    required this.isActive,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.formattedDate,
    required this.formattedUpdatedDate,
  });

  String name;
  String number;
  String instructions;
  bool isActive;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  String formattedDate;
  String formattedUpdatedDate;

  factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
    name: json["bank_name"] ?? '', // Default to empty string if null
    number: json["account_number"] ?? '', // Default to empty string if null
    instructions: json["instructions"] ?? '', // Default to empty string if null
    isActive: (json["is_active"]?.toString().toInt() ?? 0) == 1, // Handle null safely
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : DateTime.now(), // Fallback to current date if null
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : DateTime.now(), // Fallback to current date if null
    id: json["id"] ?? 0, // Default to 0 if null
    formattedDate: json["formatted_date"] ?? '', // Default to empty string if null
    formattedUpdatedDate: json["formatted_updated_date"] ?? '', // Default to empty string if null
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "number": number,
    "is_active": isActive ? "1" : "0",
    "instructions": instructions,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
    "formatted_date": formattedDate,
    "formatted_updated_date": formattedUpdatedDate,
  };
}
