import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:driver/utils/map.utils.dart';
import 'package:driver/views/pages/order/completed_orders.page.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/services/location.service.dart';
import 'package:driver/view_models/taxi/taxi.vm.dart';
import 'package:driver/views/pages/taxi/widgets/location_permission.view.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:driver/widgets/cards/custom.visibility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_images.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_text_styles.dart';
import '../../../services/app.service.dart';
import '../../../utils/size_utils.dart';

class TaxiOrderPage extends StatefulWidget {
  const TaxiOrderPage({super.key});

  @override
  State<TaxiOrderPage> createState() => _TaxiOrderPageState();
}

class _TaxiOrderPageState extends State<TaxiOrderPage>
    with
        SingleTickerProviderStateMixin,
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  TaxiViewModel? taxiViewModel;

  @override
  void initState() {
    super.initState();
    taxiViewModel ??= TaxiViewModel(context);

    ///
    taxiViewModel!.controllerDotCount = AnimationController(
      //vsync: ,
      duration: const Duration(seconds: 2), vsync: this,
    );

    if (null != taxiViewModel?.controllerDotCount) {
      taxiViewModel!.animationDotCount = Tween<double>(
        begin: 0,
        end: 3,
      ).animate(taxiViewModel!.controllerDotCount!)
        ..addListener(() {
          if (mounted &&
              AppStrings.selectedIndex == 0 &&
              taxiViewModel!.orderList.isEmpty) setState(() {});
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            taxiViewModel!.controllerDotCount?.repeat();
          } else if (status == AnimationStatus.dismissed) {
            taxiViewModel!.controllerDotCount?.forward();
          }
        });
    }

    if (AppService().driverIsOnline) {
      taxiViewModel!.startAnimation();
    }
  }

  @override
  void dispose() {
    taxiViewModel?.controllerDotCount?.dispose();
    taxiViewModel?.taxiGoogleMapManagerService?.googleMapController!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    taxiViewModel?.taxiGoogleMapManagerService?.setGoogleMapStyle();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfigs().init(context);
    super.build(context);
    return BasePage(
      body: ViewModelBuilder<TaxiViewModel>.reactive(
        viewModelBuilder: () => taxiViewModel!,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return Stack(
            children: [
              //google map 49.2383° N, 123.1283° W.
              CustomVisibility(
                visible: vm.taxiGoogleMapManagerService?.canShowMap ?? false,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        LocationService().currentLocation?.latitude ?? 49.23,
                        LocationService().currentLocation?.longitude ?? 123.12),
                    zoom: 2.5,
                  ),
                  myLocationButtonEnabled: true,
                  trafficEnabled: true,
                  onMapCreated: vm.taxiGoogleMapManagerService?.onMapReady,
                  // onCameraIdle: vm.taxiGoogleMapManagerService.onMapCameraIdle,
                  padding: vm.taxiGoogleMapManagerService?.googleMapPadding ??
                      EdgeInsets.zero,
                  markers: vm.taxiGoogleMapManagerService?.gMapMarkers ??
                      const <Marker>{},
                  polylines: vm.taxiGoogleMapManagerService?.gMapPolylines ??
                      const <Polyline>{},
                  zoomControlsEnabled: false,
                ),
              ),

              //sos button
              //SOSButton(),
              //
              // StreamBuilder<Widget?>(
              //   stream: vm.uiStream,
              //   builder: (ctx, snapshot) {
              //     if (!snapshot.hasData || snapshot.data == null) {
              //       return IdleTaxiView(vm);
              //     }
              //     return snapshot.data!;
              //   },
              // ),
              //permission request
              CustomVisibility(
                visible: !(vm.taxiGoogleMapManagerService?.canShowMap ?? false),
                child: LocationPermissionView(
                  onResult: (request) {
                    if (request) {
                      vm.taxiLocationService
                          ?.requestLocationPermissionForGoogleMap();
                    }
                  },
                ).centered(),
              ),

              //loading
              Visibility(
                visible: vm.isBusy,
                child: BusyIndicator(
                  color: AppColor.primaryColor,
                )
                    .wh(60, 60)
                    .box
                    .white
                    .rounded
                    .p32
                    .makeCentered()
                    .box
                    .color(Colors.black.withOpacity(0.3))
                    .make()
                    .wFull(context)
                    .hFull(context),
              ),

              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: !AppService().driverIsOnline
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: AppColor.primaryColor, width: 2)),
                          child: 'Start earning now!'
                              .text
                              .bold
                              .color(AppColor.primaryColor)
                              .size(36)
                              .makeCentered(),
                        ).onInkTap(() {
                          taxiViewModel!.toggleOnlineStatus();
                          // openStartEarningDialog(context);
                        })
                      : vm.orderList.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: AppColor.primaryColor, width: 2)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: 'Looking for orders'
                                          .text
                                          .bold
                                          .color(AppColor.primaryColor)
                                          .size(32)
                                          .make(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 46.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: List.generate(
                                        (taxiViewModel?.animationDotCount
                                                            ?.value ??
                                                        0)
                                                    .floor() %
                                                3 +
                                            1,
                                        (index) => Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: DotAnimation(),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(
                              child: CarouselSlider.builder(
                              carouselController: vm.carouselSliderController,
                              itemCount: min(1, vm.orderList.length) +
                                  ((vm.isAccepted) ? 1 : 0),
                              options: CarouselOptions(
                                viewportFraction: 1.0,
                                initialPage: 0,
                                enableInfiniteScroll: false,
                                reverse: false,
                                autoPlay: false,
                                height: 450,
                                autoPlayInterval: const Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {
                                  if (vm.isAccepted && index > 0) {
                                    index = index - 1;
                                  }
                                  /*vm.priceTag = 0.0;
                                  if (vm.orderList[index].orderProducts !=
                                          null &&
                                      vm.orderList[index].orderProducts!
                                          .isNotEmpty) {
                                    for (var element
                                        in vm.orderList[index].orderProducts!) {
                                      vm.priceTag = vm.priceTag + element.price;
                                    }
                                  }*/

                                  print("onPageChanged $index");
                                  vm.taxiGoogleMapManagerService?.currentIndex =
                                      index;
                                  vm.taxiGoogleMapManagerService
                                      ?.drawRoute(index);
                                  if (mounted) setState(() {});
                                },
                                scrollDirection: Axis.horizontal,
                              ),
                              itemBuilder: (BuildContext context, int index,
                                  int realIndex) {
                                if (vm.isAccepted && index > 0) {
                                  //Additional delivery destination info
                                  index = index - 1;
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!vm.isPickedUp)
                                            Container(
                                              width: 100,
                                              height: 38,
                                              margin: const EdgeInsets.only(
                                                  right: 20),
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: (vm.isAccepted
                                                      ? 'Cancel'
                                                      : 'Reject')
                                                  .text
                                                  .color(Colors.white)
                                                  .size(20)
                                                  .fontWeight(FontWeight.w600)
                                                  .align(TextAlign.center)
                                                  .make(),
                                            ).onTap(() {
                                              if (vm.isAccepted) {
                                                vm.cancelOrderDelivery(index);
                                              } else {
                                                vm.rejectAssignment(index);
                                              }
                                            }),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            margin: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10,
                                                top: 3),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        AppColor.primaryColor,
                                                    width: 2)),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                'Next Stop'
                                                    .text
                                                    .size(20)
                                                    .fontWeight(FontWeight.w600)
                                                    .color(
                                                        AppColor.primaryColor)
                                                    .make()
                                                    .h(25),
                                                "Dropoff at ${vm.orderList[index].user.name}"
                                                    .text
                                                    .size(30)
                                                    .bold
                                                    .color(
                                                        AppColor.primaryColor)
                                                    .make()
                                                    .h(35),
                                                Container(
                                                  // Adjust the height as needed
                                                  child: Text(
                                                    vm
                                                            .orderList[index]
                                                            .deliveryAddress
                                                            ?.address ??
                                                        "",
                                                    maxLines: 3,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColor
                                                            .primaryColor), // Adjust the font size as needed
                                                  ),
                                                ),
                                                if ((vm
                                                            .orderList[index]
                                                            .deliveryAddress
                                                            ?.description ??
                                                        "")
                                                    .isNotEmpty) ...[
                                                  8.heightBox,
                                                  "Notes: ${vm.orderList[index].deliveryAddress?.description}"
                                                      .text
                                                      .size(16)
                                                      .fontWeight(
                                                          FontWeight.w600)
                                                      .color(
                                                          AppColor.primaryColor)
                                                      .make(),
                                                ],
                                                32.heightBox,
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: AppColor
                                                                  .primaryColor,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/telephone.png',
                                                            height: 20,
                                                            width: 20,
                                                          ),
                                                          5.widthBox,
                                                          'Call'
                                                              .text
                                                              .fontWeight(
                                                                  FontWeight
                                                                      .w600)
                                                              .size(16)
                                                              .color(AppColor
                                                                  .primaryColor)
                                                              .make(),
                                                        ],
                                                      ),
                                                    ).onTap(() async {
                                                      final Uri launchUri = Uri(
                                                        scheme: 'tel',
                                                        path: vm.acceptedOrder
                                                            ?.vendor?.phone,
                                                      );
                                                      await launchUrl(
                                                          launchUri);
                                                    }),
                                                    const SizedBox(width: 8.0),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: AppColor
                                                                  .primaryColor,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/location.png',
                                                            height: 20,
                                                            width: 20,
                                                          ),
                                                          5.widthBox,
                                                          'Direction'
                                                              .text
                                                              .fontWeight(
                                                                  FontWeight
                                                                      .w600)
                                                              .size(16)
                                                              .color(AppColor
                                                                  .primaryColor)
                                                              .make(),
                                                        ],
                                                      ).onTap(() async {
                                                        //String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=${vm.acceptedOrder.deliveryLatLong.latitude}";
                                                        if (vm.isAccepted) {
                                                          MapUtils.launchDirections(
                                                              address: vm
                                                                  .acceptedOrder
                                                                  ?.deliveryAddress
                                                                  ?.address);
                                                        } else {
                                                          MapUtils.launchDirections(
                                                              address: vm
                                                                  .acceptedOrder
                                                                  ?.vendor
                                                                  ?.address);
                                                        }
                                                        /*double lat = vm
                                                                .acceptedOrder
                                                                ?.deliveryLatLong
                                                                ?.latitude ??
                                                            0.0;
                                                        double lng = vm
                                                                .acceptedOrder
                                                                ?.deliveryLatLong
                                                                ?.longitude ??
                                                            0.0;

                                                        String url =
                                                            'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

                                                        await launchUrl(
                                                            Uri.parse(url));*/
                                                      }),
                                                    ),
                                                  ],
                                                ),
                                                if (vm.isPickedUp) ...[
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            color: AppColor
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: 'Order Delivered'
                                                            .text
                                                            .color(Colors.white)
                                                            .size(18)
                                                            .fontWeight(
                                                                FontWeight.w600)
                                                            .align(TextAlign
                                                                .center)
                                                            .make(),
                                                      ).onTap(() async {
                                                        await vm
                                                            .successfulOrderDelivery(
                                                                index);
                                                      }),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!vm.isPickedUp)
                                          Container(
                                            width: 100,
                                            height: 38,
                                            margin: const EdgeInsets.only(
                                                right: 20),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: (vm.isAccepted
                                                    ? 'Cancel'
                                                    : 'Reject')
                                                .text
                                                .color(Colors.white)
                                                .size(20)
                                                .fontWeight(FontWeight.w600)
                                                .align(TextAlign.center)
                                                .make(),
                                          ).onTap(() {
                                            if (vm.isAccepted) {
                                              vm.cancelOrderDelivery(index);
                                            } else {
                                              vm.rejectAssignment(index);
                                            }
                                          }),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              bottom: 10,
                                              top: 3),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: AppColor.primaryColor,
                                                  width: 2)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (vm.isAccepted)
                                                (vm.isEnteredTheStore
                                                        ? 'Picking up from'
                                                        : 'Heading to')
                                                    .text
                                                    .size(20)
                                                    .fontWeight(FontWeight.w600)
                                                    .color(
                                                        AppColor.primaryColor)
                                                    .make()
                                                    .h(25),
                                              vm.orderList[index].vendor!.name
                                                  .text
                                                  .size(34)
                                                  .bold
                                                  .color(AppColor.primaryColor)
                                                  .make()
                                                  .h(35),
                                              Container(
                                                // Adjust the height as needed
                                                child: Text(
                                                  vm.orderList[index].vendor!
                                                      .address,
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .primaryColor), // Adjust the font size as needed
                                                ),
                                              ),
                                              8.heightBox,
                                              if (vm.isAccepted &&
                                                  (vm
                                                              .orderList[index]
                                                              .deliveryAddress
                                                              ?.description ??
                                                          "")
                                                      .isNotEmpty)
                                                "Notes: ${vm.orderList[index].deliveryAddress?.description}"
                                                    .text
                                                    .size(16)
                                                    .fontWeight(FontWeight.w600)
                                                    .color(
                                                        AppColor.primaryColor)
                                                    .make()
                                              else if (!vm.isAccepted)
                                                Image.asset(
                                                  'assets/images/down_arrow.png',
                                                  height: 45,
                                                  width: 45,
                                                ),
                                              3.heightBox,
                                              if (!vm.isAccepted)
                                                (vm
                                                            .orderList[index]
                                                            .deliveryAddress
                                                            ?.address ??
                                                        "")
                                                    .text
                                                    .size(16)
                                                    .fontWeight(FontWeight.w600)
                                                    .color(
                                                        AppColor.primaryColor)
                                                    .make()
                                                    .h(35),
                                              5.heightBox,
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  vm.isPickedUp
                                                      ? "${vm.orderList[index].distance?.toInt()} km"
                                                          .text
                                                          .size(24)
                                                          .bold
                                                          .fontWeight(
                                                              FontWeight.w600)
                                                          .color(AppColor
                                                              .primaryColor)
                                                          .make()
                                                      : vm.isAccepted
                                                          ? Container(
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: AppColor
                                                                          .primaryColor,
                                                                      width: 2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15)),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          5),
                                                              child: Row(
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/telephone.png',
                                                                    height: 20,
                                                                    width: 20,
                                                                  ),
                                                                  5.widthBox,
                                                                  'Call'
                                                                      .text
                                                                      .fontWeight(
                                                                          FontWeight
                                                                              .w600)
                                                                      .size(16)
                                                                      .color(AppColor
                                                                          .primaryColor)
                                                                      .make(),
                                                                ],
                                                              ),
                                                            ).onTap(() async {
                                                              final Uri
                                                                  launchUri =
                                                                  Uri(
                                                                scheme: 'tel',
                                                                path: vm
                                                                    .orderList[
                                                                        index]
                                                                    .vendor
                                                                    ?.phone,
                                                              );
                                                              await launchUrl(
                                                                  launchUri);
                                                            })
                                                          : //"${vm.orderList[index].distance ?? 0 + vm.orderList[index].pickupDistance} km"

                                                          ValueListenableBuilder(
                                                              builder: (BuildContext
                                                                      context,
                                                                  double value,
                                                                  Widget?
                                                                      child) {
                                                                return "${((vm.orderList[index].distance ?? 0) + value).toInt()} km"
                                                                    .text
                                                                    .size(24)
                                                                    .bold
                                                                    .fontWeight(
                                                                        FontWeight
                                                                            .w600)
                                                                    .color(AppColor
                                                                        .primaryColor)
                                                                    .make();
                                                              },
                                                              valueListenable: vm
                                                                  .orderList[
                                                                      index]
                                                                  .pickupDistance,
                                                            ),
                                                  const SizedBox(width: 8.0),
                                                  vm.isAccepted
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: AppColor
                                                                      .primaryColor,
                                                                  width: 2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                'assets/images/location.png',
                                                                height: 20,
                                                                width: 20,
                                                              ),
                                                              5.widthBox,
                                                              'Direction'
                                                                  .text
                                                                  .fontWeight(
                                                                      FontWeight
                                                                          .w600)
                                                                  .size(16)
                                                                  .color(AppColor
                                                                      .primaryColor)
                                                                  .make(),
                                                            ],
                                                          ).onTap(() async {
                                                            //String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=${vm.acceptedOrder.deliveryLatLong.latitude}";
                                                            MapUtils.launchDirections(
                                                                address: vm
                                                                    .orderList[
                                                                        index]
                                                                    .deliveryAddress
                                                                    ?.address);

                                                            /*double lat = vm
                                                                    .acceptedOrder
                                                                    ?.deliveryLatLong
                                                                    ?.latitude ??
                                                                0.0;
                                                            double lng = vm
                                                                    .acceptedOrder
                                                                    ?.deliveryLatLong
                                                                    ?.longitude ??
                                                                0.0;

                                                            String url =
                                                                'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

                                                            await launchUrl(
                                                                Uri.parse(url));*/
                                                          }),
                                                        )
                                                      : "\$${((vm.orderList[index].vendor?.deliveryFee ?? 0) * (vm.commission / 100.0)).toStringAsFixed(2)}"
                                                          .text
                                                          .size(24)
                                                          .bold
                                                          .fontWeight(
                                                              FontWeight.w600)
                                                          .color(AppColor
                                                              .primaryColor)
                                                          .make(),
                                                  const SizedBox(width: 8.0),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        color: AppColor
                                                            .primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: (vm.isPickedUp
                                                            ? 'Picked Up'
                                                            : vm.isEnteredTheStore
                                                                ? 'Order Picked up'
                                                                : vm.isAccepted
                                                                    ? 'Entered the store'
                                                                    : 'Accept Now')
                                                        .text
                                                        .color(Colors.white)
                                                        .size(18)
                                                        .fontWeight(FontWeight.w600)
                                                        .align(TextAlign.center)
                                                        .make(),
                                                  ).onTap(() async {
                                                    if (!vm.isAccepted) {
                                                      await vm
                                                          .acceptOrder(index);
                                                    } else if (!vm
                                                        .isEnteredTheStore) {
                                                      //already accepted, need to call entered the store api on click
                                                      await vm
                                                          .enteredTheStoreForOrder(
                                                              index);
                                                    } else if (!vm.isPickedUp) {
                                                      //pickup done
                                                      await vm.orderPickupDone(
                                                          index);
                                                    } else {
                                                      //delivery successful
                                                      //await vm.successfulOrderDelivery(index);
                                                    }
                                                  }),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )).p4()),
              Positioned(
                  top: 30,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: AppColor.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(15)),
                    child: !taxiViewModel!.isBusy
                        ? (!AppService().driverIsOnline
                                ? "Offline".tr()
                                : null != vm.earning
                                    ? "${vm.currency?.symbol ?? '\$'} ${(vm.earning?.amount ?? 0.0).toStringAsFixed(2)}"
                                    : "Online".tr())
                            .text
                            .color(AppColor.primaryColor)
                            .size(28)
                            .make()
                        : const CircularProgressIndicator(),
                  ).onInkTap(() {
                    if (AppService().driverIsOnline &&
                        taxiViewModel?.controllerDotCount?.isAnimating ==
                            true) {
                      taxiViewModel?.stopAnimation();
                    } else if (!AppService().driverIsOnline) {
                      taxiViewModel!.toggleOnlineStatus();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CompletedOrdersPage()),
                      );
                    }
                  })),

              !AppService().driverIsOnline
                  ? const SizedBox()
                  : Positioned(
                      right: 5,
                      bottom: vm.orderList.isEmpty ? 80 : 400,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            vm.taxiGoogleMapManagerService
                                ?.getCurrentLocation();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(width: 2, color: Colors.blue)),
                          child: const Icon(
                            Icons.location_searching,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      )),

              !AppService().driverIsOnline
                  ? const SizedBox()
                  : Positioned(
                      top: 30,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.only(top: 7, left: 7),
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          AppImages.menuIcon,
                          height: getWidth(45),
                          width: getWidth(45),
                        ),
                      ).onInkTap(() {
                        openMenuDialog(context);
                      }))
            ],
          );
        },
      ),
    );
  }

  Future<String> openStartEarningDialog(BuildContext context) async {
    String result = "";
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(15),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 2, color: AppColor.appMainColor)),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                              'We value the time of our drivers. To maintain an awarding experience, '
                              'we may limit the number of drivers actively on shift.\n\n'
                              'If a spot is not open, you may join the wait list and we will reserve your '
                              'spot and notify you when it’s available!\n',
                              maxLines: 15,
                              style: AppTextStyle.comicNeue20BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: AppColor.primaryColor, width: 2)),
                        child: Text('Show me how!',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.comicNeue25BoldTextStyle(
                                    color: AppColor.appMainColor))
                            .p4(),
                      ).onInkTap(() {
                        Navigator.pop(context);
                        openShowMeHowDialog(context);
                      })
                    ],
                  )),
            ),
          ),
        );
      },
    );
    return result;
  }

  Future<void> openShowMeHowDialog(BuildContext context) async {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('h:mm a').format(now);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(15),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(width: 2, color: AppColor.appMainColor)),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 25, 10, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Uh oh!',
                              style: AppTextStyle.comicNeue35BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                      Text(
                              'Wait time for orders is very high. No more spots are available. '
                              'Join the wait-list and we will notify you when a spot opens up',
                              maxLines: 15,
                              style: AppTextStyle.comicNeue20BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Latest start time:',
                                  maxLines: 15,
                                  style: AppTextStyle.comicNeue25BoldTextStyle(
                                      color: AppColor.appMainColor))
                              .p4(),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColor.primaryColor, width: 2)),
                            child: Text(formattedTime,
                                    textAlign: TextAlign.center,
                                    style:
                                        AppTextStyle.comicNeue16BoldTextStyle(
                                            color: AppColor.appMainColor))
                                .p4(),
                          ).onInkTap(() {
                            Navigator.pop(context);
                          }),
                          const Spacer(),
                        ],
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: AppColor.primaryColor, width: 2)),
                        child: Text('Join (4)',
                                textAlign: TextAlign.center,
                                style: AppTextStyle.comicNeue30BoldTextStyle(
                                    color: AppColor.appMainColor))
                            .p4(),
                      ).onInkTap(() {
                        Navigator.pop(context);
                        taxiViewModel!.toggleOnlineStatus();
                      })
                    ],
                  )),
            ),
          ),
        );
      },
    );
  }

  Future<bool> openMenuDialog(BuildContext context) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return SingleChildScrollView(
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(15),
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: AppColor.primaryColor,
                                        width: 2)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.logout,
                                      height: getWidth(35),
                                      width: getWidth(35),
                                    ).pOnly(right: 5),
                                    Text('Go\nOffline',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle
                                            .comicNeue20BoldTextStyle(
                                                color: AppColor.appMainColor)),
                                  ],
                                ),
                              ).onInkTap(() {
                                newState(() {
                                  if (AppService().driverIsOnline) {
                                    taxiViewModel!.toggleOnlineStatus();
                                  }
                                  Navigator.pop(context);
                                });
                              }).expand(),
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: AppColor.primaryColor,
                                        width: 2)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.chatIcon,
                                      height: getWidth(35),
                                      width: getWidth(35),
                                    ).pOnly(right: 5),
                                    Text('Help-\nChat Now',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle
                                            .comicNeue20BoldTextStyle(
                                                color: AppColor.appMainColor)),
                                  ],
                                ),
                              ).onInkTap(() {
                                Navigator.pop(context);
                              }).expand(),
                            ],
                          ).pOnly(bottom: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: AppColor.primaryColor,
                                        width: 2)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.powerYellow,
                                      height: getWidth(35),
                                      width: getWidth(35),
                                    ).pOnly(right: 5),
                                    Text('Pause\nOrders',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle
                                            .comicNeue20BoldTextStyle(
                                                color: AppColor.appMainColor)),
                                  ],
                                ),
                              ).onInkTap(() {
                                Navigator.pop(context);
                              }).expand(),
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: AppColor.primaryColor,
                                        width: 2)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.telephoneIcon,
                                      height: getWidth(35),
                                      width: getWidth(35),
                                    ).pOnly(right: 5),
                                    Text('Help-\nCall me!',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle
                                            .comicNeue20BoldTextStyle(
                                                color: AppColor.appMainColor)),
                                  ],
                                ),
                              ).onInkTap(() {
                                Navigator.pop(context);
                              }).expand(),
                            ],
                          ),
                        ],
                      )),
                ),
              );
            },
          ),
        );
      },
    );
    return result;
  }
}
