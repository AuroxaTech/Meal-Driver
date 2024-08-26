import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../services/validator.service.dart';
import '../../../view_models/bank_account_details.vm.dart';
import '../../../widgets/base.page.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/custom_text_form_field.dart';

class BankAccountDetailsPage extends StatelessWidget {
  const BankAccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BankAccountDetailsViewModel>.reactive(
      viewModelBuilder: () => BankAccountDetailsViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Bank Account Details",
          body: SafeArea(
              top: true,
              bottom: false,
              child: VStack(
                [
                  Form(
                    key: model.formKey,
                    child: VStack(
                      [
                        CustomTextFormField(
                          labelText: "Name",
                          hintText: "Name",
                          textEditingController: model.nameTEC,
                          validator: FormValidator.validateEmpty,
                        ).py12(),
                        CustomTextFormField(
                          labelText: "Account number",
                          hintText: "Account number",
                          textEditingController: model.accountNumberTEC,
                          validator: FormValidator.validateEmpty,
                        ).py12(),
                        CustomTextFormField(
                          labelText: "Transit number",
                          hintText: "Transit number",
                          textEditingController: model.transitNumberTEC,
                          validator: FormValidator.validateEmpty,
                        ).py12(),
                        CustomTextFormField(
                          labelText: "Institution number",
                          hintText: "Institution number",
                          textEditingController: model.institutionNumberTEC,
                          validator: FormValidator.validateEmpty,
                        ).py12(),
                        CustomButton(
                          title: "Save".tr(),
                          loading: model.isBusy,
                          onPressed: model.processUpdate,
                        ).centered().py12(),
                      ],
                    ),
                  ),
                ],
              ).p20().scrollVertical()),
        );
      },
    );
  }
}
