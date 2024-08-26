import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/services/http.service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:http/http.dart' as http;
import 'package:localize_and_translate/localize_and_translate.dart';

class Utils {
  //
  static bool get isArabic =>
      LocalizeAndTranslate.getLocale().languageCode == "ar";

  static TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  //
  static bool get currencyLeftSided {
    final uiConfig = AppStrings.uiConfig;
    if (uiConfig != null && uiConfig["currency"] != null) {
      final currencylOCATION = uiConfig["currency"]["location"] ?? 'left';
      return currencylOCATION.toLowerCase() == "left";
    } else {
      return true;
    }
  }

  // Function to calculate distance between two points using Haversine formula
  static double distanceBetweenPoints(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    final double lat1Rad = degreesToRadians(point1.latitude);
    final double lat2Rad = degreesToRadians(point2.latitude);
    final double deltaLat = degreesToRadians(point2.latitude - point1.latitude);
    final double deltaLon =
        degreesToRadians(point2.longitude - point1.longitude);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;
    return distance;
  }

  //get vendor distance from address
  static Future<List<double>> vendorDistanceFromDefaultAddress(
      LatLng sourceLocation, LatLng destinationLocation) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${sourceLocation.latitude},${sourceLocation.longitude}'
        '&destination=${destinationLocation.latitude},${destinationLocation.longitude}'
        '&key=AIzaSyBDc75DLs1UQ25VQfWAQhl4cthGEjaaV9Q&alternatives=true';
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] != "ZERO_RESULTS") {
        print("Map route ${data['routes']}");
        String distance = data['routes'][0]['legs'][0]['distance']['text'];
        String duration = data['routes'][0]['legs'][0]['duration']['text'];
        double travelDistance = double.tryParse(distance.split(' ').first) ?? 0;
        int travelTime = int.tryParse(duration.split(' ').first) ?? 0;

        print("Map distance $distance $travelDistance $duration $travelTime");
        return [travelDistance, travelTime.toDouble()];
      }
    } else {
      print("Failed to get location distance");
    }
    return [];
  }

  // Function to convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static bool isDark(Color color) {
    return ColorUtils.calculateRelativeLuminance(
            color.red, color.green, color.blue) <
        0.5;
  }

  static bool isPrimaryColorDark([Color? mColor]) {
    final color = mColor ?? AppColor.primaryColor;
    return ColorUtils.calculateRelativeLuminance(
            color.red, color.green, color.blue) <
        0.5;
  }

  static Color textColorByTheme() {
    return isPrimaryColorDark() ? Colors.white : Colors.black;
  }

  static Color textColorByColor(Color color) {
    return isPrimaryColorDark(color) ? Colors.white : Colors.black;
  }

  ///
  Future<Uint8List> getBytesFromCanvas(int width, int height, urlAsset) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final ByteData datai = await rootBundle.load(urlAsset);
    var imaged = await loadImage(new Uint8List.view(datai.buffer));
    canvas.drawImageRect(
      imaged,
      Rect.fromLTRB(
          0.0, 0.0, imaged.width.toDouble(), imaged.height.toDouble()),
      Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble()),
      new Paint(),
    );

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List() ?? Uint8List(0);
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  static setJiffyLocale() async {
    String cLocale = LocalizeAndTranslate.getLocale().languageCode;
    List<String> supportedLocales = Jiffy.getSupportedLocales();
    if (supportedLocales.contains(cLocale)) {
      await Jiffy.setLocale(LocalizeAndTranslate.getLocale().languageCode);
    } else {
      await Jiffy.setLocale("en");
    }
  }

  //get country code
  static Future<String> getCurrentCountryCode() async {
    String countryCode = "US";
    try {
      //make request to get country code
      final response = await HttpService().dio.get(
            "http://ip-api.com/json/?fields=countryCode",
          );
      //get the country code
      countryCode = response.data["countryCode"];
    } catch (e) {
      try {
        countryCode = AppStrings.countryCode
            .toUpperCase()
            .replaceAll("AUTO", "")
            .replaceAll("INTERNATIONAL", "")
            .split(",")[0];
      } catch (e) {
        countryCode = "us";
      }
    }

    return countryCode.toUpperCase();
  }
}
