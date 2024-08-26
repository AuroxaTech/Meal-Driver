import 'package:flutter/material.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/services/alert.service.dart';
import 'package:driver/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: Utils.isArabic ? null : 20,
      left: !Utils.isArabic ? null : 20,
      child: VxBox(
        child: "SOS".text.xl2.extraBold.white.make().p8(),
      )
          .p8
          .color(Colors.red.shade600)
          .roundedFull
          .outerShadow
          .shadowXl
          .make()
          .onTap(
        () {
          try {
            launchUrlString("tel:${AppStrings.emergencyContact}");
          } catch (error) {
            AlertService.error(title: "SOS".tr(), text: "$error");
          }
        },
      ).safeArea(),
    );
  }
}
