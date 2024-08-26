import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/constants/app_routes.dart';
import 'package:driver/requests/settings.request.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class OnboardingViewModel extends MyBaseViewModel {
  OnboardingViewModel(BuildContext context, this.finishLoading) {
    viewContext = context;
  }

  final Function finishLoading;

  List<PageModel> onBoardData = [];

  initialise() {
    final bgColor = viewContext.theme.colorScheme.background;
    final textColor =
        Utils.textColorByColor(viewContext.theme.colorScheme.background);

    onBoardData = [
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding1,
        title: "Delivery made easy".tr(),
        body: "Get notified as soon as an order is available for delivery".tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding2,
        title: "Chat with vendor/customer".tr(),
        body:
            "Call/Chat with vendor/delivery boy for update about your order and more"
                .tr(),
        doAnimateImage: true,
      ),
      PageModel(
        color: bgColor,
        titleColor: textColor,
        bodyColor: textColor,
        imageAssetPath: AppImages.onboarding3,
        title: "Earning".tr(),
        body: "You get commissions from every delivery made".tr(),
        doAnimateImage: true,
      ),
    ];
    //
    loadOnboardingData();
  }

  loadOnboardingData() async {
    setBusy(true);
    try {
      final apiResponse = await SettingsRequest().appOnboardings();
      //load the data
      //[
      //     {
      //         "id": 4,
      //         "in_order": 4,
      //         "type": "driver",
      //         "is_active": 1,
      //         "created_at": "2022-08-15 14:35:14",
      //         "updated_at": "2023-12-12 12:19:28",
      //         "formatted_date_time": "15 Aug 2022 at 02:35 pm",
      //         "formatted_date": "15 Aug 2022",
      //         "formatted_updated_date": "12 Dec 2023",
      //     },
      //     {
      //         "id": 5,
      //         "in_order": 5,
      //         "type": "driver",
      //         "is_active": 1,
      //         "created_at": "2022-08-15 14:35:35",
      //         "updated_at": "2023-12-12 12:19:20",
      //         "formatted_date_time": "15 Aug 2022 at 02:35 pm",
      //         "formatted_date": "15 Aug 2022",
      //         "formatted_updated_date": "12 Dec 2023",
      //     },
      //     {
      //         "id": 6,
      //         "in_order": 6,
      //         "type": "driver",
      //         "is_active": 1,
      //         "created_at": "2022-08-15 14:35:58",
      //         "updated_at": "2023-12-12 12:19:20",
      //         "formatted_date_time": "15 Aug 2022 at 02:35 pm",
      //         "formatted_date": "15 Aug 2022",
      //         "formatted_updated_date": "12 Dec 2023",
      //     }
      // ]
      if (apiResponse.allGood) {
        List<PageModel> mOnBoardDatas = [];
        dynamic intros = apiResponse.body;
        if (intros is List) {
          for (var e in intros) {
            mOnBoardDatas.add(PageModel.withChild(
              child: VStack(
                [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: CustomImage(
                      imageUrl: "${e['photo']}",
                      //width: viewContext.percentWidth * 50,
                      //height: viewContext.percentWidth * 50,
                      width: 200,
                      height: 200,
                      boxFit: BoxFit.cover,
                    ).centered(),
                  ),
                  "${e["title"] ?? ""}".text.xl3.bold.make(),
                  UiSpacer.vSpace(5),
                  "${e["description"] ?? ""}".text.lg.hairLine.make(),
                ],
              ).p20(),
              color: Colors.white,
              doAnimateChild: true,
            ));
          }
        }
        /*final mOnBoardDatas = (apiResponse.body as List).map(
          (e) {
            print(e);
            return PageModel.withChild(
              child: VStack(
                [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: CustomImage(
                      imageUrl: "${e['photo']}",
                      width: viewContext.percentWidth * 50,
                      height: viewContext.percentWidth * 50,
                      boxFit: BoxFit.cover,
                    ).centered(),
                  ),
                  "${e["title"] ?? ""}".text.xl3.bold.make(),
                  UiSpacer.vSpace(5),
                  "${e["description"] ?? ""}".text.lg.hairLine.make(),
                ],
              ).p20(),
              color: viewContext.theme.colorScheme.background,
              doAnimateChild: true,
            );
          },
        ).toList();*/
        if (mOnBoardDatas.isNotEmpty) {
          onBoardData = mOnBoardDatas;
        }
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      print(error);
      toastError("$error");
    }
    setBusy(false);
    finishLoading();
  }

  void onDonePressed() async {
    //
    await AuthServices.firstTimeCompleted();
    Navigator.of(viewContext).pushNamedAndRemoveUntil(
      AppRoutes.loginRoute,
      (route) => false,
    );
  }
}
