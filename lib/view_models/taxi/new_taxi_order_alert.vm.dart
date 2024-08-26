import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:driver/models/new_taxi_order.dart';
import 'package:driver/requests/order.request.dart';
import 'package:driver/requests/taxi.request.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderAlertViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  NewTaxiOrder newOrder;
  bool canDismiss = false;
  CountDownController countDownTimerController = CountDownController();
  NewTaxiOrderAlertViewModel(this.newOrder, BuildContext context) {
    this.viewContext = context;
  }

  initialise() {
    //
    AppService().playNotificationSound();
    //
    countDownTimerController.start();
  }

  void processOrderAcceptance() async {
    setBusy(true);
    try {
      final order = await orderRequest.acceptNewOrder(
        newOrder.id,
        status: "preparing",
      );
      AppService().assetsAudioPlayer.stop();
      //
      Navigator.pop(viewContext,order);
      // return;
    } catch (error) {
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
        textSize: 20,
      );

      //
      canDismiss = true;
    }
    setBusy(false);
    //
    if (canDismiss) {
      AppService().assetsAudioPlayer.stop();
      Navigator.pop(viewContext);
    }
  }

  void countDownCompleted(bool started) async {
    print('Countdown Ended');
    if (started) {
      if (isBusy) {
        canDismiss = true;
      } else {
        AppService().assetsAudioPlayer.stop();
        Navigator.pop(viewContext);
        //STOP NOTIFICATION SOUND
        AppService().stopNotificationSound();
        //silently reject order assignment
        setBusy(true);
        try {
          //
          await taxiRequest.rejectAssignment(
            newOrder.id,
            AuthServices.currentUser!.id,
          );
        } catch (error) {
          print("error ignoring trip assignment ==> $error");
        }
        setBusy(false);
      }
    }
  }
}
