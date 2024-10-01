import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart'as slider;
import 'package:dartx/dartx.dart';
import 'package:firestore_chat/firestore_chat.dart';
//import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georange/georange.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_ui_settings.dart';
import '../../models/currency.dart';
import '../../models/earning.dart';
import '../../models/new_order.dart';
import '../../models/new_taxi_order.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../../models/vehicle.dart';
import '../../models/vendor.dart';
import '../../requests/auth.request.dart';
import '../../requests/earning.request.dart';
import '../../requests/order.request.dart';
import '../../requests/taxi.request.dart';
import '../../services/app.service.dart';
import '../../services/appbackground.service.dart';
import '../../services/auth.service.dart';
import '../../services/chat.service.dart';
import '../../services/local_storage.service.dart';
import '../../services/location.service.dart';
import '../../services/order_assignment.service.dart';
import '../../services/order_manager.service.dart';
import '../../services/taxi/new_taxi_booking.service.dart';
import '../../services/taxi/ongoing_taxi_booking.service.dart';
import '../../services/taxi/taxi_google_map_manager.service.dart';
import '../../services/taxi/taxi_location.service.dart';
import '../../services/update.service.dart';
import '../../utils/utils.dart';
import '../../view_models/base.view_model.dart';
import '../../widgets/bottomsheets/new_order_alert.bottomsheet.dart';
import '../../widgets/bottomsheets/user_rating.bottomsheet.dart';

class TaxiViewModel extends MyBaseViewModel with UpdateService {
  TaxiViewModel(BuildContext context) {
    viewContext = context;
  }
  Timer? pollingTimer;
  OrderRequest orderRequest = OrderRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  bool isInitialLoading = true;
  bool isButtonLoading = false;

  //services
  TaxiLocationService? taxiLocationService;
  NewTaxiBookingService? newTaxiBookingService;
  OnGoingTaxiBookingService? onGoingTaxiBookingService;
  TaxiGoogleMapManagerService? taxiGoogleMapManagerService;

  AnimationController? controllerDotCount;
  Animation<double>? animationDotCount;
  AppService appService = AppService();
  BehaviorSubject<Widget?> uiStream = BehaviorSubject<Widget?>();

  EarningRequest earningRequest = EarningRequest();
  Currency? currency;
  Earning? earning;
  double commission = 0.0;

  //
  Order? onGoingOrderTrip;
  Order? finishedOrderTrip;
  NewTaxiOrder? newOrder;
  List<Order> orderList = [];
  Order? acceptedOrder;
  bool isAccepted = false;
  bool isEnteredTheStore = false;
  bool isPickedUp = false;

  //
  // bool isOnline = true;
  int currentIndex = 0;
  User? currentUser;
  Vehicle? driverVehicle;
  PageController pageViewController = PageController(initialPage: 0);
  StreamSubscription? homePageChangeStream;
  StreamSubscription? locationReadyStream;
  GeoRange georange = GeoRange();
  StreamSubscription? newOrderStream;
  AuthRequest authRequest = AuthRequest();

  slider.CarouselController carouselSliderController = slider.CarouselController();

  void startPollingForOrders() {
    if (pollingTimer == null || !pollingTimer!.isActive) {
      pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        await getOrder(); // Replace with your API call to fetch orders
      });
    }
  }

  // Stop the polling
  void stopPollingForOrders() {
    pollingTimer?.cancel();
    pollingTimer = null;
  }

  @override
  void initialise() async {
    super.initialise();
    //
    commission = await AuthServices.getCommission();
    taxiGoogleMapManagerService = TaxiGoogleMapManagerService(this);
    await taxiGoogleMapManagerService?.setSourceAndDestinationIcons();
    newTaxiBookingService = NewTaxiBookingService(this);
    onGoingTaxiBookingService = OnGoingTaxiBookingService(this);
    taxiLocationService = TaxiLocationService(this);
    isInitialLoading = true; // Set initial loading to true
    await getOrder(); // Initial order fetch
    isInitialLoading = false;
    //get the driver online status from the server api
    await getOnlineDriverState();

    // Load the status of driver free/online from firebase
    await OrderManagerService().monitorOnlineStatusListener(
      appService: appService,
    );
    //update the new taxi booking service listener
    await newTaxiBookingService?.toggleVisibility(appService.driverIsOnline);

    //now check for any on going trip
    await checkForOnGoingTrip();

    //
    handleAppUpdate(viewContext);
    //
    currentUser = await AuthServices.getCurrentUser();
    driverVehicle = await AuthServices.getDriverVehicle();
    //

    AppService().driverIsOnline =
        LocalStorageService.prefs!.getBool(AppStrings.onlineOnApp) ?? false;
    notifyListeners();

    if (AppService().driverIsOnline) {
      startPollingForOrders();
    }
    //
    await OrderManagerService().monitorOnlineStatusListener();
    notifyListeners();

    //
    locationReadyStream = LocationService().locationDataAvailable.stream.listen(
          (event) {
        if (event) {
          print("abut call ==> listenToNewOrders");
          listenToNewOrders();
        }
      },
    );

    homePageChangeStream = AppService().homePageIndex.stream.listen(
          (index) {
        //
        onTabChange(index);
      },
    );

    //INCASE OF previous driver online state
    handleNewOrderServices();
    if (AppService().driverIsOnline) {
      startAnimation();
    }
  }

  fetchEarning() async {
    setBusy(true);
    try {
      final results = await earningRequest.getEarning(todayEarning: true);
      currency = results[0];
      earning = results[1];
      print("Earning amount is ${earning?.amount}");
      clearErrors();
    } catch (error) {
      print("Error getting earning amount $error");
      setError(error);
    }
    setBusy(false);
  }

  void startAnimation() {
    controllerDotCount?.forward(from: 0);
  }

  void stopAnimation() {
    controllerDotCount?.stop();
  }

  // Main function to fetch orders and handle polling
  getOrder() async {
    if (!isInitialLoading) {
      setBusy(false); // Avoid showing busy indicator during polling
    }
    //load today earning as well
    fetchEarning();

    List<Order> tempOrders = await orderRequest.lookingOrders(queryParameters: {
      'status[0]': 'preparing',
      'status[1]': 'pending',
      'status[2]': 'enter_store',
      'status[3]': 'ready',
      'status[4]': 'picked_up',
      'status[5]': 'failed',
    });
    print("Temp Orders $tempOrders");
    int userId = await AuthServices.getUserId();
    Order? existingOrder = tempOrders.firstOrNullWhere(
            (element) => (null != element.driverId && element.driverId == userId));
    if (null != existingOrder) {
      isAccepted = true;
      /// Available statuses
      /// -------------------
      /// pending
      /// preparing
      /// enter_store
      /// ready
      /// picked_up
      /// delivered
      /// failed
      /// cancelled
      if (existingOrder.status == "enter_store") {
        isEnteredTheStore = true;
      } else if (existingOrder.status == "picked_up") {
        isPickedUp = true;
      }
      orderList = [existingOrder];
    } else {
      orderList = tempOrders;
    }

    // Stop polling if orders are found
    if (orderList.isNotEmpty) {
      stopPollingForOrders(); // Stop polling when orders are available
      notifyListeners();
    } else {
      // If orderList is empty, restart polling
      if (pollingTimer == null || !pollingTimer!.isActive) {
        startPollingForOrders();
      }
    }

    try {
      taxiGoogleMapManagerService?.getCurrentLocation();
      taxiGoogleMapManagerService?.currentIndex = 0;
      taxiGoogleMapManagerService?.drawRoute(0);
      notifyListeners();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng source = LatLng(position.latitude, position.longitude);

      for (Order order in orderList) {
        Vendor? vendor = order.vendor;
        if (null != vendor) {
          double latitude = (vendor.latitude).toDouble();
          double longitude = (vendor.longitude).toDouble();
          LatLng destination = LatLng(latitude, longitude);

          Utils.vendorDistanceFromDefaultAddress(source, destination)
              .then((value) {
            if (value.length > 1) {
              order.pickupDistance.value = value[0];
              order.pickupTravelTime.value = value[1].toInt();
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    setBusy(false);

    //Move the slider to delivery address if the order is picked up
    if (isPickedUp) {
      Future.delayed(const Duration(seconds: 1), () {
        carouselSliderController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.linear);
      });
    }
  }

  checkForOnGoingTrip() async {
    onGoingOrderTrip = await onGoingTaxiBookingService?.getOnGoingTrip();
    onGoingTaxiBookingService?.loadTripUIByOrderStatus();
  }

  /// pending
  /// preparing
  /// driver_entered
  /// ready
  /// enroute
  /// delivered
  /// failed
  /// cancelled
  void setButtonLoading(bool loading) {
    isButtonLoading = loading;
    notifyListeners();
  }
  // Accept Order Logic
  acceptOrder(int index) async {
    setButtonLoading(true); // Start button-specific loading
    try {
      setBusy(true); // General busy state
      acceptedOrder = await orderRequest
          .acceptNewOrder(orderList[index].orderProducts?.first.orderId ?? 0);
      isAccepted = true;
      getOrder();
    } finally {
      setBusy(false);
      setButtonLoading(false); // Stop button-specific loading
    }
  }

  // Enter the Store Logic
  enteredTheStoreForOrder(int index) async {
    setButtonLoading(true); // Start button-specific loading
    try {
      setBusy(true); // General busy state
      acceptedOrder = await orderRequest.updateOrderStatus(
          orderList[index].orderProducts?.first.orderId ?? 0,
          status: "enter_store");
      isEnteredTheStore = true;
      getOrder();
    } finally {
      setBusy(false);
      setButtonLoading(false); // Stop button-specific loading
    }
  }

  // Order Pickup Done Logic
  orderPickupDone(int index) async {
    setButtonLoading(true); // Start button-specific loading
    try {
      setBusy(true); // General busy state
      acceptedOrder = await orderRequest.updateOrderStatus(
          orderList[index].orderProducts?.first.orderId ?? 0,
          status: "picked_up");
      isPickedUp = true;
      getOrder();
    } finally {
      setBusy(false);
      setButtonLoading(false); // Stop button-specific loading
    }
  }

  // Successful Order Delivery Logic
  successfulOrderDelivery(int index) async {
    setButtonLoading(true); // Start button-specific loading
    try {
      setBusy(true); // General busy state
      acceptedOrder = await orderRequest.updateOrderStatus(
          orderList[index].orderProducts?.first.orderId ?? 0,
          status: "delivered");
      isAccepted = false;
      isEnteredTheStore = false;
      isPickedUp = false;
      getOrder();
    } finally {
      setBusy(false);
      setButtonLoading(false); // Stop button-specific loading
    }
  }

  // Cancel Trip Logic
  cancelTrip(int index) async {
    setButtonLoading(true); // Start button-specific loading
    try {
      setBusy(true); // General busy state

      int orderId = orderList[index].orderProducts?.first.orderId ?? 0;
      final apiResult = await taxiRequest.cancelTrip(orderId);

      if (apiResult.code == 200) {
        isAccepted = false;
        isEnteredTheStore = false;
        isPickedUp = false;
        getOrder(); // Refresh the order list after canceling
      } else {
        print("Failed to cancel the order: ${apiResult.message}");
      }
    } finally {
      setBusy(false);
      setButtonLoading(false); // Stop button-specific loading
    }
  }


  cancelOrderDelivery(int index) async {
    setBusy(true);
    acceptedOrder = await orderRequest.updateOrderStatus(
        orderList[index].orderProducts?.first.orderId ?? 0,
        status: "cancelled");
    isAccepted = false;
    isEnteredTheStore = false;
    isPickedUp = false;
    getOrder();
  }


//fetch driver online offline
  getOnlineDriverState() async {
    setBusyForObject(appService.driverIsOnline, true);
    try {
      User driverData = await AuthRequest().getMyDetails();
      appService.driverIsOnline = driverData.isOnline;
      //if is online start listening to new trip
      if (appService.driverIsOnline) {
        newTaxiBookingService?.startNewOrderListener();
      }
    } catch (error) {
      print("error getting driver data ==> $error");
    }
    setBusyForObject(appService.driverIsOnline, false);
  }

  //update driver state
  Future<bool> syncDriverNewState() async {
    bool updated = false;
    setBusyForObject(appService.driverIsOnline, true);
    try {
      await AuthRequest().updateProfile(
        isOnline: appService.driverIsOnline,
      );
      updated = true;
    } catch (error) {
      print("error getting driver data ==> $error");
      appService.driverIsOnline = !appService.driverIsOnline;
    }
    setBusyForObject(appService.driverIsOnline, false);
    return updated;
  }

  //
  chatCustomer() {
    //
    Map<String, PeerUser> peers = {
      '${onGoingOrderTrip!.driver!.id}': PeerUser(
        id: '${onGoingOrderTrip!.driver!.id}',
        name: onGoingOrderTrip!.driver!.name,
        image: onGoingOrderTrip!.driver!.photo,
      ),
      '${onGoingOrderTrip!.user.id}': PeerUser(
          id: "${onGoingOrderTrip!.user.id}",
          name: onGoingOrderTrip!.user.name,
          image: onGoingOrderTrip!.user.photo),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${onGoingOrderTrip?.driver?.id}']!,
      peers: peers,
      //don't translate this
      path: "orders/${onGoingOrderTrip?.code}/customerDriver/chats",
      title: "Chat with customer".tr(),
      supportMedia: AppUISettings.canDriverChatSupportMedia,
    );
    //
    Navigator.of(viewContext).pushNamed(
      AppRoutes.chatRoute,
      arguments: chatEntity,
    );
  }

  //rate trip
  void showUserRating(Order finishedTrip) async {
    //
    finishedTrip =
        finishedOrderTrip != null ? finishedOrderTrip! : finishedTrip;
    //
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => UserRatingBottomSheet(
          order: finishedTrip,
          onSubmitted: () {
            Navigator.pop(viewContext);
            resetOrderListener();
          },
        ),
      ),
    );

    //
    resetOrderListener();
  }

  resetOrderListener() {
    //
    onGoingOrderTrip = null;
    notifyListeners();
    newTaxiBookingService?.startNewOrderListener();
    taxiLocationService?.zoomToLocation();
    taxiGoogleMapManagerService?.updateGoogleMapPadding(20);
  }

  cancelAllListeners() async {
    homePageChangeStream?.cancel();
    newOrderStream?.cancel();
  }

  //
  onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  //
  onTabChange(int index) {
    currentIndex = index;
    pageViewController.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 5),
      curve: Curves.bounceInOut,
    );
    notifyListeners();
  }

  void toggleOnlineStatus() async {
    setBusy(true);
    try {
      //
      final apiResponse = await authRequest.updateProfile(
        isOnline: !AppService().driverIsOnline,
      );
      if (apiResponse.allGood) {
        //
        AppService().driverIsOnline = !AppService().driverIsOnline;
        await LocalStorageService.prefs!.setBool(
          AppStrings.onlineOnApp,
          AppService().driverIsOnline,
        );

        //
        // viewContext.showToast(
        //   msg: "Updated Successfully".tr(),
        //   bgColor: Colors.green,
        //   textColor: Colors.white,
        // );

        //
        handleNewOrderServices();

        if (AppService().driverIsOnline) {
          startAnimation();
        }
      } else {
        viewContext.showToast(
          msg: "${apiResponse.message}",
          bgColor: Colors.red,
        );
      }
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    setBusy(false);
  }

  handleNewOrderServices() {
    if (AppService().driverIsOnline) {
      listenToNewOrders();
      AppbackgroundService().startBg();
    } else {
      //
      // LocationService().clearLocationFromFirebase();
      cancelAllListeners();
      AppbackgroundService().stopBg();
    }
  }

  //NEW ORDER STREAM
  listenToNewOrders() async {
    //close any previous listener
    newOrderStream?.cancel();
    //start the background service
    startNewOrderBackgroundService();
  }

  NewOrder? showingNewOrder;

  void showNewOrderAlert(NewOrder newOrder) async {
    //

    if (showingNewOrder == null || showingNewOrder!.docRef != newOrder.docRef) {
      showingNewOrder = newOrder;
      print("called showNewOrderAlert");
      final result = await showModalBottomSheet(
        context: AppService().navigatorKey.currentContext!,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return NewOrderAlertBottomSheet(newOrder);
        },
      );

      //
      if (result is bool && result) {
        AppService().refreshAssignedOrders.add(true);
      } else {
        await OrderAssignmentService.releaseOrderForotherDrivers(
          newOrder.toJson(),
          newOrder.docRef!,
        );
      }
    }
  }

  dispose() {
    super.dispose();
    cancelAllListeners();
  }

  // Reject Assignment Logic
  void rejectAssignment(int index) async {
    setButtonLoading(true); // Start button-specific loading
    try {
      await taxiRequest.rejectAssignment(orderList[index].id, 0);
      getOrder(); // Refresh orders
    } finally {
      setButtonLoading(false); // Stop button-specific loading
    }
  }}

class DotAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.primaryColor,
      ),
    );
  }
}
