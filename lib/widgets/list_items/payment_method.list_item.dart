import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/models/payment_method.dart';
import 'package:driver/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class PaymentOptionListItem extends StatelessWidget {
  const PaymentOptionListItem(
    this.paymentMethod, {
    this.selected = false,
    super.key,
    required this.onSelected,
  });

  final bool selected;
  final PaymentMethod paymentMethod;
  final Function(PaymentMethod) onSelected;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        //
        CustomImage(
          imageUrl: paymentMethod.photo,
          width: Vx.dp48,
          height: Vx.dp48,
        ).p8(),
        //
        paymentMethod.name.text.medium.xl.make().expand(),
      ],
    )
        .box
        .roundedSM
        .border(
          color: selected
              ? AppColor.primaryColor
              : context.textTheme.bodyLarge!.color!.withOpacity(0.20),
          width: selected ? 2 : 1,
        )
        .make()
        .onInkTap(
          () => onSelected(paymentMethod),
        );
  }
}
