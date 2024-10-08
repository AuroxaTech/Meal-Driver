import 'package:flutter/material.dart';
import 'package:driver/models/payment_account.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PaymentAccountListItem extends StatelessWidget {
  const PaymentAccountListItem(
    this.paymentAccount, {
    super.key,
    required this.onPressed,
  });

  final PaymentAccount paymentAccount;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        Row(
          children: [
            //name
            VStack(
              [
                "Account Name".tr().text.sm.make(),
                paymentAccount.name.text.xl.medium.make(),
              ],
            ).expand(),
            UiSpacer.hSpace(),
            //
            VStack(
              [
                "Account Number".tr().text.sm.make(),
                paymentAccount.number.text.xl.medium.make(),
              ],
              crossAlignment: CrossAxisAlignment.end,
            ),
          ],
        ),

        //

        Visibility(
          visible: paymentAccount.instructions.isNotEmpty,
          child: VStack(
            [
              "Instructions".tr().text.medium.make(),
              paymentAccount.instructions.text.sm.hairLine.make(),
            ],
          ).pOnly(top: Vx.dp12),
        ),
      ],
    )
        .p12()
        .box
        .color(context.theme.colorScheme.background)
        .outerShadow
        .rounded
        .margin(const EdgeInsets.symmetric(horizontal: Vx.dp4))
        .make()
        .opacity(value: paymentAccount.isActive ? 1.0 : 0.6)
        .onInkTap(() => onPressed());
  }
}
