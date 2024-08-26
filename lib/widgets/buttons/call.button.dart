import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/models/vendor.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class CallButton extends StatelessWidget {
  const CallButton(
    this.vendor, {
    this.size = 24,
    this.phone,
    super.key,
  });

  final Vendor? vendor;
  final String? phone;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      FlutterIcons.phone_ant,
      size: size,
      color: Colors.white,
    ).p8().box.color(AppColor.primaryColor).roundedFull.make().onInkTap(() {
      launchUrlString("tel://${vendor?.phone ?? phone}");
    });
  }
}
