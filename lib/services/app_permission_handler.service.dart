import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/widgets/bottomsheets/background_location_permission.bottomsheet.dart';
import 'package:driver/widgets/bottomsheets/background_permission.bottomsheet.dart';
import 'package:driver/widgets/bottomsheets/regular_location_permission.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandlerService {
  //MANAGE BACKGROUND SERVICE PERMISSION
  Future<bool> handleBackgroundRequest() async {
    //check for permission
    bool hasPermissions = await FlutterBackground.hasPermissions;
    if (!hasPermissions) {
      //background app service permission
      final result = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return BackgroundPermissionDialog();
        },
      );
      //
      if (result != null && (result is bool) && result) {
        hasPermissions = result;
      }
    }

    return hasPermissions;
  }

  //MANAGE LOCATION PERMISSION
  Future<bool> isLocationGranted() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> handleLocationRequest() async {
    var status = await Permission.locationWhenInUse.status;

    if (!status.isGranted) {
      final requestResult = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return RegularLocationPermissionDialog();
        },
      );

      if (requestResult == null || !(requestResult is bool && requestResult)) {
        return false;
      }

      status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        permissionDeniedAlert();
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }

      final backgroundRequestResult = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return BackgroundLocationPermissionDialog();
        },
      );

      if (backgroundRequestResult == null || !(backgroundRequestResult is bool && backgroundRequestResult)) {
        return false;
      }

      status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        permissionDeniedAlert();
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    }

    // If "WhenInUse" permission is granted, check "Always"
    status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      final backgroundRequestResult = await showDialog(
        barrierDismissible: false,
        context: AppService().navigatorKey.currentContext!,
        builder: (context) {
          return BackgroundLocationPermissionDialog();
        },
      );

      if (backgroundRequestResult == null || !(backgroundRequestResult is bool && backgroundRequestResult)) {
        return false;
      }

      status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        permissionDeniedAlert();
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
    }

    return true;
  }


  //
  void permissionDeniedAlert() async {
    //The user deny the permission
    await Fluttertoast.showToast(
      msg: "Permission denied".tr(),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
