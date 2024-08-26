import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/models/order.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/view_models/order_details.vm.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    required this.order,
    super.key,
  });

  //
  final Order order;

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: ViewModelBuilder<OrderDetailsViewModel>.reactive(
        viewModelBuilder: () => OrderDetailsViewModel(context, order),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          print("Transit Fee =====> ${vm.earnings.toStringAsFixed(2)}");
          return BasePage(
            title: "Order Details".tr(),
            showAppBar: false,
            showLeadingAction: true,
            onBackPressed: vm.onBackPressed,
            isLoading: vm.isBusy,
            body: vm.isBusy
                ? const BusyIndicator().centered()
                : VStack([
                    30.heightBox,
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'assets/images/close.png',
                        height: 45,
                        width: 45,
                      ),
                    ).onTap(() {
                      Navigator.pop(context);
                    }),
                    //'Wallet'.text.color(AppColor.primaryColor).bold.size(37).make(),
                    //
                    //top-up
                    // CustomButton(
                    //   loading: vm.isBusy,
                    //   title: "Top-Up Wallet".tr(),
                    //   onPressed: vm.showAmountEntry,
                    // ).py12().wFull(context),
                    //transactions list
                    //"Wallet Transactions".tr().text.bold.xl2.make().py12(),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "1. ${order.vendor?.name}"
                            .text
                            .bold
                            .color(AppColor.primaryColor)
                            .size(30)
                            .make(),
                        "#${order.code}"
                            .text
                            .bold
                            .color(AppColor.primaryColor)
                            .size(30)
                            .make(),
                      ],
                    ),
                    50.heightBox,
                    Column(
                      children: [
                        HStack([
                          "Transit fee:"
                              .tr()
                              .text
                              .bold
                              .color(AppColor.primaryColor)
                              .size(30)
                              .make()
                              .expand(),
                          vm.isBusy
                              ? const BusyIndicator().py12()
                              : "\$${vm.earnings.toStringAsFixed(2)}"
                                  .text
                                  .bold
                                  .color(AppColor.primaryColor)
                                  .size(30)
                                  .make(),
                        ]),
                        HStack([
                          "Tip"
                              .tr()
                              .text
                              .bold
                              .color(AppColor.primaryColor)
                              .size(30)
                              .make()
                              .expand(),
                          vm.isBusy
                              ? const BusyIndicator().py12()
                              : "\$${(order.tip ?? 0).toStringAsFixed(2)}"
                                  .text
                                  .bold
                                  .color(AppColor.primaryColor)
                                  .size(30)
                                  .make(),
                        ]),
                      ],
                    ).scrollVertical().expand(),

                    VStack(
                      [
                        //
                        HStack([
                          "Total Earning:"
                              .tr()
                              .text
                              .bold
                              .color(AppColor.primaryColor)
                              .size(30)
                              .make()
                              .expand(),
                          vm.isBusy
                              ? const BusyIndicator().py12()
                              : "${AppStrings.currencySymbol}${(vm.earnings + (order.tip ?? 0)).toStringAsFixed(2)}"
                                  .text
                                  .bold
                                  .color(AppColor.primaryColor)
                                  .size(30)
                                  .make(),
                        ]),
                        8.heightBox,

                        ValueListenableBuilder(
                          builder: (BuildContext context, double value,
                              Widget? child) {
                            return HStack([
                              "KM travelled"
                                  .tr()
                                  .text
                                  .bold
                                  .color(AppColor.primaryColor)
                                  .size(30)
                                  .make()
                                  .expand(),
                              vm.isBusy
                                  ? const BusyIndicator().py12()
                                  : "${(order.distance ?? 0 + value).toInt()} km"
                                      .text
                                      .bold
                                      .color(AppColor.primaryColor)
                                      .size(30)
                                      .make(),
                            ]);
                          },
                          valueListenable: order.pickupDistance,
                        ),
                      ],
                    )
                        .p12()
                        .box
                        .withRounded()
                        .border(color: AppColor.primaryColor, width: 2)
                        .make()
                        .wFull(context),
                  ]).pOnly(left: 16, right: 16, bottom: 16),

            //
            // bottomSheet: OrderActions(
            //   order: vm.order,
            //   canChatCustomer: vm.order.canChatCustomer,
            //   busy: vm.isBusy || vm.busy(vm.order),
            //   processOrderCompletion: vm.initiateOrderCompletion,
            //   processOrderEnroute: vm.processOrderEnroute,
            // ),
          );
        },
      ),
    );
  }
}
