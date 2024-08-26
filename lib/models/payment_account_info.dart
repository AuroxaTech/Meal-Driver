import 'dart:convert';
import 'package:supercharged/supercharged.dart';

PaymentAccountInfo paymentAccountInfoFromJson(String str) =>
    PaymentAccountInfo.fromJson(json.decode(str));

String paymentAccountInfoToJson(PaymentAccountInfo data) =>
    json.encode(data.toJson());

class PaymentAccountInfo {
  PaymentAccountInfo({
    required this.name,
    required this.accountNumber,
    required this.transitNumber,
    required this.institutionNumber,
  });

  String name;
  String accountNumber;
  String transitNumber;
  String institutionNumber;

  factory PaymentAccountInfo.fromJson(Map<String, dynamic> json) {
    return PaymentAccountInfo(
      name: json["bank_name"],
      accountNumber: json["account_number"],
      transitNumber: json["ifsc_code"],
      institutionNumber: json["account_type"],
    );
  }

  Map<String, dynamic> toJson() => {
        "bank_name": name,
        "account_number": accountNumber,
        "ifsc_code": transitNumber,
        "account_type": institutionNumber,
      };
}
