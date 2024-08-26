import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/services/validator.service.dart';
import 'package:driver/view_models/login.view_model.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:driver/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EmailLoginView extends StatelessWidget {
  const EmailLoginView(this.model, {super.key});

  final LoginViewModel model;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: model.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //
          'Email'.text.color(AppColor.primaryColor).bold.size(25).make(),
          5.heightBox,
          CustomTextFormField(
            labelText: "Email".tr(),
            keyboardType: TextInputType.emailAddress,
            textEditingController: model.emailTEC,
            validator: FormValidator.validateEmail,
          ).pOnly(bottom: 12),
          'Password'.text.color(AppColor.primaryColor).bold.size(25).make(),
          5.heightBox,
          CustomTextFormField(
            labelText: "Password".tr(),
            obscureText: true,
            textEditingController: model.passwordTEC,
            validator: FormValidator.validatePassword,
          ).pOnly(bottom: 12),
          (!model.isBusy)
              ? 'Sign in'
              .text
              .bold
              .color(AppColor.primaryColor)
              .center
              .size(42)
              .make()
              .onTap(() {
            model.processLogin();
          }).centered()
              : const CircularProgressIndicator().p(20).centered(),
          //
          8.heightBox,
          "Forgot Password ?"
              .tr()
              .text
              .size(25)
              .color(AppColor.primaryColor)
              .bold
              .make()
              .onInkTap(
            model.openForgotPassword,
          )
              .centered(),

          //

          // CustomButton(
          //   title: "Login".tr(),
          //   loading: model.isBusy,
          //   onPressed: model.processLogin,
          // ).centered().py12(),
        ],
      ),
    ).py20();
  }
}
