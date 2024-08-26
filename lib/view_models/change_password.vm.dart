import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:driver/requests/auth.request.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ChangePasswordViewModel extends MyBaseViewModel {
  File? newPhoto;

  //the textediting controllers
  TextEditingController currentPasswordTEC = TextEditingController();
  TextEditingController newPasswordTEC = TextEditingController();
  TextEditingController confirmNewPasswordTEC = TextEditingController();

  //
  final AuthRequest _authRequest = AuthRequest();
  final picker = ImagePicker();

  ChangePasswordViewModel(BuildContext context) {
    viewContext = context;
  }

  //
  processUpdate() async {
    //
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);

      //
      final apiResponse = await _authRequest.updatePassword(
        password: currentPasswordTEC.text,
        new_password: newPasswordTEC.text,
        new_password_confirmation: confirmNewPasswordTEC.text,
      );

      //
      setBusy(false);

      //
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Change Password".tr(),
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
