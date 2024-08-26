import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_text_styles.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomOutlineButton extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final double? iconSize;
  final Widget? child;
  final TextStyle? titleStyle;
  final Function? onPressed;
  final OutlinedBorder? shape;
  final bool isFixedHeight;
  final double? height;
  final bool loading;
  final double? shapeRadius;
  final Color? color;
  final Color? iconColor;

  const CustomOutlineButton({
    this.title,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.child,
    this.onPressed,
    this.shape,
    this.isFixedHeight = false,
    this.height,
    this.loading = false,
    this.shapeRadius = Vx.dp4,
    this.color,
    this.titleStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      padding: const EdgeInsets.all(0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: color ?? AppColor.primaryColor,
            disabledBackgroundColor:
                loading ? AppColor.primaryColor : null,
            shape: shape ??
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(shapeRadius ?? Vx.dp4),
                ),
            side: BorderSide(
              color: color ?? AppColor.primaryColor,
            )),
        onPressed: (loading || onPressed == null)
            ? null
            : () => onPressed!(),
        child: loading
            ? const BusyIndicator(color: Colors.white)
            : SizedBox(
                width: null, //double.infinity,
                height: isFixedHeight ? Vx.dp48 : (height ?? Vx.dp48),
                child: child ??
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon != null
                            ? Icon(icon,
                                    color: iconColor ?? Colors.white,
                                    size: iconSize ?? 20,
                                    textDirection:
                                        LocalizeAndTranslate.getLocale().languageCode ==
                                                "ar"
                                            ? TextDirection.rtl
                                            : TextDirection.ltr)
                                .pOnly(
                                right:
                                LocalizeAndTranslate.getLocale().languageCode == "ar"
                                        ? Vx.dp0
                                        : Vx.dp5,
                                left:
                                LocalizeAndTranslate.getLocale().languageCode != "ar"
                                        ? Vx.dp0
                                        : Vx.dp5,
                              )
                            : UiSpacer.emptySpace(),
                        (title != null && title!.isNotBlank)
                            ? Text(
                                "$title",
                                textAlign: TextAlign.center,
                                style: titleStyle ??
                                    AppTextStyle.h3TitleTextStyle(
                                      color: Colors.white,
                                    ),
                              ).centered()
                            : UiSpacer.emptySpace(),
                      ],
                    ),
              ),
      ),
    );
  }
}
