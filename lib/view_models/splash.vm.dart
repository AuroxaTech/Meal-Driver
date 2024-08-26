import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_routes.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/constants/app_theme.dart';
import 'package:driver/requests/settings.request.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/services/firebase.service.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/views/pages/permission/permission.page.dart';
import 'package:driver/widgets/cards/language_selector.view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashViewModel extends MyBaseViewModel {
  SplashViewModel(BuildContext context) {
    viewContext = context;
  }

  SettingsRequest settingsRequest = SettingsRequest();

  initialise() async {
    super.initialise();
    await loadAppSettings();
  }

  loadAppSettings() async {
    setBusy(true);
    try {
      final appSettingsObject = await settingsRequest.appSettings();
      //app settings
      await updateAppVariables(appSettingsObject.body["strings"]);
      //colors
      await updateAppTheme(appSettingsObject.body["colors"]);
      loadNextPage();
    } catch (error) {
      setError(error);
      print("Error loading app settings ==> $error");
    }
    setBusy(false);
  }

  updateAppVariables(dynamic json) async {
    await AppStrings.saveAppSettingsToLocalStorage(jsonEncode(json));
  }

  //theme change
  updateAppTheme(dynamic colorJson) async {
    await AppColor.saveColorsToLocalStorage(jsonEncode(colorJson));
    //change theme
    // await AdaptiveTheme.of(viewContext).reset();
    AdaptiveTheme.of(viewContext).setTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      notify: true,
    );
    await AdaptiveTheme.of(viewContext).persist();
  }

  loadNextPage() async {
    await Utils.setJiffyLocale();

    print("loadNextPage=================================================== 1");
    if (AuthServices.firstTimeOnApp()) {
      print(
          "loadNextPage=================================================== 2");
      //Navigator.of(viewContext).pushNamedAndRemoveUntil(AppRoutes.welcomeRoute, (route) => false);
      //choose language
      await AuthServices.firstTimeCompleted();
      await showModalBottomSheet(
        context: viewContext,
        builder: (context) {
          return AppLanguageSelector();
        },
      );
    } else if (!AuthServices.authenticated()) {
      print(
          "loadNextPage=================================================== 3");
      Navigator.of(viewContext)
          .pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
    } else {
      print(
          "loadNextPage=================================================== 4");
      var inUseStatus = await Permission.locationWhenInUse.status;
      var alwaysUseStatus = await Permission.locationAlways.status;
      final bgPermissinGranted =
          Platform.isIOS ? true : await FlutterBackground.hasPermissions;

      print(
          "loadNextPage==== inUseStatus =>  $inUseStatus  =============alwaysUseStatus => $alwaysUseStatus ===============bgPermissinGranted => $bgPermissinGranted================ 5");
      if (bgPermissinGranted &&
          inUseStatus.isGranted &&
          alwaysUseStatus.isGranted) {
        print(
            "loadNextPage=================================================== 5");
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) => false,
        );
      } else {
        print(
            "loadNextPage=================================================== 6");
        viewContext.nextAndRemoveUntilPage(PermissionPage());
      }
      print(
          "loadNextPage=================================================== 7");
    }

    /*print("loadNextPage=================================================== 9");
    RemoteMessage? initialMessage =
        await FirebaseService().firebaseMessaging.getInitialMessage();
    if (initialMessage == null) {
      print(
          "loadNextPage=================================================== 10");
      Navigator.of(viewContext)
          .pushNamedAndRemoveUntil(AppRoutes.loginRoute, (route) => false);
      return;
    }
    print("loadNextPage=================================================== 11");
    FirebaseService().saveNewNotification(initialMessage);
    FirebaseService().notificationPayloadData = initialMessage.data;
    FirebaseService().selectNotification("");*/
  }
}
