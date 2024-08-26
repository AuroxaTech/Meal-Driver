import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/models/order.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderCustomerInfoView extends StatelessWidget {
  const OrderCustomerInfoView(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    double avatarSize = 40;

    //
    return VxBox(
      child: HStack(
        [
          //customer profile
          CustomImage(
            imageUrl: order.user.photo,
            width: avatarSize,
            height: avatarSize,
          ),
          UiSpacer.hSpace(12),

          VStack(
            [
              "${order.user.name}".text.medium.make(),
              VxRating(
                isSelectable: false,
                onRatingUpdate: (value) {},
                maxRating: 5.0,
                count: 5,
                size: 16,
                value: order.user.rating,
                selectionColor: AppColor.ratingColor,
              ),
            ],
          ).expand(),
        ],
        crossAlignment: CrossAxisAlignment.center,
      ).px20().py12(),
    ).shadowXs.color(context.theme.colorScheme.background).make();
  }
}
