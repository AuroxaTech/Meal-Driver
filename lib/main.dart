import 'dart:async';
import 'dart:io';
import 'package:driver/white_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:driver/my_app.dart';
import 'package:driver/services/general_app.service.dart';
import 'package:driver/services/local_storage.service.dart';
import 'package:driver/services/firebase.service.dart';
import 'package:driver/services/location_watcher.service.dart';
import 'package:driver/services/overlay.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_languages.dart';
import 'firebase_options.dart';
import 'services/notification.service.dart';
import 'views/overlays/floating_app_bubble.view.dart';

//Updated Code
//ssll handshake error
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FloatingAppBubble(),
    ),
  );
}

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      //setting up firebase notifications
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      //
      await LocalizeAndTranslate.init(
        defaultType: LocalizationDefaultType.asDefined,
        assetLoader: const AssetLoaderRootBundleJson('assets/lang/'),
        supportedLanguageCodes: AppLanguages.codes,
      );
      //
      await LocalStorageService.getPrefs();

      //await NotificationService.clearIrrelevantNotificationChannels();
      await NotificationService.initializeAwesomeNotification();
      await NotificationService.listenToActions();

      await FirebaseService().setUpFirebaseMessaging();
      FirebaseMessaging.onBackgroundMessage(
        GeneralAppService.onBackgroundMessageHandler,
      );
      LocationServiceWatcher.listenToDelayLocationUpdate();
      //
      OverlayService1().closeFloatingBubble();

      //prevent ssl error
      HttpOverrides.global = MyHttpOverrides();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Run app!
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime now = DateTime.now();
      String firstLaunchKey = 'first_launch';
      String? firstLaunch = prefs.getString(firstLaunchKey);
      DateTime firstLaunchDate;

      if (firstLaunch == null) {
        prefs.setString(firstLaunchKey, now.toIso8601String());
        firstLaunchDate = now;
      } else {
        firstLaunchDate = DateTime.parse(firstLaunch);
      }

      int daysDifference = now.difference(firstLaunchDate).inDays;
      Widget appChild = (daysDifference >= 7) ? const WhiteScreen() : const MyApp();
      appChild = MyApp();
      runApp(
        LocalizedApp(
          child: appChild,
        ),
      );
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
