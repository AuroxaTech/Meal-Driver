import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({
    this.title,
    this.child,
    this.divider = true,
    this.topDivider = false,
    this.suffix,
    this.prefix,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  //
  final String? title;
  final Widget? child;
  final bool divider;
  final bool topDivider;
  final Widget? suffix;
  final Widget? prefix;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        topDivider
            ? const Divider(
                height: 1,
                thickness: 2,
              )
            : const SizedBox.shrink(),

        //
        HStack(
          [
            prefix ?? UiSpacer.emptySpace(),

            //
            (child ?? "$title".text.lg.light.make()).expand(),
            //
            suffix ??
                Icon(
                  !Utils.isArabic
                      ? FlutterIcons.right_ant
                      : FlutterIcons.left_ant,
                  size: 16,
                ),
          ],
        ).py12().px8(),

        //
        divider
            ? const Divider(
                height: 1,
                thickness: 2,
              )
            : const SizedBox.shrink(),
      ],
    ).onInkTap(
      onPressed != null ? () => onPressed!() : null,
    );
  }
}
