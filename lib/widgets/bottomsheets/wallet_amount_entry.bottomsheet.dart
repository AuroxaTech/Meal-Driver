import 'package:flutter/material.dart';
import 'package:driver/services/validator.service.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:driver/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletAmountEntryBottomSheet extends StatefulWidget {
  const WalletAmountEntryBottomSheet({
    required this.onSubmit,
    super.key,
  });

  final Function(String) onSubmit;

  @override
  State<WalletAmountEntryBottomSheet> createState() =>
      _WalletAmountEntryBottomSheetState();
}

class _WalletAmountEntryBottomSheetState
    extends State<WalletAmountEntryBottomSheet> {
  //
  final formKey = GlobalKey<FormState>();
  final amountTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: context.mq.viewPadding.bottom),
        child: VStack(
          [
            //
            "Top-Up Wallet".tr().text.xl2.semiBold.make(),
            "Enter amount to top-up wallet with".tr().text.make(),
            Form(
              key: formKey,
              child: CustomTextFormField(
                labelText: "Amount".tr(),
                textEditingController: amountTEC,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => FormValidator.validateEmpty(
                  value,
                  errorTitle: "Amount".tr(),
                ),
              ),
            ).py12(),
            //
            CustomButton(
              title: "TOP-UP".tr(),
              onPressed: () {
                //
                if (formKey.currentState!.validate()) {
                  widget.onSubmit(amountTEC.text);
                }
              },
            ),
          ],
        )
            .hOneThird(context)
            .p20()
            .pOnly(
              bottom: context.mq.viewInsets.bottom,
            )
            .scrollVertical());
  }
}
