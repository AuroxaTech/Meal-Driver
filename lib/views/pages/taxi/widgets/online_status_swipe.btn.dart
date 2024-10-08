import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:driver/services/alert.service.dart';
import 'package:driver/view_models/taxi/taxi.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../widgets/swipe_button_widget/swipe_button_widget.dart';

class OnlineStatusSwipeButton extends StatefulWidget {
  const OnlineStatusSwipeButton(this.vm, {super.key});
  final TaxiViewModel vm;

  @override
  State<OnlineStatusSwipeButton> createState() =>
      _OnlineStatusSwipeButtonState();
}

class _OnlineStatusSwipeButtonState extends State<OnlineStatusSwipeButton> {
  //
  ObjectKey viewKey = ObjectKey(DateTime.now());
  //
  @override
  Widget build(BuildContext context) {
    final driverIsOnline = widget.vm.appService.driverIsOnline;
    //
    return SwipeButtonWidget(
        key: viewKey,
        acceptPointTransition: 0.7,
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        boxShadow: const [],
        borderRadius: BorderRadius.circular(0),
        colorBeforeSwipe: driverIsOnline ? Colors.red : Colors.green,
        colorAfterSwiped: driverIsOnline ? Colors.red : Colors.green,
        height: 50,
        childBeforeSwipe: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: driverIsOnline ? Colors.red : Colors.green,
          ),
          width: 100,
          height: double.infinity,
          child: const Center(
            child: Icon(
              FlutterIcons.chevrons_right_fea,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        childAfterSwiped: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: driverIsOnline ? Colors.red : Colors.green,
          ),
          width: 70,
          height: double.infinity,
          child: const Center(
            child: Icon(
              FlutterIcons.check_ant,
              color: Colors.white,
            ),
          ),
        ),
        leftChildren: [
          Align(
            alignment: const Alignment(0.9, 0),
            child: (driverIsOnline ? "Go offline" : "Go online")
                .tr()
                .text
                .extraBold
                .xl2
                .white
                .make(),
          )
        ],
        onHorizontalDragUpdate: (e) {},
        onHorizontalDragRight: (e) async {
          bool result = false;
          AlertService.showLoading();
          try {
            final newDriverState = !widget.vm.appService.driverIsOnline;
            //show loading
            await widget.vm.newTaxiBookingService
                ?.toggleVisibility(newDriverState);

            setState(() {
              viewKey = ObjectKey(DateTime.now());
            });
            result = true;
          } catch (error) {
            widget.vm.toastError("$error");
          }
          AlertService.stopLoading();
          return result;
        },
        onHorizontalDragLeft: (e) async {
          return false;
        }).h(widget.vm.isBusy ? 0 : 60);
  }
}
