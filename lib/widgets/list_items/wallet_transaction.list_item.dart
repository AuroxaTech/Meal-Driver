import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/extensions/dynamic.dart';
import 'package:driver/models/wallet_transaction.dart';
import 'package:driver/utils/ui_spacer.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:intl/intl.dart';

class WalletTransactionListItem extends StatelessWidget {
  const WalletTransactionListItem(this.walletTransaction, {super.key});

  final WalletTransaction walletTransaction;

  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        UiSpacer.verticalSpace(space: 5),
        HStack(
          [
            "${walletTransaction.status.capitalized}"
                .tr()
                .text
                .medium
                .xl
                .color(AppColor.getStausColor(walletTransaction.status))
                .make()
                .expand(),
            ("${walletTransaction.isCredit == 1 ? '+' : '-'} ${"${AppStrings.currencySymbol} ${walletTransaction.amount}".currencyFormat()}")
                .text
                .semiBold
                .xl
                .color(
                    walletTransaction.isCredit == 1 ? Colors.green : Colors.red)
                .make()
          ],
        ),
        //
        HStack(
          [
            "${walletTransaction.reason}".text.make().expand(),
            DateFormat.MMMd(LocalizeAndTranslate.getLocale().languageCode)
                .format(walletTransaction.createdAt)
                .text
                .light
                .make()
          ],
        ),
      ],
    ).p8().px2();
  }
}
