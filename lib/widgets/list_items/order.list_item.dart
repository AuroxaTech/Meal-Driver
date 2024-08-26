import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/models/order.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    required this.order,
    this.onPayPressed,
    required this.orderPressed,
    super.key,
  });

  final Order order;
  final Function? onPayPressed;
  final Function orderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        "${order.vendor?.name}"
            .text
            .xl
            .bold
            .color(AppColor.primaryColor)
            .make(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "#${order.code}"
                .text
                .xl
                .bold
                .color(AppColor.primaryColor)
                .make()
                .expand(),
            "\$${(order.commission?.driver ?? 0).toStringAsFixed(2)}"
                .text
                .lg
                .color(
                  AppColor.primaryColor,
                )
                .bold
                .make(),
          ],
        ),
      ],
    )
        .onInkTap(() => orderPressed())
        .box
        .clip(Clip.antiAlias)
        .padding(const EdgeInsets.all(10))
        .border(color: AppColor.primaryColor, width: 2.5)
        .color(Colors.white)
        .withRounded()
        .make();
  }
}
