import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/payment_account.dart';
import 'package:driver/services/http.service.dart';

import '../models/payment_account_info.dart';

class PaymentAccountRequest extends HttpService {
  //
  Future<ApiResponse> newPaymentAccount(Map<String, dynamic> payload) async {
    final apiResult = await post(Api.paymentAccount, payload);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updatePaymentAccount(
      int id, Map<String, dynamic> payload) async {
    final apiResult = await patch(Api.paymentAccount + "/$id", payload);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<PaymentAccount>> paymentAccounts({int page = 1}) async {
    final apiResult = await get(
      Api.paymentAccount,
      queryParameters: {"page": page},
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      var data = apiResponse.body["data"];

      // Since the data is a single object, we wrap it in a list
      if (data is Map) {
        return [PaymentAccount.fromJson(data.cast<String, dynamic>())];
      } else if (data is List) {
        // If by any chance the data is a list in other cases, handle it
        return data.map((e) => PaymentAccount.fromJson(e)).toList();
      } else {
        throw "Unexpected data format: ${data.runtimeType}";
      }
    }

    throw "${apiResponse.message}";
  }


  //
  Future<ApiResponse> requestPayout(Map<String, dynamic> payload) async {
    final apiResult = await post(Api.payoutRequest, payload);
    print("Request Payout ====> ${apiResult.data}");
    return ApiResponse.fromResponse(apiResult);
  }

  Future<PaymentAccountInfo?> getPayoutAccount({
    int page = 1,
    String? status,
    String? type,
  }) async {
    final apiResult = await get(Api.paymentAccount);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return PaymentAccountInfo.fromJson(apiResponse.body['data']);
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> savePayoutAccount({
    required String name,
    required String accountNumber,
    required String transitNumber,
    required String institutionNumber,
  }) async {
    final apiResult = await post(
      Api.paymentAccount,
      {
        "bank_name": name,
        "account_number": accountNumber,
        "ifsc_code": transitNumber,
        "account_type": institutionNumber,
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }
}
