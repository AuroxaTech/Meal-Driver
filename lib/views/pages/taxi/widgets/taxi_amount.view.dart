import 'package:flutter/material.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/extensions/dynamic.dart';
import 'package:driver/models/order.dart';
import 'package:driver/widgets/currency_hstack.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiAmountView extends StatelessWidget {
  const TaxiAmountView(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return CurrencyHStack([
      (order.taxiOrder?.currency != null
              ? order.taxiOrder!.currency!.symbol
              : AppStrings.currencySymbol)
          .text
          .medium
          .lg
          .make()
          .px4(),
      (order.total ?? 0.00).currencyValueFormat().text.bold.xl2.make(),
    ]);
  }
}
