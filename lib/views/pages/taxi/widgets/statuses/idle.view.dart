import 'package:flutter/material.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/view_models/taxi/taxi.vm.dart';
import 'package:driver/views/pages/taxi/widgets/online_status_swipe.btn.dart';
import 'package:driver/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

class IdleTaxiView extends StatelessWidget {
  const IdleTaxiView(this.taxiViewModel, {super.key});

  final TaxiViewModel taxiViewModel;

  @override
  Widget build(BuildContext context) {
    final driverVehicle = AuthServices.driverVehicle;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: MeasureSize(
        onChange: (size) {
          taxiViewModel.taxiGoogleMapManagerService
              ?.updateGoogleMapPadding(size.height + 10);
        },
        child: VStack(
          [
            Visibility(
              visible: taxiViewModel.appService.driverIsOnline,
              child: VStack(
                [
                  const LinearProgressIndicator(
                    minHeight: 4,
                  ).wFull(context),
                  "Searching for order"
                      .tr()
                      .text
                      .extraBold
                      .sm
                      .makeCentered()
                      .p8(),
                ],
              ),
            ),

            //Online/offline button
            OnlineStatusSwipeButton(taxiViewModel),

            // Driver's vehicle info, only if it's available
            if (driverVehicle != null) ...[
              VStack(
                [
                  "Vehicle Type".tr().text.light.make(),
                  HStack(
                    [
                      CustomImage(
                          imageUrl: driverVehicle.vehicleType.photo ?? '')
                          .wh(32, 32),
                      UiSpacer.hSpace(5),
                      driverVehicle.vehicleType.name
                          .text
                          .xl
                          .semiBold
                          .make()
                          .expand(),
                    ],
                  ),
                  UiSpacer.vSpace(),
                  "Vehicle Details".tr().text.thin.make(),
                  HStack(
                    [
                      "${driverVehicle.carModel?.carMake?.name ?? 'Unknown'} (${driverVehicle.carModel?.name ?? 'Unknown'}) - ${driverVehicle.regNo ?? 'Unknown'} - ${driverVehicle.color?.toUpperCase() ?? 'Unknown'}"
                          .text
                          .xl
                          .semiBold
                          .make()
                          .expand(),
                    ],
                  ),
                ],
              ).p20(),
            ] else
            // Display a message when the driver vehicle info is not available
              "Vehicle information is not available"
                  .tr()
                  .text
                  .light
                  .makeCentered(),
          ],
        )
            .box
            .color(context.theme.colorScheme.surface)
            .shadow2xl
            .outerShadow
            .make(),
      ),
    );
  }
}
