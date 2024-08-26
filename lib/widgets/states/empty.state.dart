import 'package:flutter/material.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.imageUrl,
    this.title = "",
    this.actionText = "Action",
    this.description = "",
    this.showAction = false,
    this.actionPressed,
    this.auth = false,
  });

  final String title;
  final String actionText;
  final String description;
  final String? imageUrl;
  final Function? actionPressed;
  final bool showAction;
  final bool auth;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        (imageUrl != null && imageUrl!.isNotBlank)
            ? Image.asset(imageUrl!)
                .wh(
                  Vx.dp64 * 2,
                  Vx.dp64 * 2,
                )
                .box
                .makeCentered()
                .wFull(context)
            : UiSpacer.emptySpace(),

        //
        (title.isNotEmpty)
            ? title.text.xl.semiBold.center.makeCentered()
            : const SizedBox.shrink(),

        //
        auth
            ? Image.asset(AppImages.auth)
                .wh(
                  Vx.dp64,
                  Vx.dp64,
                )
                .box
                .makeCentered()
                .py12()
                .wFull(context)
            : const SizedBox.shrink(),
        //
        auth
            ? "You have to login to access profile and history"
                .tr()
                .text
                .center
                .lg
                .light
                .makeCentered()
                .py12()
            : description.isNotEmpty
                ? description.text.lg.light.center.makeCentered()
                : const SizedBox.shrink(),

        //
        auth
            ? CustomButton(
                title: "Login".tr(),
                onPressed: actionPressed,
              ).centered()
            : showAction
                ? CustomButton(
                    title: actionText,
                    onPressed: actionPressed,
                  ).centered().py12()
                : const SizedBox.shrink(),
      ],
    );
  }
}
