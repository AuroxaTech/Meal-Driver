import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/view_models/assigned_orders.vm.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/custom_list_view.dart';
import 'package:driver/widgets/list_items/order.list_item.dart';
import 'package:driver/widgets/states/error.state.dart';
import 'package:driver/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class AssignedOrdersPage extends StatefulWidget {
  const AssignedOrdersPage({super.key});

  @override
  State<AssignedOrdersPage> createState() => _AssignedOrdersPageState();
}

class _AssignedOrdersPageState extends State<AssignedOrdersPage>
    with AutomaticKeepAliveClientMixin<AssignedOrdersPage> {
  @override
  Widget build(BuildContext context) {
    //
    super.build(context);
    return SafeArea(
      child: ViewModelBuilder<AssignedOrdersViewModel>.reactive(
        viewModelBuilder: () => AssignedOrdersViewModel(),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return BasePage(
            body: VStack(
              [
                10.heightBox,
                //online status
                Row(
                  children: [
                    Expanded(
                        child: 'Today’s Orders'
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
                ),
                // .centered().safeArea(),
                UiSpacer.vSpace(),
                //
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
                  //
                  emptyWidget: VStack(
                    [
                      EmptyOrder(
                        title: "Assigned Orders".tr(),
                      ),
                    ],
                  ),
                  itemBuilder: (context, index) {
                    //
                    final order = vm.orders[index];
                    return OrderListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
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
