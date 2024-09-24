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
import 'package:driver/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class EarningPage extends StatelessWidget {
  const EarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EarningViewModel>.reactive(
      viewModelBuilder: () => EarningViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return Material(
            child: VStack(
          [
            50.heightBox,
            "Wallet"
                .tr()
                .text
                .bold
                .size(37)
                .color(AppColor.primaryColor)
                .make(),
            if (vm.isBusy)
              const BusyIndicator().centered().p20().expand()
            else
              Padding(
                padding: const EdgeInsets.all(14),
                child: VStack(
                  [
                    //amount
                    "Your Earning ${vm.currency?.symbol} ${vm.earning?.available.toStringAsFixed(2)}"
                        .currencyValueFormat()
                        .text
                        .bold
                        .size(35)
                        .color(AppColor.primaryColor)
                        .make()
                        .pOnly(top: 5, bottom: 25),

                    "Pending ${vm.currency?.symbol} ${vm.earning?.pending.toStringAsFixed(2)}"
                        .currencyValueFormat()
                        .text
                        .bold
                        .size(25)
                        .color(AppColor.primaryColor)
                        .make()
                        .pOnly(bottom: 12),
                    "Available ${vm.currency?.symbol} ${vm.earning?.available.toStringAsFixed(2)}"
                        .currencyValueFormat()
                        .text
                        .bold
                        .size(25)
                        .color(AppColor.primaryColor)
                        .make()
                        .pOnly(bottom: 12),

                    Align(
                      alignment: Alignment.topRight,
                      child: CustomButton(
                        title:
                            "Cashout Now\n\$${vm.earning?.available.toStringAsFixed(2)}",
                        titleStyle: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        height: 75,
                        shapeRadius: 15,
                        onPressed:
                            vm.showEarning, //vm.processPayoutRequest,
                      ).centered().py12().w(300),
                    ),
                    // "${vm.earning?.formattedUpdatedDate}".text.medium.lg.makeCentered(),

                    //request payout
                    // Visibility(
                    //   visible: !vm.showPayout,
                    //   child: CustomButton(
                    //     title: "Request Payout".tr(),
                    //     onPressed: vm.requestEarningPayout,
                    //   ).py20(),
                    // ),

                    //payout form
                    // Visibility(
                    //   visible: vm.showPayout,
                    //   child: Form(
                    //     key: vm.formKey,
                    //     child: vm.busy(vm.paymentAccounts)
                    //         ? const BusyIndicator().centered().py20()
                    //         : VStack(
                    //             [
                    //               //
                    //               const Divider(thickness: 2).py12(),
                    //               "Request Payout".tr().text.semiBold.xl.make(),
                    //               UiSpacer.verticalSpace(),
                    //               //
                    //               "Payment Account".tr().text.base.light.make(),
                    //               DropdownButtonFormField<PaymentAccount>(
                    //                 decoration: const InputDecoration.collapsed(
                    //                     hintText: ""),
                    //                 value: vm.selectedPaymentAccount,
                    //                 onChanged: (value) {
                    //                   vm.selectedPaymentAccount = value;
                    //                   vm.notifyListeners();
                    //                 },
                    //                 items: vm.paymentAccounts.map(
                    //                   (e) {
                    //                     return DropdownMenuItem(
                    //                         value: e,
                    //                         child:
                    //                             Text("${e.name}(${e.number})")
                    //                         // .text
                    //                         // .make(),
                    //                         );
                    //                   },
                    //                 ).toList(),
                    //               )
                    //                   .p12()
                    //                   .box
                    //                   .border(color: AppColor.accentColor)
                    //                   .roundedSM
                    //                   .make()
                    //                   .py4(),
                    //               //
                    //               UiSpacer.verticalSpace(space: 10),
                    //               CustomTextFormField(
                    //                 labelText: "Amount".tr(),
                    //                 textEditingController: vm.amountTEC,
                    //                 keyboardType:
                    //                     const TextInputType.numberWithOptions(
                    //                   decimal: true,
                    //                 ),
                    //                 validator: (value) =>
                    //                     FormValidator.validateCustom(
                    //                   value,
                    //                   rules:
                    //                       "required||numeric||lte:${vm.earning?.amount}",
                    //                 ),
                    //               ).py12(),
                    //               CustomButton(
                    //                 title: "Request Payout".tr(),
                    //                 loading: vm.busy(vm.selectedPaymentAccount),
                    //                 onPressed: vm.processPayoutRequest,
                    //               ).centered().py12(),
                    //               //
                    //               CustomTextButton(
                    //                 title: "Close".tr(),
                    //                 onPressed: () {
                    //                   vm.showPayout = false;
                    //                   vm.notifyListeners();
                    //                 },
                    //               ).centered(),
                    //             ],
                    //           ).scrollVertical(),
                    //   ),
                    // ),
                  ],
                  crossAlignment: CrossAxisAlignment.start,
                  alignment: MainAxisAlignment.start,
                )
                    //.h(context.percentHeight * (vm.showPayout ? 80 : 30))
                    .box
                    .p8
                    .border(color: AppColor.primaryColor, width: 2)
                    .color(context.theme.colorScheme.background)
                    .withRounded()
                    .width(double.infinity)
                    .make(),
              ),
          ],
        )).pOnly(left: 8, right: 8, bottom: 8);
      },
    );
  }
}
