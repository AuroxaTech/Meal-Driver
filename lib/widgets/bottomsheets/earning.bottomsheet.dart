import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/extensions/dynamic.dart';
import 'package:driver/models/payment_account.dart';
import 'package:driver/services/validator.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/view_models/earning.vm.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:driver/widgets/buttons/custom_text_button.dart';
import 'package:driver/widgets/currency_hstack.dart';
import 'package:driver/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class EarningBottomSheet extends StatelessWidget {
  const EarningBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EarningViewModel>.reactive(
      viewModelBuilder: () => EarningViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return VStack(
          [
            "Earning".tr().text.medium.xl2.makeCentered(),
            vm.isBusy
                ? const BusyIndicator().centered().p20().expand()
                : VStack(
                    [
                      //amount
                      CurrencyHStack(
                        [
                          //currency
                          "${vm.currency?.symbol}".text.medium.xl.make().px4(),
                          //earning
                          "${vm.earning?.amount}"
                              .currencyValueFormat()
                              .text
                              .semiBold
                              .xl3
                              .make(),
                        ],
                        crossAlignment: CrossAxisAlignment.center,
                        alignment: MainAxisAlignment.center,
                      ).py12(),
                      //updated at
                      "${vm.earning?.formattedUpdatedDate}"
                          .text
                          .medium
                          .lg
                          .makeCentered(),

                      //request payout
                      Visibility(
                        visible: !vm.showPayout,
                        child: CustomButton(
                          title: "Request Payout".tr(),
                          onPressed: vm.requestEarningPayout,
                        ).py20(),
                      ),

                      //payout form
                      Visibility(
                        visible: vm.showPayout,
                        child: Form(
                          key: vm.formKey,
                          child: vm.busy(vm.paymentAccounts)
                              ? const BusyIndicator().centered().py20()
                              : VStack(
                                  [
                                    //
                                    const Divider(thickness: 2).py12(),
                                    "Request Payout"
                                        .tr()
                                        .text
                                        .semiBold
                                        .xl
                                        .make(),
                                    UiSpacer.verticalSpace(),
                                    //
                                    "Payment Account"
                                        .tr()
                                        .text
                                        .base
                                        .light
                                        .make(),
                                    DropdownButtonFormField<PaymentAccount>(
                                      decoration:
                                          const InputDecoration.collapsed(
                                              hintText: ""),
                                      value: vm.selectedPaymentAccount,
                                      onChanged: (value) {
                                        vm.selectedPaymentAccount = value;
                                        vm.notifyListeners();
                                      },
                                      items: vm.paymentAccounts.map(
                                        (e) {
                                          return DropdownMenuItem(
                                              value: e,
                                              child:
                                                  Text("${e.name}(${e.number})")
                                              // .text
                                              // .make(),
                                              );
                                        },
                                      ).toList(),
                                    )
                                        .p12()
                                        .box
                                        .border(color: AppColor.accentColor)
                                        .roundedSM
                                        .make()
                                        .py4(),
                                    //
                                    UiSpacer.verticalSpace(space: 10),
                                    CustomTextFormField(
                                      labelText: "Amount".tr(),
                                      textEditingController: vm.amountTEC,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      validator: (value) =>
                                          FormValidator.validateCustom(
                                        value,
                                        rules:
                                            "required||numeric||lte:${vm.earning?.amount}",
                                      ),
                                    ).py12(),
                                    CustomButton(
                                      title: "Request Payout".tr(),
                                      loading:
                                          vm.busy(vm.selectedPaymentAccount),
                                      onPressed: vm.processPayoutRequest,
                                    ).centered().py12(),
                                    //
                                    CustomTextButton(
                                      title: "Close".tr(),
                                      onPressed: () {
                                        vm.showPayout = false;
                                        vm.notifyListeners();
                                      },
                                    ).centered(),
                                  ],
                                ).scrollVertical(),
                        ),
                      ),
                    ],
                    crossAlignment: CrossAxisAlignment.center,
                    alignment: MainAxisAlignment.center,
                  ),
          ],
        )
            .p20()
            .h(context.percentHeight * (vm.showPayout ? 80 : 34))
            .box
            .color(context.theme.colorScheme.background)
            .topRounded()
            .make();
      },
    );
  }
}
