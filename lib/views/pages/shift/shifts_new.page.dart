import 'package:flutter/material.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/states/error.state.dart';
import 'package:driver/widgets/states/order.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_colors.dart';
import '../../../models/shift.dart';
import '../../../view_models/shifts.vm.dart';
import '../../../widgets/custom_map_list_view.dart';
import '../../../widgets/list_items/shift.list_item.dart';

class ShiftsPage extends StatefulWidget {
  const ShiftsPage({super.key});

  @override
  State<ShiftsPage> createState() => _ShiftsPageState();
}

class _ShiftsPageState extends State<ShiftsPage>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<ShiftsPage>,
        WidgetsBindingObserver {
  ShiftsViewModel? vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm?.fetchShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ViewModelBuilder<ShiftsViewModel>.reactive(
        viewModelBuilder: () => ShiftsViewModel(
              context,
              tickerProvider: this,
            ),
        onViewModelReady: (model) {
          vm = model;
          model.tabBarController = TabController(
              length: model.menus.length, vsync: this, initialIndex: 0);

          model.tabBarController?.addListener(model.handleTabChange);
          model.fetchShifts();
        },
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Shifts"),
              bottom: TabBar(
                indicatorColor: Colors.transparent,
                indicator: const BoxDecoration(color: Colors.transparent),
                onTap: (int index) {
                  setState(() {
                    setState(() {
                      model.selectedTabName = model.menus[index];
                    });
                  });
                },
                isScrollable: true,
                labelPadding: const EdgeInsets.all(10),
                controller: model.tabBarController,
                tabAlignment: TabAlignment.start,
                tabs: model.menus.map(
                  (menu) {
                    return model.selectedTabName == menu
                        ? Tab(
                            child: menu.text.xl2
                                .color(AppColor.primaryColor)
                                .make()
                                .py2()
                                .px8()
                                .box
                                .border(color: AppColor.primaryColor, width: 2)
                                .roundedLg
                                .make(),
                          )
                        : Tab(
                            child: menu.text.xl2
                                .color(AppColor.primaryColor)
                                .make()
                                .py2(),
                          );
                  },
                ).toList(),
              ),
            ),
            backgroundColor: Colors.grey.shade200,
            body: ViewModelBuilder<ShiftsViewModel>.reactive(
              viewModelBuilder: () => model,
              onViewModelReady: (vm) => vm.initialise(),
              builder: (context, vm, child) {
                return CustomMapListView(
                  canRefresh: true,
                  canPullUp: true,
                  //refreshController: vm.refreshController,
                  onRefresh: vm.fetchShifts,
                  onLoading: () => vm.fetchShifts(initialLoading: false),
                  isLoading: vm.isBusy,
                  dataSet: vm.shifts,
                  hasError: vm.hasError,
                  padding: const EdgeInsets.all(20),
                  errorWidget: LoadingError(
                    onRefresh: vm.fetchShifts,
                  ),
                  //
                  emptyWidget: const EmptyOrder(),
                  itemBuilder: (context, index) {
                    String title = vm.shifts.keys.toList()[index];
                    List<Shift> shifts = vm.shifts[title] ?? [];
                    return ShiftListItem(
                      title: title,
                      shifts: shifts,
                      orderPressed: (Shift shift) => vm.onShiftClick(shift),
                    );
                  },
                  separatorBuilder: (context, index) => UiSpacer.vSpace(10),
                );
              },
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
