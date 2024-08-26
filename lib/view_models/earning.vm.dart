import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:driver/models/currency.dart';
import 'package:driver/models/earning.dart';
import 'package:driver/models/payment_account.dart';
import 'package:driver/requests/earning.request.dart';
import 'package:driver/requests/payment_account.request.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../widgets/bottomsheets/earning.bottomsheet.dart';

class EarningViewModel extends MyBaseViewModel {
  EarningRequest earningRequest = EarningRequest();
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  Currency? currency;
  Earning? earning;
  bool showPayout = false;
  List<PaymentAccount> paymentAccounts = [];
  PaymentAccount? selectedPaymentAccount;
  TextEditingController amountTEC = TextEditingController();

  EarningViewModel(BuildContext context) {
    viewContext = context;
  }

  @override
  void initialise() async {
    fetchEarning();
  }

  fetchEarning() async {
    setBusy(true);
    try {
      final results = await earningRequest.getEarning();
      currency = results[0];
      earning = results[1];
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  void requestEarningPayout() async {
    showPayout = true;
    notifyListeners();
    //
    if (paymentAccounts.isNotEmpty) {
      return;
    }
    //
    setBusyForObject(paymentAccounts, true);
    try {
      paymentAccounts = (await paymentAccountRequest.paymentAccounts(page: 0))
          .filter((e) => e.isActive)
          .toList();
    } catch (error) {
      print("paymentAccounts error ==> $error");
    }
    setBusyForObject(paymentAccounts, false);
  }

  //Earning
  showEarning() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const EarningBottomSheet();
      },
    );
  }

  processPayoutRequest() async {
    setBusy(true);
    final apiResponse = await paymentAccountRequest.requestPayout({});
    setBusy(false);
    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Request Payout".tr(),
      text: apiResponse.allGood ? "Successful".tr() : "${apiResponse.message}",
      onConfirmBtnTap: apiResponse.allGood
          ? () {
              Navigator.pop(viewContext);
            }
          : null,
    ).then((value) {
      fetchEarning();
    });
    //
    /*if (selectedPaymentAccount == null) {
      toastError("Please select payment account".tr());
      //
    } else if (formKey.currentState!.validate()) {
      setBusyForObject(selectedPaymentAccount, true);
      //
      final apiResponse = await paymentAccountRequest.requestPayout(
        {
          "amount": amountTEC.text,
          "payment_account_id": selectedPaymentAccount?.id,
        },
      );
      //
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Request Payout".tr(),
        text:
            apiResponse.allGood ? "Successful".tr() : "${apiResponse.message}",
        onConfirmBtnTap: apiResponse.allGood
            ? () {
                Navigator.pop(viewContext);
                Navigator.pop(viewContext);
              }
            : null,
      );

      setBusyForObject(selectedPaymentAccount, false);
    }*/
  }
}
