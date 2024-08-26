import 'package:flutter/material.dart';
import 'package:driver/view_models/profile.vm.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Legal Documents".tr(),
      body: ViewModelBuilder<ProfileViewModel>.reactive(
        viewModelBuilder: () => ProfileViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          return VStack(
            [
              //
              //
              MenuItem(
                title: "Privacy Policy".tr(),
                onPressed: model.openPrivacyPolicy,
              ),
              //
              MenuItem(
                title: "Terms & Conditions".tr(),
                onPressed: model.openTerms,
              ),
            ],
          ).p20().scrollVertical();
        },
      ),
    );
  }
}
