import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:driver/views/pages/permission/widgets/request_bg_location_permission.view.dart';
import 'package:driver/views/pages/permission/widgets/request_bg_permission.view.dart';
import 'package:driver/views/pages/permission/widgets/request_location_permission.view.dart';
import 'package:driver/views/pages/permission/widgets/request_overlay_permission.view.dart';
import 'package:driver/views/pages/shared/home.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class PermissionViewModel extends MyBaseViewModel {
  PermissionViewModel(BuildContext context) {
    this.viewContext = context;
  }

  int currentStep = 0;
  PageController pageController = PageController();
  bool locationPermissionGranted = false;
  bool bgLocationPermissionGranted = false;
  bool bgPermissionGranted = false;
  bool overlayPermissionGranted = false;

  void initialise() async {
    //
    await fetchAllNeededPermissions();
  }

  fetchAllNeededPermissions() async {
    locationPermissionGranted = await isLocationPermissionGranted();
    bgLocationPermissionGranted = await isBgLocationPermissionGranted();
    bgPermissionGranted = await isBgPermissionGranted();
    overlayPermissionGranted = await isOverlayPermissionGranted();

    // if all permissions granted
    if (locationPermissionGranted && bgLocationPermissionGranted) {
      //for android
      if (Platform.isAndroid &&
          bgPermissionGranted &&
          overlayPermissionGranted) {
        loadHomepage();
      } else {
        loadHomepage();
      }
    }
  }

  List<Widget> permissionPages() {
    List<Widget> pages = [];

    //location permission
    pages.add(RequestLocationPermissionView(this));
    //bg location permission
    pages.add(RequestBGLocationPermissionView(this));

    if (Platform.isAndroid) {
      pages.add(RequestBGPermissionView(this));
    }

    //overlay permission
    if (Platform.isAndroid) {
      pages.add(RequestOverlayPermissionView(this));
    }

    return pages;
  }

  onPageChanged(int index) {
    currentStep = index;
    notifyListeners();
  }

  //
  Future<bool> isLocationPermissionGranted() async {
    var status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> isBgLocationPermissionGranted() async {
    var status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  Future<bool> isOverlayPermissionGranted() async {
    var status = await Permission.systemAlertWindow.status;
    return status.isGranted;
  }

  Future<bool> isBgPermissionGranted() async {
    return Platform.isAndroid && await FlutterBackground.hasPermissions;
  }

  // //
  // bool showLocationPermissionView() {
  //   return currentStep == 0 && !locationPermissinGranted;
  // }

  // bool showBgLocationPermissionView() {
  //   return currentStep == 1 && !bgLocationPermissinGranted;
  // }

  // bool showBgPermissionView() {
  //   return currentStep == 2 && !bgPermissinGranted;
  // }

  // showContinueBtn() {
  //   //
  //   return !showLocationPermissionView() &
  //       !showBgLocationPermissionView() &
  //       !showBgPermissionView();
  // }

//PERMISSION HANDLERS

  Future<void> handleLocationPermission(BuildContext context) async {
    var status = await Permission.location.request();
    print("Location permission status: $status");

    if (status.isGranted) {
      print("Permission granted.");
      nextStep(); // Only move to the next step when permission is granted
    } else if (status.isPermanentlyDenied) {
      print("Permission permanently denied.");
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Location Permission Required"),
          content: Text(
              "This app needs location access to function properly. Please enable location permissions in your device settings."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: Text("Open Settings"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Show error only when denied permanently
                toastError("Permission denied permanently");
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      );
    } else {
      // Permission denied but not permanently
      print("Permission denied.");
      toastError("Permission denied"); // Show error when denied
    }

    // Ensure UI is updated
    notifyListeners();
  }





  handleBackgroundLocationPermission() async {
    PermissionStatus status = await Permission.locationAlways.request();
    if (status.isGranted) {
      nextStep();
      notifyListeners();
    } else {
      toastError("Background Location Permission denied".tr());
    }

    if (status.isPermanentlyDenied) {
      nextStep();
      notifyListeners();
      return;
    }
  }

  handleOverlayPermission() async {
    PermissionStatus status = await Permission.systemAlertWindow.request();
    if (status.isGranted) {
      nextStep();
    } else if (status.isPermanentlyDenied) {
      toastError("Permission is permanently denied".tr());
      return;
    } else {
      toastError("Permission denied".tr());
    }
  }

  bool bgPermissinGranted = false;
  handleBackgroundPermission() async {
    if (Platform.isAndroid) {
      //
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Background service".tr(),
        notificationText: "Background notification to keep app running".tr(),
        notificationImportance: AndroidNotificationImportance.Default,
        notificationIcon: AndroidResource(
          name: 'notification_icon',
          defType: 'drawable',
        ), // Default is ic_launcher from folder mipmap
      );

      //check for permission
      //CALL THE PERMISSION HANDLER
      await FlutterBackground.initialize(androidConfig: androidConfig);
      bool isGranted = await FlutterBackground.hasPermissions;
      if (isGranted) {
        await FlutterBackground.initialize(androidConfig: androidConfig);
        await FlutterBackground.enableBackgroundExecution();
      }
      nextStep();
    }
    nextStep();
  }

  //
  nextStep() {
    if ((currentStep + 1) >= permissionPages().length) {
      loadHomepage();
    } else {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }

    notifyListeners();
  }

  loadHomepage() {
    viewContext.nextAndRemoveUntilPage(
      HomePage(),
    );
  }
}
