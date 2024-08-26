import 'dart:convert';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/models/delivery_address.dart';
import 'package:driver/models/order_attachment.dart';
import 'package:driver/models/order_fee.dart';
import 'package:driver/models/order_service.dart';
import 'package:driver/models/order_stop.dart';
import 'package:driver/models/package_type.dart';
import 'package:driver/models/taxi_order.dart';
import 'package:driver/models/vendor.dart';
import 'package:driver/models/order_product.dart';
import 'package:driver/models/payment_method.dart';
import 'package:driver/models/user.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'commission.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    required this.id,
    required this.canRate,
    required this.rateDriver,
    required this.code,
    required this.verificationCode,
    required this.note,
    required this.type,
    required this.status,
    required this.paymentStatus,
    this.subTotal,
    this.discount,
    this.deliveryFee,
    this.comission,
    this.tax,
    this.taxRate,
    this.tip,
    this.total,
    required this.deliveryAddressId,
    required this.distance,
    required this.paymentMethodId,
    required this.vendorId,
    required this.userId,
    required this.driverId,
    required this.createdAt,
    required this.updatedAt,
    required this.formattedDate,
    required this.paymentLink,
    required this.orderProducts,
    required this.orderStops,
    required this.user,
    required this.driver,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.vendor,
    required this.orderService,
    required this.taxiOrder,
    //
    required this.packageType,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupDate,
    required this.pickupTime,
    this.recipientName,
    this.recipientPhone,
    required this.width,
    required this.height,
    required this.length,
    required this.weight,
    required this.payer,
    required this.photo,
    required this.attachments,
    required this.fees,
    required this.transitFeePerKm,
    this.deliveryLatLong,
    this.commission,
    this.showDateHeader = false,
  });

  int id;
  bool canRate;
  bool rateDriver;
  String code;
  String verificationCode;
  String note;
  String type;

  /// Available statuses
  /// -------------------
  /// pending
  /// preparing
  /// driver_entered
  /// ready
  /// enroute
  /// delivered
  /// failed
  /// cancelled
  String status;
  String paymentStatus;
  double? subTotal;
  double? discount;
  double? deliveryFee;
  double? comission;
  double? tax;
  double? taxRate;
  double? tip;
  double? total;
  int? deliveryAddressId;
  double? distance;
  int? paymentMethodId;
  int? vendorId;
  int userId;
  int? driverId;
  String? pickupDate;
  String? pickupTime;
  DateTime createdAt;
  DateTime updatedAt;
  String formattedDate;
  String paymentLink;
  List<OrderProduct>? orderProducts;
  List<OrderStop>? orderStops;
  User user;
  User? driver;
  DeliveryAddress? deliveryAddress;
  PaymentMethod? paymentMethod;
  Vendor? vendor;
  OrderService? orderService;
  TaxiOrder? taxiOrder;

  //Package related
  PackageType? packageType;
  DeliveryAddress? pickupLocation;
  DeliveryAddress? dropoffLocation;
  DeliveryLatLong? deliveryLatLong;
  String? weight;
  String? length;
  String? height;
  String? width;
  String? payer;
  String? recipientName;
  String? recipientPhone;
  String? photo;
  List<OrderAttachment>? attachments;
  List<OrderFee>? fees;
  double? transitFeePerKm;
  Commission? commission;
  bool showDateHeader;

  ValueNotifier<double> pickupDistance = ValueNotifier<double>(0);
  ValueNotifier<int> pickupTravelTime = ValueNotifier<int>(0);

  factory Order.fromJson(dynamic json) {
    print("Addresseses");
    print(json["vendor"]);
    print(json["delivery_address"]);
    //parse fees
    dynamic fees = json["fees"];
    if (fees.runtimeType == String) {
      try {
        fees = jsonDecode(jsonDecode(fees));
      } catch (e) {
        fees = jsonDecode(fees);
      }
    }

    Order order = Order(
      id: json["id"],
      canRate: json["can_rate"],
      rateDriver: json["can_rate_driver"] ?? false,
      code: json["code"],
      verificationCode: json["verification_code"] ?? "",
      note: json["note"] ?? "--",
      type: json["type"],
      status: json["status"],
      paymentStatus: json["payment_status"],
      subTotal: json["sub_total"] == null
          ? null
          : double.parse(json["sub_total"].toString()),
      discount: json["discount"] == null
          ? null
          : double.parse(json["discount"].toString()),
      deliveryFee: json["delivery_fee"] == null
          ? null
          : double.parse(json["delivery_fee"].toString()),
      comission: json["comission"] == null
          ? null
          : double.parse(json["comission"].toString()),
      tax: json["tax"] == null ? null : double.parse(json["tax"].toString()),
      taxRate: json["tax_rate"] == null
          ? null
          : double.parse(json["tax_rate"].toString()),
      tip: json["tip"] == null ? 0.00 : double.parse(json["tip"].toString()),
      total:
          json["total"] == null ? null : double.parse(json["total"].toString()),
      distance: json["distance"] == null
          ? null
          : double.parse(json["distance"].toString()),
      deliveryAddressId: json["delivery_address_id"] == null
          ? null
          : int.parse(json["delivery_address_id"].toString()),
      paymentMethodId: json["payment_method_id"] == null
          ? null
          : int.parse(json["payment_method_id"].toString()),
      vendorId: json["vendor_id"] == null
          ? null
          : int.parse(json["vendor_id"].toString()),
      userId: int.parse(json["user_id"].toString()),
      driverId: json["driver_id"] == null
          ? null
          : int.parse(json["driver_id"].toString()),
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      formattedDate: json["formatted_date"],
      paymentLink: json["payment_link"] ?? "",
      //
      orderProducts: json["products"] == null
          ? []
          : List<OrderProduct>.from(
              json["products"].map((x) => OrderProduct.fromJson(x))),
      orderStops: json["stops"] == null
          ? []
          : List<OrderStop>.from(
              json["stops"].map((x) => OrderStop.fromJson(x))),
      user: User.fromJson(json["user"]),
      driver: json["driver"] == null ? null : User.fromJson(json["driver"]),
      deliveryAddress: json["delivery_address"] == null
          ? null
          : DeliveryAddress.fromJson(json["delivery_address"]),
      paymentMethod: json["payment_method"] == null
          ? null
          : PaymentMethod.fromJson(json["payment_method"]),
      vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
      orderService: json["order_service"] == null
          ? null
          : OrderService.fromJson(
              json["order_service"],
            ),
      taxiOrder: json["taxi_order"] == null
          ? null
          : TaxiOrder.fromJson(
              json["taxi_order"],
            ),

      //package related data
      packageType: json["package_type"] == null
          ? null
          : PackageType.fromJson(json["package_type"]),
      pickupLocation: json["pickup_location"] == null
          ? null
          : DeliveryAddress.fromJson(json["pickup_location"]),
      dropoffLocation: json["dropoff_location"] == null
          ? null
          : DeliveryAddress.fromJson(json["dropoff_location"]),
      deliveryLatLong: json['delivery_lat_long'] != null
          ? DeliveryLatLong.fromJson(json['delivery_lat_long'])
          : null,
      recipientName: json["recipient_name"],
      recipientPhone: json["recipient_phone"],
      pickupDate: json["pickup_date"] != null
          ? Jiffy.parse(json["pickup_date"]).format(pattern: "dd MMM, yyyy")
          : "",
      pickupTime: "${json["pickup_date"]} ${json["pickup_time"]}",
      // Jiffy("${json["pickup_date"]} ${json["pickup_time"]}","yyyy-MM-dd hh:mm:ss").format("hh:mm a"),
      weight: json["weight"].toString(),
      length: json["length"].toString(),
      height: json["height"].toString(),
      width: json["width"].toString(),
      payer: json["payer"].toString(),
      fees: json["fees"] == null
          ? []
          : List<OrderFee>.from(
              (fees as List).map(
                (x) => OrderFee.fromJson(x),
              ),
            ),
      //attachments
      attachments: json["attachments"] == null
          ? []
          : List<OrderAttachment>.from(
              json["attachments"].map(
                (x) => OrderAttachment.fromJson(x),
              ),
            ),
      photo: json["photo"],
      transitFeePerKm: null != json["transit_fee_per_km"]
          ? double.parse(json["transit_fee_per_km"].toString())
          : 0.0,
        commission: json["commission"] != null && json["commission"] is Map<String, dynamic>
            ? Commission.fromJson(json["commission"])
            : null

    );
    return order;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "verification_code": verificationCode,
        "note": note,
        "type": type,
        "status": status,
        "payment_status": paymentStatus,
        "sub_total": subTotal,
        "discount": discount,
        "delivery_fee": deliveryFee,
        "comission": comission,
        "tax": tax,
        "tax_rate": taxRate,
        "total": total,
        "tip": tip,
        "delivery_address_id": deliveryAddressId,
        "payment_method_id": paymentMethodId,
        "vendor_id": vendorId,
        "user_id": userId,
        "driver_id": driverId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "formatted_date": formattedDate,
        "payment_link": paymentLink,
        "products": List<dynamic>.from(
          (orderProducts ?? []).map((x) => x.toJson()),
        ),
        "stops": List<dynamic>.from((orderStops ?? []).map((x) => x.toJson())),
        "user": user.toJson(),
        "driver": driver?.toJson(),
        "delivery_address": deliveryAddress?.toJson(),
        "payment_method": paymentMethod?.toJson(),
        "vendor": vendor?.toJson(),
        "order_service": orderService?.toJson(),
        "taxi_order": taxiOrder?.toJson(),
        "transit_fee_per_km": transitFeePerKm,
        "fees": List<dynamic>.from((fees ?? []).map((x) => x.toJson())),
        "attachments": List<dynamic>.from(
          (attachments ?? []).map((x) => x.toJson()),
        ),
        "delivery_lat_long": deliveryLatLong?.toJson()
      };

  //getters

  //
  get isPaymentPending => paymentStatus == "pending";

  get isPackageDelivery => vendor?.vendorType?.slug == "parcel";

  //status => 'pending','preparing','enroute','failed','cancelled','delivered'
  get canChatVendor {
    if (!AppStrings.enableChat) {
      return false;
    }
    return ["pending", "preparing", "enroute"].contains(status);
  }

  get canChatCustomer {
    if (!AppStrings.enableChat) {
      return false;
    }
    return !["failed", "delivered", "cancelled"].contains(status);
  }

  get canChatDriver => ["enroute"].contains(status);

  String get taxiStatus {
    return status.contains("deliver") ? "completed" : status;
  }

  //
  bool get isUnpaid {
    return ['pending', 'request', 'review'].contains(paymentStatus) &&
        !["wallet", "cash"].contains([paymentMethod?.slug]);
  }

  get duration {
    return updatedAt.difference(createdAt).inMinutes;
  }

/*double get pickupDistance {
    return Geolocator.distanceBetween(
          LocationService().currentLocation?.latitude ?? 0.00,
          LocationService().currentLocation?.longitude ?? 0.00,
          vendor?.latitude.toDouble() ?? 0.0,
          vendor?.longitude.toDouble() ?? 0.0,
        ) /
        1000;
  }*/
}

class DeliveryLatLong {
  double? latitude;
  double? longitude;

  DeliveryLatLong({this.latitude, this.longitude});

  DeliveryLatLong.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
