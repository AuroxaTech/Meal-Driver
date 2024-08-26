import 'package:dio/dio.dart';
import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/order.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/services/http.service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderRequest extends HttpService {
  //
  Future<List<Order>> getOrders({
    int page = 1,
    String? status,
    String? type,
  }) async {
    final apiResult = await get(
      Api.orders,
      queryParameters: {
        "driver_id": (await AuthServices.getCurrentUser()).id,
        "page": page,
        // "status": status,
        // "type": type,
      },
    );
    print("Orders History =======>${apiResult}");
    print({
      "driver_id": (await AuthServices.getCurrentUser()).id,
      "page": page,
      // "status": status,
      // "type": type,
    });

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Order.fromJson(jsonObject);
      }).toList();
    } else {
      throw "Order API Error =======>${apiResponse.message}";

    }
  }

  //
  Future<List<Order>> lookingOrders(
      {Map<String, dynamic>? queryParameters}) async {
    print(queryParameters);
    final apiResult =
        await get(Api.lookingForOrder, queryParameters: queryParameters);

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    print('lookingForOrder ========> ${apiResponse.data}');
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Order.fromJson(jsonObject);
      }).toList();
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<Order> getOrderDetails({required int id}) async {
    final apiResult = await get("${Api.orders}/$id");
    print('Order Details =======> $apiResult');
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body);
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<Order> updateOrder({
    required int id,
    String status = "delivered",
    LatLng? location,
  }) async {
    final apiResult = await patch(
      "${Api.orders}/$id",
      {
        "status": status,
        "latlng": "${location?.latitude},${location?.longitude}"
      },
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body["order"]);
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> updateOrderWithSignature({
    required int id,
    String status = "delivered",
    String? signaturePath,
    String typeOfProof = "signature",
  }) async {
    //compress signature image

    //
    XFile? signature;
    if (signaturePath != null) {
      signature = await AppService().compressFile(signaturePath);
    }
    //
    final apiResult = await postWithFiles(
      "${Api.orders}/$id",
      {
        "_method": "PUT",
        "status": status,
        "proof_type": typeOfProof,
        "signature": signature != null
            ? await MultipartFile.fromFile(
                signature.path,
              )
            : null,
      },
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> verifyOrderStopRequest({
    required int id,
    String? signaturePath,
    String typeOfProof = "signature",
  }) async {
    //compress signature image

    //
    XFile? signature;
    if (signaturePath != null) {
      signature = await AppService().compressFile(signaturePath);
    }
    //
    final apiResult = await postWithFiles(
      "${Api.orderStopVerification}/$id",
      {
        "proof_type": typeOfProof,
        "signature": signature != null
            ? await MultipartFile.fromFile(
                signature.path,
              )
            : null,
      },
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<Order> acceptNewOrder(int id, {String status = "preparing"}) async {
    final apiResult = await post(
      Api.acceptTaxiBookingAssignment,
      {
        // "status": status,
        // "driver_id": (await AuthServices.getCurrentUser()).id,
        "order_id": id,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body["order"]);
    } else {
      throw "${apiResponse.message}";
    }
  }

  //"delivered"  "enroute"
  Future<Order> updateOrderStatus(int id,
      {required String status}) async {
    final apiResult = await post(
      Api.updateTaxiBookingAssignmentStatus,
      {
        "status": status,
        "order_id": id,
      },

    );
    print({
      "status ": status,
      "order_id": id,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body["order"]);
    } else {
      throw "API Response =====> ${apiResponse.message}";
    }
  }

}
