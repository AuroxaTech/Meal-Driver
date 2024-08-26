import 'package:driver/constants/api.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/wallet.dart';
import 'package:driver/models/wallet_transaction.dart';
import 'package:driver/services/http.service.dart';

class WalletRequest extends HttpService {
  //
  Future<Wallet> walletBalance() async {
    final apiResult = await get(Api.walletBalance);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Wallet.fromJson(apiResponse.body);
    }

    throw "${apiResponse.message}";
  }

  Future<String> walletTopup(String amount) async {
    final apiResult = await post(Api.walletTopUp, {"amount": amount});
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.body["link"];
    }

    throw "${apiResponse.message}";
  }

  Future<List<WalletTransaction>> walletTransactions({int page = 1}) async {
    final apiResult =
        await get(Api.walletTransactions, queryParameters: {"page": page});

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body["data"] as List)
          .map((e) => WalletTransaction.fromJson(e))
          .toList();
    }

    throw "${apiResponse.message}";
  }

  Future<ApiResponse> transferBalanceRequest({
    required String amount,
    required int userId,
  }) async {
    final apiResult = await post(
      Api.transferWalletBalance,
      {
        "user_id": userId,
        "amount": amount,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
