import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:driver/constants/app_ui_settings.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/view_models/profile.vm.dart';
import 'package:driver/views/pages/order/orders.page.dart';
import 'package:driver/views/pages/profile/finance.page.dart';
import 'package:driver/views/pages/profile/legal.page.dart';
import 'package:driver/views/pages/profile/support.page.dart';
import 'package:driver/views/pages/profile/widget/document_request.view.dart';
import 'package:driver/views/pages/profile/widget/driver_type.switch.dart';
import 'package:driver/views/pages/vehicle/vehicles.page.dart';
import 'package:driver/widgets/cards/profile.card.dart';
import 'package:driver/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeMenuView extends StatelessWidget {
  const HomeMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Stack(
          children: [
            VStack(
              [
                //profile card
                ProfileCard(model),
                12.heightBox,

                //if driver switch is enabled
                const DriverTypeSwitch(),
                //document verification
                const DocumentRequestView(),
                Visibility(
                  visible: AppUISettings.enableDriverTypeSwitch ||
                      model.currentUser!.isTaxiDriver,
                  child: MenuItem(
                    title: "Vehicle Details".tr(),
                    onPressed: () {
                      context.nextPage(const VehiclesPage());
                    },
                    topDivider: true,
                  ),
                ),
                //
                // orders
                MenuItem(
                  title: "Orders".tr(),
                  onPressed: () {
                    context.nextPage(const OrdersPage());
                  },
                ),

                MenuItem(
                  title: "Finance".tr(),
                  onPressed: () {
                    context.nextPage(const FinancePage());
                  },
                ),

                //menu
                VStack(
                  [
                    //
                    MenuItem(
                      title: "Notifications".tr(),
                      onPressed: model.openNotification,
                    ),

                    //
                    MenuItem(
                      title: "Rate & Review".tr(),
                      onPressed: model.openReviewApp,
                    ),

                    MenuItem(
                      title: "Faqs".tr(),
                      onPressed: model.openFaqs,
                    ),

                    //
                    MenuItem(
                      title: "Legal".tr(),
                      onPressed: () {
                        context.nextPage(const LegalPage());
                      },
                    ),
                    MenuItem(
                      title: "Support".tr(),
                      onPressed: () {
                        context.nextPage(SupportPage());
                      },
                    ),

                    //
                    MenuItem(
                      title: "Language".tr(),
                      divider: false,
                      suffix: const Icon(
                        FlutterIcons.language_ent,
                      ),
                      onPressed: model.changeLanguage,
                    ),
                  ],
                ),

                //
                MenuItem(
                  onPressed: model.logoutPressed,
                  divider: false,
                  suffix: const Icon(
                    FlutterIcons.logout_ant,
                    size: 16,
                  ),
                  child: "Logout".tr().text.red500.make(),
                ),

                UiSpacer.vSpace(15),

                //
                ("${"Version".tr()} - ${model.appVersionInfo}")
                    .text
                    .center
                    .sm
                    .makeCentered()
                    .py20(),
              ],
            )
                .p(18)
                .scrollVertical()
                .hFull(context)
                .box
                .color(context.colors.background)
                .topRounded(value: 20)
                .make()
                .pOnly(top: 20),

            //close
            IconButton(
              icon: const Icon(
                FlutterIcons.close_ant,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ).box.roundedFull.red500.make().positioned(top: 0, right: 20),
          ],
        );
      },
    );
  }
}
