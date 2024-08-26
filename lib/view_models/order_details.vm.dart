import 'dart:io';
//import 'package:firestore_chat/firestore_chat.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/app_routes.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/constants/app_ui_settings.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/delivery_address.dart';
import 'package:driver/models/order.dart';
import 'package:driver/models/order_stop.dart';
import 'package:driver/requests/order.request.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/services/chat.service.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:driver/views/pages/order/widgets/photo_verification.page.dart';
import 'package:driver/views/pages/order/widgets/scanner_verification_dialog.dart';
import 'package:driver/views/pages/order/widgets/signature_verification.page.dart';
import 'package:driver/views/pages/order/widgets/verification_dialog.dart';
import 'package:driver/widgets/dialogs/collect_cash_info.dialog.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderDetailsViewModel extends MyBaseViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  bool changed = false;
  double earnings = 0.0;

  //
  OrderDetailsViewModel(BuildContext context, this.order) {
    viewContext = context;
  }

  initialise() {
    fetchOrderDetails();
  }

  openPaymentPage() {
    launchUrlString(order.paymentLink);
  }

  void callVendor() {
    launchUrlString("tel:${order.vendor?.phone}");
  }

  void callCustomer() {
    launchUrlString("tel:${order.user.phone}");
  }

  void callRecipient() {
    launchUrlString("tel:${order.recipientPhone}");
  }

  chatVendor() {
    //
    Map<String, PeerUser> peers = {
      '${order.driver!.id}': PeerUser(
        id: '${order.driver!.id}',
        name: order.driver!.name,
        image: order.driver!.photo,
      ),
      'vendor_${order.vendor!.id}': PeerUser(
        id: "vendor_${order.vendor!.id}",
        name: order.vendor!.name,
        image: order.vendor!.logo,
      ),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${order.driver?.id}']!,
      peers: peers,
      //don't translate this
      path: 'orders/' + order.code + "/driverVendor/chats",
      title: "Chat with vendor".tr(),
      supportMedia: AppUISettings.canDriverChatSupportMedia,
    );
    //
    Navigator.of(viewContext).pushNamed(
      AppRoutes.chatRoute,
      arguments: chatEntity,
    );
  }

  chatCustomer() {
    //
    Map<String, PeerUser> peers = {
      '${order.driver!.id}': PeerUser(
        id: '${order.driver!.id}',
        name: order.driver!.name,
        image: order.driver!.photo,
      ),
      '${order.user.id}': PeerUser(
          id: "${order.user.id}",
          name: order.user.name,
          image: order.user.photo),
    };
    //
    final chatEntity = ChatEntity(
      onMessageSent: ChatService.sendChatMessage,
      mainUser: peers['${order.driver?.id}']!,
      peers: peers,
      //don't translate this
      path: 'orders/' + order.code + "/customerDriver/chats",
      title: "Chat with customer".tr(),
      supportMedia: AppUISettings.canDriverChatSupportMedia,
    );
    //
    Navigator.of(viewContext).pushNamed(
      AppRoutes.chatRoute,
      arguments: chatEntity,
    );
  }

  void fetchOrderDetails() async {
    setBusy(true);
    try {
      print('API Getting Hit');
      order = await orderRequest.getOrderDetails(id: order.id);
      earnings = order.commission?.driver ?? 0;
      print("Driver commission ${earnings}");
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      toastError("$error");
    }
    setBusy(false);
  }

  //
  void initiateOrderCompletion() async {
    if (AppStrings.enableProofOfDelivery) {
      //code verification code
      if (!AppStrings.signatureVerify && !AppStrings.verifyOrderByPhoto) {
        showModalBottomSheet(
          context: AppService().navigatorKey.currentContext!,
          isScrollControlled: true,
          builder: (context) {
            return OrderVerificationDialog(
              order: order,
              onValidated: () {
                if(null != AppService().navigatorKey.currentContext){
                  Navigator.pop(AppService().navigatorKey.currentContext!);
                }

                processOrderCompletion();
              },
              openQRCodeScanner: () {
                if(null != AppService().navigatorKey.currentContext){
                  Navigator.pop(AppService().navigatorKey.currentContext!);
                }

                showQRCodeScanner();
              },
            );
          },
        );
      }
      //verification via photo
      else if (AppStrings.verifyOrderByPhoto) {
        final result = await Navigator.push(
            viewContext,
            MaterialPageRoute(builder: (context) => PhotoVerificationPage(order: order),
        ),);
        //
        if (result is Order) {
          order = result;
          notifyListeners();
        } else if (result != null && result) {
          processOrderCompletion();
        }
      }
      //verification via signature
      else {
        final result = await Navigator.push(
            viewContext,
            MaterialPageRoute(builder: (context) => SignatureVerificationPage(order: order),
        ),);
        //
        if (result is Order) {
          order = result;
          notifyListeners();
        } else if (result != null && result) {
          processOrderCompletion();
        }
      }
    } else {
      processOrderCompletion();
    }
  }

  //
  showQRCodeScanner() async {
    showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return Dialog(
          child: ScanOrderVerificationDialog(
            order: order,
            onValidated: () {
              // AppService().navigatorKey.currentContext.pop();
              processOrderCompletion();
            },
          ),
        );
      },
    );
  }

  void processOrderCompletion() async {
    setBusyForObject(order, true);
    try {
      order = await orderRequest.updateOrder(
        id: order.id,
        status: "delivered",
      );
      //beaware a change as occurred
      changed = true;
      clearErrors();
      //show successful toast
      toastSuccessful("Order completed successfully".tr());
      //show a cash collection dialog if is cash order
      if (order.paymentMethod?.slug == "cash") {
        showDialog(
          barrierDismissible: false,
          context: viewContext,
          builder: (context) {
            return CollectCashInfoDialog(order);
          },
        );
      }
    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      toastError("$error");
    }
    setBusyForObject(order, false);
  }

  //
  void processOrderEnroute() async {
    setBusyForObject(order, true);
    try {
      order = await orderRequest.updateOrder(
        id: order.id,
        status: "enroute",
      );
      //beaware a change as occurred
      changed = true;
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setErrorForObject(order, error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
      );
    }
    setBusyForObject(order, false);
  }

  onBackPressed() {
    if(null != AppService().navigatorKey.currentContext){
      Navigator.pop(AppService().navigatorKey.currentContext!,changed ? order : null);
    }
  }

  //
  routeToLocation(DeliveryAddress deliveryAddress) async {
    try {
      final coords = Coords(
        deliveryAddress.latitude!,
        deliveryAddress.longitude!,
      );
      final title = deliveryAddress.name;
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: AppService().navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title ?? "",
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  //
  verifyStop(OrderStop stop) async {
    //code verification code
    if (AppStrings.verifyOrderByPhoto) {
      await Navigator.push(
          viewContext,
          MaterialPageRoute(builder: (context) => PhotoVerificationPage(
          order: order,
          onsubmit: (photo) {
            processOrderStopVerification(stop, photo);
            Navigator.pop(viewContext);
          },
        ),
      ),);
    }
    //verification via signature
    else {
      await Navigator.push(
          viewContext,
          MaterialPageRoute(builder: (context) => SignatureVerificationPage(
          order: order,
          onsubmit: (photo) {
            processOrderStopVerification(stop, photo);
            Navigator.pop(viewContext);
          },
        ),
      ),);
    }
  }

  void processOrderStopVerification(OrderStop stop, File photo) async {
    setBusyForObject(stop, true);
    try {
      ApiResponse apiResponse = await orderRequest.verifyOrderStopRequest(
        id: stop.id,
        signaturePath: photo.path,
      );
      clearErrors();
      //
      order = Order.fromJson(apiResponse.body["order"]);
      notifyListeners();
      toastSuccessful(apiResponse.body["message"]);
    } catch (error) {
      print("Error ==> $error");
      toastError("$error");
    }
    setBusyForObject(stop, false);
  }
}
