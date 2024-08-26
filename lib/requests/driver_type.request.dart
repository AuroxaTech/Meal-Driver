import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/services/http.service.dart';

class DriverTypeRequest extends HttpService {
  //
  Future<ApiResponse> switchType(Map payload) async {
    final apiResult = await post(Api.driverTypeSwitch, payload);
    return ApiResponse.fromResponse(apiResult);
  }
}
