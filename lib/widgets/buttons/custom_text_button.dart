import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_text_styles.dart';
import 'package:driver/widgets/busy_indicator.dart';

class CustomTextButton extends StatelessWidget {
  final Function? onPressed;
  final String title;
  final Color? titleColor;
  final EdgeInsets? padding;
  final bool loading;

  //
  const CustomTextButton({
    required this.title,
    this.onPressed,
    this.titleColor,
    this.padding,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      style: TextButton.styleFrom(
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: loading
          ? const Center(
              child: BusyIndicator(),
            )
          : Text(
              title,
              style: AppTextStyle.h4TitleTextStyle(
                color: titleColor ?? AppColor.primaryColor,
              ),
            ),
    );
  }
}
