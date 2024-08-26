import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/order.dart';
import 'package:driver/services/http.service.dart';

class TaxiRequest extends HttpService {
  //
  Future<Order?> getOnGoingTrip() async {
    final apiResult = await get(Api.currentTaxiBooking);
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    //
    if (apiResponse.allGood) {
      //if there is order
      if (apiResponse.body is Map && apiResponse.body.containsKey("order")) {
        return Order.fromJson(apiResponse.body["order"]);
      } else {
        return null;
      }
    }

    //
    throw apiResponse.body;
  }

  //
  Future<ApiResponse> cancelTrip(int id) async {
    final apiResult = await get(
      "${Api.cancelTaxiBooking}/$id",
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> rateUser(
    int orderId,
    int userId,
    double newTripRating,
    String review,
  ) async {
    //
    final apiResult = await post(
      "${Api.rating}",
      {
        //
        "user_id": userId,
        "order_id": orderId,
        "rating": newTripRating,
        "review": review,
      },
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> rejectAssignment(int orderId, int driverId) async {
    //
    final apiResult = await post(
      "${Api.rejectTaxiBookingAssignment}",
      {
        //
        //"driver_id": driverId,
        "order_id": orderId,
      },
    );
    print(apiResult.data);
    //
    return ApiResponse.fromResponse(apiResult);
  }
}
