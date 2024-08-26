import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/services/http.service.dart';

import '../models/driver_shift_request.dart';
import '../models/shift.dart';

class ShiftRequest extends HttpService {
  //
  Future<String> requestShift({
    required int shiftId,
  }) async {
    final apiResult = await post(
      Api.requestShift,
      {
        "driver_id": (await AuthServices.getCurrentUser()).id,
        "shift_id": shiftId,
        // "status": status,
        // "type": type,
      },
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.message ?? "";
    } else {
      throw "${apiResponse.message}";
    }
  }

  //
  Future<List<Shift>> getShifts() async {
    final apiResult = await get(Api.shifts);

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Shift.fromJson(jsonObject);
      }).toList();
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<Map<int, DriverShiftRequest>> getMyShifts() async {
    final apiResult = await get(Api.myShifts);

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      Map<int, DriverShiftRequest> response = {};
      for (var jsonObject in apiResponse.data) {
        DriverShiftRequest driverShiftRequest =
            DriverShiftRequest.fromJson(jsonObject);
        response[driverShiftRequest.shiftId] = driverShiftRequest;
      }
      return response;
    } else {
      throw "${apiResponse.message}";
    }
  }
}
