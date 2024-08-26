import 'package:flutter/material.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class LoadingError extends StatelessWidget {
  const LoadingError({
    this.onRefresh,
    super.key,
  });

  final Function? onRefresh;
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      imageUrl: AppImages.error,
      showAction: true,
      actionPressed: onRefresh,
      actionText: "Retry".tr(),
      title: "An error occurred".tr(),
      description:
          "There was an error while processing your request. Please try again"
              .tr(),
    ).p20();
  }
}
