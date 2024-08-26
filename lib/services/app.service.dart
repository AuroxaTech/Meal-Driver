import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:driver/models/order.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:singleton/singleton.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class AppService {
  //

  /// Factory method that reuse same instance automatically
  factory AppService() => Singleton.lazy(() => AppService._());

  /// Private constructor
  AppService._() {}

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BehaviorSubject<int> homePageIndex = BehaviorSubject<int>();
  BehaviorSubject<bool> refreshAssignedOrders = BehaviorSubject<bool>();
  BehaviorSubject<Order> addToAssignedOrders = BehaviorSubject<Order>();
  bool driverIsOnline = false;
  StreamSubscription? actionStream;
  List<int> ignoredOrders = [];
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  changeHomePageIndex({int index = 2}) async {
    print("Changed Home Page");
    homePageIndex.add(index);
  }

  //
  void playNotificationSound() {
    try {
      assetsAudioPlayer.stop();
    } catch (error) {
      print("Error stopping audio player");
    }

    //
    assetsAudioPlayer.open(
      Audio("assets/audio/alert.mp3"),
      loopMode: LoopMode.single,
      notificationSettings: const NotificationSettings(
        nextEnabled: false,
        prevEnabled: false,
        stopEnabled: false,
        seekBarEnabled: false,
      ),
      showNotification: true,
      playInBackground: PlayInBackground.enabled,
    );
  }

  void stopNotificationSound() {
    try {
      assetsAudioPlayer.stop();
    } catch (error) {
      print("Error stopping audio player");
    }
  }

  Future<XFile?> compressFile(String filePath, {int quality = 50}) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/temp_${randomAlphaNumeric(10)}.jpg";
    //
    var result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: quality,
    );
    print("Compressed File size ==> ${await result?.length()}");
    return result;
  }
}
