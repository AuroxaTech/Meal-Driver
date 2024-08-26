import 'package:flutter/material.dart';
import 'package:driver/extensions/dynamic.dart';
import 'package:driver/models/product.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/widgets/cards/custom.visibility.dart';
import 'package:driver/widgets/currency_hstack.dart';
import 'package:driver/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class HorizontalProductListItem extends StatelessWidget {
  //
  const HorizontalProductListItem(
    this.product, {
    required this.onPressed,
    super.key,
  });

  //
  final Product product;
  final Function(Product) onPressed;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;

    //
    return HStack(
      [
        //
        Hero(
          tag: product.heroTag ?? product.id,
          child: CustomImage(imageUrl: product.photo)
              .wh(Vx.dp64, Vx.dp64)
              .box
              .clip(Clip.antiAlias)
              .roundedSM
              .make(),
        ),

        //Details
        VStack(
          [
            //name
            product.name.text.lg.medium
                .maxLines(2)
                .overflow(TextOverflow.ellipsis)
                .make(),
            //description
            product.description.text.sm.medium
                .maxLines(1)
                .overflow(TextOverflow.ellipsis)
                .make(),
          ],
        ).px12().expand(),

        //
        VStack(
          [
            //price
            CurrencyHStack(
              [
                currencySymbol.text.lg.make(),
                product.sellPrice.currencyValueFormat().text.xl.semiBold.make(),
              ],
              crossAlignment: CrossAxisAlignment.end,
            ),
            //discount
            CustomVisibility(
              visible: product.showDiscount,
              child: CurrencyHStack(
                [
                  currencySymbol.text.lineThrough.xs.make(),
                  product.price
                      .currencyValueFormat()
                      .text
                      .lineThrough
                      .lg
                      .medium
                      .make(),
                ],
              ),
            ),
          ],
        ),
      ],
    ).p8().onInkTap(() => onPressed(product)).card.make();
  }
}
