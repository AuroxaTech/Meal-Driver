import 'dart:async';
import 'dart:io';

import 'package:awesome_drawer_bar/awesome_drawer_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:driver/constants/app_upgrade_settings.dart';
import 'package:driver/views/pages/taxi/taxi_order.page.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../view_models/taxi/taxi.vm.dart';
import 'widgets/home_menu.view.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final awesomeDrawerBarController = AwesomeDrawerBarController();

  bool canCloseApp = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        if (!canCloseApp) {
          canCloseApp = true;
          Timer(const Duration(seconds: 1), () {
            canCloseApp = false;
          });
          Fluttertoast.showToast(
            msg: "Press back again to close".tr(),
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: const Color(0xAA000000),
            textColor: Colors.white,
            fontSize: 14.0,
          );
          return false;
        }
        return true;
      },
      child: ViewModelBuilder<TaxiViewModel>.reactive(
        viewModelBuilder: () => TaxiViewModel(context),
        onViewModelReady: (vm) {
          vm.initialise();
        },
        builder: (context, vm, child) {
          return UpgradeAlert(
            showIgnore: !AppUpgradeSettings.forceUpgrade(),
            shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
            dialogStyle: Platform.isIOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            child: Stack(
              children: [
                vm.currentUser == null
                    ? const BusyIndicator().centered()
                    : const TaxiOrderPage(),
              ],
            ),
          );
        },
      ),
    );
  }

  void openMenuBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const HomeMenuView().h(context.percentHeight * 90);
      },
    );
  }
}
