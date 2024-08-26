import 'package:flutter/material.dart';
import 'package:driver/models/payment_account.dart';
import 'package:driver/requests/payment_account.request.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:driver/views/pages/payment_account/edit_payment_account.page.dart';
import 'package:driver/views/pages/payment_account/new_payment_account.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class PaymentAccountViewModel extends MyBaseViewModel {
  //
  PaymentAccountViewModel(BuildContext context) {
    viewContext = context;
  }

  //
  PaymentAccountRequest paymentAccountRequest = PaymentAccountRequest();
  RefreshController refreshController = RefreshController();

  List<PaymentAccount> paymentAccounts = [];
  int queryPage = 1;

  //
  initialise() async {
    await getPaymentAccounts();
  }

  getPaymentAccounts({bool initialLoading = true}) async {
    //
    if (initialLoading) {
      setBusyForObject(paymentAccounts, true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage = queryPage + 1;
    }

    try {
      //
      final mWalletTransactions = await paymentAccountRequest.paymentAccounts(
        page: queryPage,
      );
      //
      if (initialLoading) {
        paymentAccounts = mWalletTransactions;
      } else {
        paymentAccounts.addAll(mWalletTransactions);
        refreshController.loadComplete();
      }
      clearErrors();
    } catch (error) {
      print("paymentAccounts error ==> $error");
      setErrorForObject(paymentAccounts, error);
    }
    setBusyForObject(paymentAccounts, false);
  }

  //

  void openNewPaymentAccount() async {
    final result = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => const NewPaymentAccountPage(),
      ),
    );

    //
    if (result != null && result is PaymentAccount) {
      paymentAccounts.insert(0, result);
      notifyListeners();
    }
  }

  void editPaymentAccount(PaymentAccount paymentAccount) async {
    final result = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => EditPaymentAccountPage(paymentAccount),
      ),
    );

    //
    if (result != null && result is PaymentAccount) {
      //
      final index = paymentAccounts.indexWhere(
        (element) => paymentAccount.id == element.id,
      );
      paymentAccounts[index] = result;
      notifyListeners();
    }
  }
}
