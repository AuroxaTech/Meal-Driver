import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/models/user.dart';
import 'package:driver/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiCustomerView extends StatelessWidget {
  const TaxiCustomerView(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return HStack(
      [
        CustomImage(
          imageUrl: user.photo,
          width: 40,
          height: 40,
        ).box.roundedFull.clip(Clip.antiAlias).make(),
        VStack(
          [
            //
            "${user.name}".text.xl.medium.make(),
            VxRating(
              maxRating: 5,
              selectionColor: AppColor.ratingColor,
              value: user.rating,
              onRatingUpdate: (value) {},
              isSelectable: false,
            ),
          ],
        ).px12().expand(),
      ],
    );
  }
}
