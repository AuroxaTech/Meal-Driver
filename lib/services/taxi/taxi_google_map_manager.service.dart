import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/view_models/taxi/taxi.vm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../view_models/base.view_model.dart';

class TaxiGoogleMapManagerService extends MyBaseViewModel {
  TaxiGoogleMapManagerService(this.taxiViewModel) {
    setSourceAndDestinationIcons();
  }

  TaxiViewModel? taxiViewModel;
  GoogleMapController? googleMapController;
  EdgeInsets googleMapPadding = const EdgeInsets.only(top: kToolbarHeight);
  Set<Polyline> gMapPolylines = {};

  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  Set<Marker> gMapMarkers = {};
  MarkerId driverMarkerId = const MarkerId("driverIcon");
  PolylinePoints polylinePoints = PolylinePoints();

// for my custom icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;
  bool canShowMap = true;

  ///
  int currentIndex = 0;
  Completer<GoogleMapController> mapController = Completer();
  LatLng? currentLocation, destinationLocation;
  bool _isMapReady = false;

  //List<LatLng> polylineCoordinates = [];
  // List<LatLng> ahmedabadLocations = [
  //   const LatLng(23.0331, 72.5633), // Sabarmati Ashram
  //   const LatLng(23.0079, 72.6027), // Kankaria Lake
  //   const LatLng(23.0778, 72.6347), // Sardar Vallabhbhai Patel International Airport
  //   const LatLng(23.1655, 72.6003), // Adalaj Stepwell
  //   const LatLng(23.0405, 72.5293), // Vastrapur Lake
  // ];

  onMapReady(GoogleMapController controller) {
    googleMapController = controller;
    setGoogleMapStyle();
    getCurrentLocation();
  }

  onMapCameraIdle() {
    taxiViewModel?.taxiLocationService?.handleAutoZoomToLocation();
  }

  void setGoogleMapStyle() async {
    if (taxiViewModel == null) {
      return;
    }
    String value =
        await DefaultAssetBundle.of(taxiViewModel!.viewContext).loadString(
      'assets/json/google_map_style.json',
    );
    //
    googleMapController?.setMapStyle(value);
  }

  setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.pickupLocation,
    );
    //
    destinationIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      AppImages.dropoffLocation,
    );
    //
    final Uint8List markerIcond = await Utils().getBytesFromCanvas(
      ((taxiViewModel?.viewContext.percentWidth ?? 1) * 13).ceil(),
      ((taxiViewModel?.viewContext.percentWidth ?? 1) * 25).ceil(),
      AppImages.driverCar,
    );
    driverIcon = BitmapDescriptor.fromBytes(markerIcond);
  }

  //
  //
  zoomToCurrentLocation1() async {
    // myLocationListener?.cancel();
    // if (await AppPermissionHandlerService().isLocationGranted()) {
    //   final currentPosition = await Geolocator.getCurrentPosition();
    //   if (currentPosition != null) {
    //     zoomToLocation(currentPosition.latitude, currentPosition.longitude);
    //   }
    // }
    // //
    // myLocationListener =
    //     LocationService().location.onLocationChanged.listen((locationData) {
    //   //actually zoom now
    //   zoomToLocation(locationData.latitude, locationData.longitude);
    // });
  }

  //
  // zoomToLocation1(double lat, double lng) {
  //   googleMapController?.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //         target: LatLng(lat, lng),
  //         zoom: 16,
  //       ),
  //     ),
  //   );
  // }

  void updateGoogleMapPadding([double? height]) {
    googleMapPadding = EdgeInsets.only(
      top: googleMapPadding.top,
      bottom: height ?? googleMapPadding.bottom,
    );
    taxiViewModel?.notifyListeners();
  }

  clearMapData() {
    clearMapMarkers();
    polylineCoordinates.clear();
    gMapPolylines.clear();
    taxiViewModel?.uiStream.add(null);
    taxiViewModel?.notifyListeners();
  }

  //
  clearMapMarkers({bool clearDriver = false}) {
    if (clearDriver) {
      gMapMarkers = {};
    } else {
      gMapMarkers.removeWhere((e) => e.markerId != driverMarkerId);
    }
    taxiViewModel?.notifyListeners();
  }

  removeMapMarker(MarkerId markerId) {
    gMapMarkers.removeWhere((e) => e.markerId == markerId);
    taxiViewModel?.notifyListeners();
  }

  ///

  void drawRoute(int index) async {
    if (currentLocation == null) {
      await getCurrentLocation();
    }
    double latitude =
        taxiViewModel!.orderList[index].deliveryLatLong!.latitude!;
    double longitude =
        taxiViewModel!.orderList[index].deliveryLatLong!.longitude!;
    destinationLocation = LatLng(latitude, longitude);
    _zoomToFit(currentLocation!, destinationLocation!);
    gMapPolylines.clear();
    final Uint8List markerIconDestination =
        await _getMarkerIcon(Icons.pin_drop, Colors.green.shade900);
    final Uint8List markerIconCurrent =
        await _getMarkerIcon(Icons.gps_fixed_rounded, Colors.red.shade900);

    // Initialize the polyline points
    Marker originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: currentLocation!,
      icon: BitmapDescriptor.fromBytes(markerIconCurrent), // Blue marker
      infoWindow: const InfoWindow(title: 'Origin'),
    );

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation!.latitude},${currentLocation!.longitude}'
        '&destination=${destinationLocation!.latitude},${destinationLocation!.longitude}'
        '&key=AIzaSyBDc75DLs1UQ25VQfWAQhl4cthGEjaaV9Q&alternatives=true';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] != "ZERO_RESULTS") {
        Marker destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: destinationLocation!,
          icon: BitmapDescriptor.fromBytes(markerIconDestination),
          // Use custom marker icon for destination
          infoWindow: const InfoWindow(title: 'Destination'),
        );

        Set<Marker> markers = {originMarker, destinationMarker};
        gMapMarkers = markers;
        List<LatLng> points =
            _decodePoly(data['routes'][0]['overview_polyline']['points']);

        Set<Polyline> polylines = {};
        polylines.add(Polyline(
          polylineId: const PolylineId('route1'),
          visible: true,
          points: points,
          color: Colors.blue,
          width: 5,
        ));

        gMapPolylines = polylines;
        notifyListeners();
      } else {
        Set<Marker> markers = {originMarker};
        gMapMarkers = markers;
        googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(currentLocation!.latitude, currentLocation!.longitude),
              zoom: 20,
            ),
          ),
        );
        notifyListeners();
      }
      notifyListeners();
    } else {
      Set<Marker> markers = {originMarker};
      gMapMarkers = markers;
      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation!.latitude, currentLocation!.longitude),
            zoom: 20,
          ),
        ),
      );
      notifyListeners();
      throw Exception('Failed to load route');
    }
  }

  Future<Uint8List> _getMarkerIcon(IconData icon, Color color) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    final double radius = 22.0;

    canvas.drawCircle(Offset(radius, radius), radius, paint);

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: radius * 1.5,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );

    painter.layout();
    painter.paint(
      canvas,
      Offset(radius - painter.width / 2, radius - painter.height / 2),
    );

    final img = await pictureRecorder.endRecording().toImage(
          (radius * 2).toInt(),
          (radius * 2).toInt(),
        );
    final data = await img.toByteData(format: ImageByteFormat.png);

    return data!.buffer.asUint8List();
  }

  List<LatLng> _decodePoly(String encoded) {
    var list = encoded.codeUnits;
    var index = 0;
    var len = encoded.length;
    int lat = 0, lng = 0;
    List<LatLng> poly = [];
    int shift, result, byte;
    while (index < len) {
      byte = 0;
      shift = 0;
      result = 0;
      do {
        byte = list[index] - 63;
        result |= (byte & 0x1F) << (shift * 5);
        shift++;
        index++;
      } while (byte >= 0x20);
      if ((result & 1) != 0) {
        lat += ~(result >> 1);
      } else {
        lat += (result >> 1);
      }
      shift = 0;
      result = 0;
      do {
        byte = list[index] - 63;
        result |= (byte & 0x1F) << (shift * 5);
        shift++;
        index++;
      } while (byte >= 0x20);
      if ((result & 1) != 0) {
        lng += ~(result >> 1);
      } else {
        lng += (result >> 1);
      }
      var latlng = LatLng(lat / 1E5, lng / 1E5);
      poly.add(latlng);
    }
    return poly;
  }

  void _zoomToFit(LatLng origin, LatLng destination) {
    // Calculate the center point between origin and destination
    double minLat = min(origin.latitude, destination.latitude);
    double maxLat = max(origin.latitude, destination.latitude);
    double minLng = min(origin.longitude, destination.longitude);
    double maxLng = max(origin.longitude, destination.longitude);

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    // Calculate the new camera position with padding
    mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 90), // 100 is padding
      );
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permission denied, handle accordingly (e.g., show a message)
      print('Location permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied, handle accordingly (e.g., show a message)
      print('Location permission permanently denied');
    } else {
      // Permission granted, initialize the map

      _isMapReady = true;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final Uint8List markerIconCurrent =
          await _getMarkerIcon(Icons.gps_fixed_rounded, Colors.red.shade900);
      currentLocation = LatLng(position.latitude, position.longitude);
      print('latitude::${position.latitude}==longitude::${position.longitude}');
      notifyListeners();

      notifyListeners();
      Marker originMarker = Marker(
        markerId: const MarkerId('origin'),
        position: currentLocation!,
        icon: BitmapDescriptor.fromBytes(markerIconCurrent), // Blue marker
        infoWindow: const InfoWindow(title: 'Origin'),
      );
      gMapMarkers = {originMarker};
      taxiViewModel?.notifyListeners();

      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation!.latitude, currentLocation!.longitude),
            zoom: 50,
          ),
        ),
      );
      notifyListeners();
      //_drawRoute(currentIndex);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }
}
