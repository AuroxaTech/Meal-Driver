import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class InputStyles {
  //get the border for the textform field
  static InputBorder inputEnabledBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
      borderRadius: BorderRadius.circular(Vx.dp14),
    );
  }

  //get the border for the textform field
  static InputBorder inputFocusBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColorDark, width: 2),
      borderRadius: BorderRadius.circular(Vx.dp14),
    );
  }

  //
  //get the border for the textform field
  static InputBorder inputUnderlineEnabledBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
      borderRadius: BorderRadius.circular(Vx.dp14),
    );
  }

  //get the border for the textform field
  static InputBorder inputUnderlineFocusBorder() {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: AppColor.primaryColorDark, width: 2),
      borderRadius: BorderRadius.circular(Vx.dp14),
    );
  }
}
