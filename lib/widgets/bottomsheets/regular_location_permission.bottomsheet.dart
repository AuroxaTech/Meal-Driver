import 'dart:io';

import 'package:flutter/material.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class RegularLocationPermissionDialog extends StatelessWidget {
  const RegularLocationPermissionDialog({super.key});

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //title
          "Location Permission".tr().text.semiBold.xl.make().py12(),
          "This app collects location data to enable system search for assignable order within your location and also allow customer track your location when delivering their order."
              .tr()
              .text
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: () {
              if (null != AppService().navigatorKey.currentContext) {
                Navigator.pop(AppService().navigatorKey.currentContext!, true);
              }
            },
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () {
                Navigator.pop(context, false);
                // print("called here");
              },
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}
