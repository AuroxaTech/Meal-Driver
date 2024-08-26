import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:driver/models/payment_account_info.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../requests/payment_account.request.dart';

class BankAccountDetailsViewModel extends MyBaseViewModel {
  File? newPhoto;

  TextEditingController nameTEC = TextEditingController();
  TextEditingController accountNumberTEC = TextEditingController();
  TextEditingController transitNumberTEC = TextEditingController();
  TextEditingController institutionNumberTEC = TextEditingController();

  final PaymentAccountRequest _paymentAccountRequest = PaymentAccountRequest();
  final picker = ImagePicker();

  BankAccountDetailsViewModel(BuildContext context) {
    viewContext = context;
  }

  initialise() {
    fetchAccountDetails();
  }

  void fetchAccountDetails() async {
    setBusy(true);
    try {
      PaymentAccountInfo? paymentAccountInfo =
          await _paymentAccountRequest.getPayoutAccount();
      if (null != paymentAccountInfo) {
        nameTEC.text = paymentAccountInfo.name;
        accountNumberTEC.text = paymentAccountInfo.accountNumber;
        transitNumberTEC.text = paymentAccountInfo.transitNumber;
        institutionNumberTEC.text = paymentAccountInfo.institutionNumber;
      }
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      toastError("$error");
    }
    setBusy(false);
  }

  processUpdate() async {
    if (formKey.currentState!.validate()) {
      setBusy(true);
      final apiResponse = await _paymentAccountRequest.savePayoutAccount(
        name: nameTEC.text,
        accountNumber: accountNumberTEC.text,
        transitNumber: transitNumberTEC.text,
        institutionNumber: institutionNumberTEC.text,
      );
      setBusy(false);
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Bank Account Details",
        text: apiResponse.message,
        onConfirmBtnTap: apiResponse.allGood
            ? () {
                Navigator.pop(viewContext);
                Navigator.pop(viewContext, true);
              }
            : null,
      );
    }
  }
}
