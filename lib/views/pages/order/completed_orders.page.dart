import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_colors.dart';
import '../../../utils/ui_spacer.dart';
import '../../../view_models/completed_orders.vm.dart';
import '../../../widgets/base.page.dart';
import '../../../widgets/custom_list_view.dart';
import '../../../widgets/list_items/order.list_item.dart';
import '../../../widgets/states/error.state.dart';
import '../../../widgets/states/order.empty.dart';

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage>
    with AutomaticKeepAliveClientMixin<CompletedOrdersPage> {
  @override
  Widget build(BuildContext context) {
    //
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<CompletedOrdersViewModel>.reactive(
        viewModelBuilder: () => CompletedOrdersViewModel(),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {

          return BasePage(
            showAppBar: true,
            showLeadingAction: true,
            title: "Earnings",
            body: VStack(
              [
                10.heightBox,
                //online status
                /*Row(
                  children: [
                    Expanded(
                        child: 'Completed Orders'
                            .text
                            .color(AppColor.primaryColor)
                            .size(37)
                            .bold
                            .make()),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: AppColor.primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(15)),
                      child: '\$${vm.total.toStringAsFixed(2)}'
                          .text
                          .color(AppColor.primaryColor)
                          .size(28)
                          .make(),
                    )
                  ],
                ),*/
                // .centered().safeArea(),
                UiSpacer.vSpace(),
                CustomListView(
                  canRefresh: true,
                  canPullUp: true,
                  refreshController: vm.refreshController,
                  onRefresh: vm.fetchOrders,
                  onLoading: () => vm.fetchOrders(initialLoading: false),
                  isLoading: vm.isBusy,
                  dataSet: vm.orders,
                  hasError: vm.hasError,
                  errorWidget: LoadingError(
                    onRefresh: vm.fetchOrders,
                  ),
                  emptyWidget: VStack(
                    [
                      EmptyOrder(
                        title: "Assigned Orders".tr(),
                      ),
                    ],
                  ),
                  itemBuilder: (context, index) {
                    final order = vm.orders[index];
                    String date =
                        DateFormat("EEEE dd/MM/yyyy").format(order.createdAt);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.showDateHeader)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "${vm.dateTotals[date]?.day} (${vm.dateTotals[date]?.count} Orders)",
                                    style: TextStyle(
                                      color: AppColor.primaryColor,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: AppColor.primaryColor,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  child:
                                      '\$${vm.dateTotals[date]?.total.toStringAsFixed(2)}'
                                          .text
                                          .color(AppColor.primaryColor)
                                          .size(24)
                                          .make(),
                                ),
                              ],
                            ),
                          ),
                        OrderListItem(
                          order: order,
                          orderPressed: () => vm.openOrderDetails(order),
                        ),
                      ],
                    );
                  },
                ).expand(),
              ],
            ).px20(),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
