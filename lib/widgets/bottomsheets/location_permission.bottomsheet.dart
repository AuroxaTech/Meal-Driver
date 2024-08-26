import 'dart:io';

import 'package:flutter/material.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({
    super.key,
    required this.onResult,
  });

  //
  final Function(bool) onResult;

  //
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          //title
          "Location Permission Request".tr().text.semiBold.xl.make().py12(),
          ("${AppStrings.appName} ${"requires your location permission to enable customer track your location when delivering their order".tr()}")
              .text
              .make(),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Next".tr(),
            onPressed: () {
              onResult(true);
              if (null != AppService().navigatorKey.currentContext) {
                Navigator.pop(AppService().navigatorKey.currentContext!);
              }
            },
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () {
                onResult(false);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}
