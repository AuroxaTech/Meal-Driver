import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  //
  static targetBounds(LatLng locNE, LatLng locSW) {
    var nLat, nLon, sLat, sLon;

    if (locSW.latitude <= locNE.latitude) {
      sLat = locSW.latitude;
      nLat = locNE.latitude;
    } else {
      sLat = locNE.latitude;
      nLat = locSW.latitude;
    }
    if (locSW.longitude <= locNE.longitude) {
      sLon = locSW.longitude;
      nLon = locNE.longitude;
    } else {
      sLon = locNE.longitude;
      nLon = locSW.longitude;
    }

    return LatLngBounds(
      northeast: LatLng(nLat, nLon),
      southwest: LatLng(sLat, sLon),
    );
  }

  static launchDirections({String? address, double? latitude, double? longitude}) {
    String locationEncoded = "";
    if (null != address) {
      locationEncoded = Uri.encodeFull(address);
    } else if (null != latitude && null != longitude) {
      locationEncoded = "$latitude,$longitude";
    }
    if (locationEncoded.isNotEmpty) {
      String url =  'https://www.google.com/maps/place/$locationEncoded';
      print(url);
      launchUrl(
          Uri.parse(
             url),
          mode: LaunchMode.externalApplication);
    }
  }
}
