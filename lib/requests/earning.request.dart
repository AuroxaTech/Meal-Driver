import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/currency.dart';
import 'package:driver/models/earning.dart';
import 'package:driver/services/http.service.dart';

class EarningRequest extends HttpService {
  Future<List<dynamic>> getEarning({bool todayEarning = false}) async {
    final apiResult = await get(Api.earning, queryParameters: {
      "today_earning": todayEarning ? "1" : "0",
    });
    print("Earning  ======> ${apiResult}");


    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return [
        Currency.fromJSON(apiResponse.body["currency"]),
        Earning.fromJson(apiResponse.body["earning"]),
      ];
    } else {
      throw "${apiResponse.message}";
    }
  }
}
