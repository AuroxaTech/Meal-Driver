import 'dart:io';
import 'package:flutter/material.dart';
import 'package:driver/view_models/base.view_model.dart';

import '../constants/app_routes.dart';

class SettingViewModel extends MyBaseViewModel {



  String soundValue = "ON";
  String vibrationValue = "ON";
  String nightModeOption = 'AUTO';
  String taxInfo = '';
  String navigationOption = Platform.isIOS ? "Apple Maps" : 'Google Maps';
  String communicationOption = 'Call Me';
  String locationOption = 'Allow';

  final List<String> nightModeLabels = ["ON", "OFF", "AUTO"];
  final List<String> navigationLabels = [Platform.isIOS ? "Apple Maps" : 'Google Maps',"Waze"];
  final List<String> communicationLabels = ["Call me", "Text me"];
  final List<String> locationLabels = ["Allow", "While Using", "Not Allowed"];

  SettingViewModel(BuildContext context) {
    this.viewContext = context;
  }
  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.changePasswordRoute,
    );
  }
  openBankAccountDetails() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.bankAccountDetailsRoute,
    );
  }
}
