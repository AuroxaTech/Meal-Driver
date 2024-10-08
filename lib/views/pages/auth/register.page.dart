import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:driver/constants/api.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_page_settings.dart';
import 'package:driver/models/vehicle.dart';
import 'package:driver/services/custom_form_builder_validator.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/view_models/register.view_model.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/buttons/custom_button.dart';
import 'package:driver/widgets/cards/custom.visibility.dart';
import 'package:driver/widgets/cards/document_selection.view.dart';
import 'package:driver/widgets/custom_type_ahead_field.input.dart';
import 'package:driver/widgets/states/custom_loading.state.dart';

import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    //
    const inputDec = InputDecoration(
      border: OutlineInputBorder(),
    );

    //
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          isLoading: vm.isBusy,
          body: FormBuilder(
            key: vm.formBuilderKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: VStack(
              [
                //appbar
                SafeArea(
                  child: HStack(
                    [
                      Icon(
                        FlutterIcons.close_ant,
                        size: 24,
                        color: Utils.textColorByTheme(),
                      ).p8().onInkTap(() {
                        Navigator.pop(context);
                      }).p12(),
                    ],
                  ),
                ).box.color(AppColor.primaryColor).make().wFull(context),

                //
                VStack(
                  [
                    //
                    VStack(
                      [
                        "Become a partner"
                            .tr()
                            .text
                            .xl3
                            .color(Utils.textColorByTheme())
                            .bold
                            .make(),
                        "Fill form below to continue"
                            .tr()
                            .text
                            .light
                            .color(Utils.textColorByTheme())
                            .make(),
                      ],
                    )
                        .p20()
                        .box
                        .color(AppColor.primaryColor)
                        .make()
                        .wFull(context),

                    //form
                    VStack(
                      [
                        //
                        FormBuilderTextField(
                          name: "name",
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Name".tr(),
                          ),
                        ),

                        FormBuilderTextField(
                          name: "email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              CustomFormBuilderValidator.compose(
                            [
                              CustomFormBuilderValidator.required(value),
                              CustomFormBuilderValidator.email(value),
                            ],
                          ),
                          decoration: inputDec.copyWith(
                            labelText: "Email".tr(),
                          ),
                        ).py20(),

                        FormBuilderTextField(
                          name: "phone",
                          keyboardType: TextInputType.phone,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Phone".tr(),
                            prefixIcon: HStack(
                              [
                                //icon/flag
                                Flag.fromString(
                                  vm.selectedCountry.countryCode,
                                  width: 20,
                                  height: 20,
                                ),
                                UiSpacer.horizontalSpace(space: 5),
                                //text
                                ("+${vm.selectedCountry.phoneCode}")
                                    .text
                                    .make(),
                              ],
                            ).px8().onInkTap(vm.showCountryDialPicker),
                          ),
                        ),

                        FormBuilderTextField(
                          name: "password",
                          obscureText: vm.hidePassword,
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Password".tr(),
                            suffixIcon: Icon(
                              vm.hidePassword
                                  ? FlutterIcons.ios_eye_ion
                                  : FlutterIcons.ios_eye_off_ion,
                            ).onInkTap(() {
                              vm.hidePassword = !vm.hidePassword;
                              vm.notifyListeners();
                            }),
                          ),
                        ).py20(),

                        FormBuilderTextField(
                          name: "referal_code",
                          decoration: inputDec.copyWith(
                            labelText: "Referral Code".tr(),
                          ),
                        ),

                        UiSpacer.divider().py20(),
                        //
                        FormBuilderDropdown(
                          name: 'driver_type',
                          decoration: inputDec.copyWith(
                            labelText: "Driver Type".tr(),
                            hintText: 'Select Driver Type'.tr(),
                          ),
                          validator: CustomFormBuilderValidator.required,
                          items: vm.types
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type.toLowerCase(),
                                  child: type.tr().text.make(),
                                ),
                              )
                              .toList(),
                          onChanged: vm.onSelectedDriverType,
                        ),

                        //vehicle details
                        CustomVisibility(
                          visible: vm.selectedDriverType == "taxi",
                          child: VStack(
                            [
                              UiSpacer.divider().py8(),
                              "Vehicle Details"
                                  .tr()
                                  .text
                                  .semiBold
                                  .xl
                                  .make()
                                  .py12(),
                              UiSpacer.vSpace(10),
                              CustomLoadingStateView(
                                loading: vm.busy(vm.carMakes),
                                child: CustomTypeAheadField<CarMake>(
                                  textEditingController: vm.carMakeTEC,
                                  title: "Car Make".tr(),
                                  items: vm.carMakes,
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.name),
                                    );
                                  },
                                  suggestionsCallback: (value) async {
                                    return vm.carMakes
                                        .where(
                                          (e) => e.name
                                              .toLowerCase()
                                              .contains(value.toLowerCase()),
                                        )
                                        .toList();
                                  },
                                  onSuggestionSelected: vm.onCarMakeSelected,
                                ),
                              ),
                              CustomLoadingStateView(
                                loading: vm.busy(vm.carModels),
                                child: CustomTypeAheadField<CarModel>(
                                  textEditingController: vm.carModelTEC,
                                  title: "Car Model".tr(),
                                  items: vm.carModels,
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      title: Text(suggestion.name),
                                    );
                                  },
                                  suggestionsCallback: (value) async {
                                    return vm.carModels
                                        .where(
                                          (e) => e.name
                                              .toLowerCase()
                                              .contains(value.toLowerCase()),
                                        )
                                        .toList();
                                  },
                                  onSuggestionSelected: vm.onCarModelSelected,
                                ).py20(),
                              ),

                              //
                              CustomLoadingStateView(
                                loading: vm.busy(vm.vehicleTypes),
                                child: FormBuilderDropdown(
                                  name: 'vehicle_type_id',
                                  decoration: inputDec.copyWith(
                                    labelText: "Vehicle Type".tr(),
                                    hintText: 'Select Vehicle Type'.tr(),
                                  ),
                                  validator:
                                      CustomFormBuilderValidator.required,
                                  items: vm.vehicleTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type.id,
                                          child: type.name.text.make(),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),

                              //
                              FormBuilderTextField(
                                name: "reg_no",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  labelText: "Registration Number".tr(),
                                ),
                              ).py20(),
                              FormBuilderTextField(
                                name: "color",
                                validator: CustomFormBuilderValidator.required,
                                decoration: inputDec.copyWith(
                                  labelText: "Color".tr(),
                                ),
                              ),
                              10.heightBox,
                              UiSpacer.divider(),
                            ],
                          ),
                        ),

                        //business documents
                        DocumentSelectionView(
                          title: "Documents".tr(),
                          instruction:
                              AppPageSettings.driverDocumentInstructions,
                          max: AppPageSettings.maxDriverDocumentCount,
                          onSelected: vm.onDocumentsSelected,
                        ).py(12),

                        UiSpacer.divider(),

                        FormBuilderCheckbox(
                          name: "agreed",
                          title: "I agree with"
                              .tr()
                              .richText
                              .semiBold
                              .withTextSpanChildren(
                            [
                              " ".textSpan.make(),
                              "terms and conditions"
                                  .tr()
                                  .textSpan
                                  .underline
                                  .semiBold
                                  .tap(() {
                                    vm.openWebpageLink(Api.terms);
                                  })
                                  .color(AppColor.primaryColor)
                                  .make(),
                            ],
                          ).make(),
                          validator: (value) =>
                              CustomFormBuilderValidator.required(
                            value,
                            errorTitle:
                                "Please confirm you have accepted our terms and conditions"
                                    .tr(),
                          ),
                        ),
                        //
                        CustomButton(
                          title: "Sign Up".tr(),
                          loading: vm.isBusy,
                          onPressed: vm.processRegister,
                        ).centered().py20(),
                      ],
                    ).p20(),
                  ],
                )
                    .wFull(context)
                    .scrollVertical()
                    .box
                    .color(context.cardColor)
                    .make()
                    .pOnly(
                      bottom: context.mq.viewInsets.bottom,
                    )
                    .expand(),
              ],
            ),
          ),
        );
      },
    );
  }
}
