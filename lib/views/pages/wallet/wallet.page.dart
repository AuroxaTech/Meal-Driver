import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/view_models/wallet.vm.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:driver/widgets/custom_list_view.dart';
import 'package:driver/widgets/list_items/wallet_transaction.list_item.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'earning.page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with WidgetsBindingObserver {
  //
  WalletViewModel? vm;

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
      vm?.getWalletBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    vm ??= WalletViewModel(context);

    //
    return BasePage(
      title: "Wallet".tr(),
      showLeadingAction: true,
      showAppBar: false,
      body: ViewModelBuilder<WalletViewModel>.reactive(
        viewModelBuilder: () => vm!,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack(
            [
              20.heightBox,
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
              CustomListView(
                refreshController: vm.refreshController,
                canPullUp: true,
                canRefresh: true,
                isLoading: vm.busy(vm.walletTransactions),
                onRefresh: vm.getWalletTransactions,
                onLoading: () =>
                    vm.getWalletTransactions(initialLoading: false),
                dataSet: vm.walletTransactions,
                itemBuilder: (context, index) {
                  return WalletTransactionListItem(
                      vm.walletTransactions[index]);
                },
              ).expand(),
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
                        ? BusyIndicator().py12()
                        : "${AppStrings.currencySymbol} ${vm.wallet?.balance}"
                            .text
                            .bold
                            .color(AppColor.primaryColor)
                            .size(30)
                            .make(),
                  ]),
                  8.heightBox,
                  HStack([
                    "KM travelled"
                        .tr()
                        .text
                        .bold
                        .color(AppColor.primaryColor)
                        .size(30)
                        .make()
                        .expand(),
                    vm.isBusy
                        ? BusyIndicator().py12()
                        : "3.8km"
                            .text
                            .bold
                            .color(AppColor.primaryColor)
                            .size(30)
                            .make(),
                  ]),
                ],
              )
                  .p12()
                  .box
                  .withRounded()
                  .border(color: AppColor.primaryColor, width: 2)
                  .make()
                  .onTap(() {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EarningPage()));
              }).wFull(context),
            ],
          ).p20();
        },
      ),
    );
  }
}
