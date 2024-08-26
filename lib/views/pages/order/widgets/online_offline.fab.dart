import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/view_models/home.vm.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OnlineOfflineFab extends StatelessWidget {
  const OnlineOfflineFab({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<HomeViewModelOld>.reactive(
      viewModelBuilder: () => HomeViewModelOld(context),
      onViewModelReady: (homeVm) => homeVm.initialise(),
      builder: (context, homeVm, child) {
        return Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColor.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(15)),
          child: !homeVm.isBusy
              ? (AppService().driverIsOnline ? "Online" : "Offline")
                  .tr()
                  .text
                  .color(AppColor.primaryColor)
                  .size(28)
                  .make()
              : CircularProgressIndicator(),
        ).onTap(homeVm.toggleOnlineStatus);
        // FloatingActionButton.extended(
        //     icon: Icon(
        //       !AppService().driverIsOnline
        //           ? FlutterIcons.location_off_mdi
        //           : FlutterIcons.location_on_mdi,
        //       color: Colors.white,
        //     ),
        //     label: (AppService().driverIsOnline
        //             ? "You are Online"
        //             : "You are Offline")
        //         .tr()
        //         .text
        //         .white
        //         .make(),
        //     backgroundColor:
        //         (AppService().driverIsOnline ? Colors.green : Colors.red),
        //     onPressed: homeVm.toggleOnlineStatus,
        //   );
      },
    );
  }
}
