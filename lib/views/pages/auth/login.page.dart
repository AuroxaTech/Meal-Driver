import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/view_models/login.view_model.dart';
import 'package:driver/views/pages/auth/login/compain_login_type.view.dart';
import 'package:driver/views/pages/auth/login/email_login.view.dart';
import 'package:driver/views/pages/auth/login/otp_login.view.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/buttons/custom_text_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'login/scan_login.view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.reactive(
      viewModelBuilder: () => LoginViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          backgroundColor: context.theme.colorScheme.background,
          body: VStack(
            [
              UiSpacer.vSpace(5 * context.percentHeight),
              Center(
                  child: Image.asset(AppImages.logoWithoutText)
                      .wh(230, 230)
                      .box
                      .clip(Clip.antiAlias)
                      .make()
                      .p12()),

              if (AppStrings.enableOTPLogin && AppStrings.enableEmailLogin)
                CombinedLoginTypeView(model),
              //only email login
              if (AppStrings.enableEmailLogin && !AppStrings.enableOTPLogin)
                EmailLoginView(model),
              //only otp login
              if (AppStrings.enableOTPLogin && !AppStrings.enableEmailLogin)
                OTPLoginView(model),

              ScanLoginView(model),
              20.heightBox,

              //registration link
              Visibility(
                visible: AppStrings.partnersCanRegister,
                child: CustomTextButton(
                  title: "Become a partner".tr(),
                  onPressed: model.openRegistrationlink,
                )
                    .wFull(context)
                    .box
                    .roundedSM
                    .border(color: AppColor.primaryColor)
                    .make(),
              ),

              //
            ],
          ).wFull(context).p20().scrollVertical().pOnly(
                bottom: context.mq.viewInsets.bottom,
              ),
        );
      },
    );
  }
}
