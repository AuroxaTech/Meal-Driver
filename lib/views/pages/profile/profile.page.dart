import 'package:flutter/material.dart';
import 'package:driver/view_models/profile.vm.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:driver/widgets/cards/profile.card.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_routes.dart';
import '../../../constants/app_text_styles.dart';
import '../../../utils/size_utils.dart';
import '../order/orders.page.dart';
import '../shift/shifts.page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfigs().init(context);
    return Scaffold(
      body: StatefulBuilder(builder:
          (BuildContext context, void Function(void Function()) newState) {
        return ViewModelBuilder<ProfileViewModel>.reactive(
          viewModelBuilder: () => ProfileViewModel(context),
          onViewModelReady: (model) => model.initialise(),
          builder: (context, model, child) {
            return SafeArea(
              child: BasePage(
                body: Column(
                  children: [
                    //profile card
                    Stack(
                      children: [
                        ProfileCard(model).pOnly(top: 30),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.only(top: 7, right: 7),
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              AppImages.logout,
                              height: getWidth(45),
                              width: getWidth(45),
                            ),
                          ).onInkTap(() {
                            model.logoutPressed();
                          }),
                        ),
                      ],
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        child: GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(5),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: model.items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Number of columns
                            crossAxisSpacing: 20.0, // Spacing between columns
                            mainAxisSpacing: 25.0, // Spacing between rows
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () async {
                                if (index == 0) {
                                  context.nextPage(const OrdersPage());
                                } else if (index == 1) {
                                } else if (index == 2) {
                                  context.nextPage(const ShiftsPage());
                                } else if (index == 3) {
                                  model.openSettings(model);
                                } else if (index == 4) {
                                  openDialog(context).then((value) {
                                    if (value.isNotEmpty) {
                                      model.vehicleImage = value;
                                      newState(() {});
                                    }
                                  });
                                } else if (index == 5) {
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.bankAccountDetailsRoute,
                                  );
                                } else if (index == 6) {
                                } else if (index == 7) {
                                } else if (index == 8) {
                                } else {}
                                //                       //
                                //                       MenuItem(
                                //                         title: "Notifications".tr(),
                                //                         onPressed: model.openNotification,
                                //                       ),
                                //
                                //                       //
                                //                       MenuItem(
                                //                         title: "Rate & Review".tr(),
                                //                         onPressed: model.openReviewApp,
                                //                       ),
                                //
                                //                       MenuItem(
                                //                         title: "Faqs".tr(),
                                //                         onPressed: model.openFaqs,
                                //                       ),
                                //
                                //                       //
                                //                       MenuItem(
                                //                         title: "Version".tr(),
                                //                         suffix: model.appVersionInfo.text.make(),
                                //                       ),
                                //
                                //                       //
                                //                       MenuItem(
                                //                         title: "Privacy Policy".tr(),
                                //                         onPressed: model.openPrivacyPolicy,
                                //                       ),
                                //                       //
                                //                       MenuItem(
                                //                         title: "Terms & Conditions".tr(),
                                //                         onPressed: model.openTerms,
                                //                       ),
                                //                       //
                                //                       MenuItem(
                                //                         title: "Contact Us".tr(),
                                //                         onPressed: model.openContactUs,
                                //                       ),
                                //                       MenuItem(
                                //                         title: "Live support".tr(),
                                //                         onPressed: model.openLivesupport,
                                //                       ),
                                //                       //
                                //                       MenuItem(
                                //                         title: "Language".tr(),
                                //                         divider: false,
                                //                         suffix: Icon(
                                //                           FlutterIcons.language_ent,
                                //                         ),
                                //                         onPressed: model.changeLanguage,
                                //                       ),
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(2),
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      SizeConfigs.screenWidth! / 3),
                                  border: Border.all(
                                      width: 2, color: AppColor.appMainColor),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        offset: const Offset(0, 3),
                                        blurRadius: 1,
                                        spreadRadius: 1)
                                  ],
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      index == 4
                                          ? Image.asset(
                                              model.vehicleImage,
                                              fit: BoxFit.cover,
                                              width: 70,
                                              height: 60,
                                            )
                                          : Image.asset(
                                              model.items[index]['image'],
                                              fit: BoxFit.cover,
                                              width: 70,
                                              height: 60,
                                            ),
                                      Text(model.items[index]["text"],
                                          textAlign: TextAlign.center,
                                          style: AppTextStyle
                                              .comicNeue18BoldTextStyle(
                                                  color:
                                                      AppColor.appMainColor)),
                                    ]),
                              ),
                            );
                          },
                        ).pOnly(bottom: 5),
                      ),
                    ),

                    Container(
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        color: Colors.white,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              AppImages.swipeArrowsLeft,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ).onInkTap(() {
                              Navigator.pop(context);
                            }),
                            Image.asset(
                              AppImages.flagIcon,
                              fit: BoxFit.cover,
                              width: 65,
                              height: 65,
                            ).onInkTap(() {}),
                          ],
                        ).px8(),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<String> openDialog(BuildContext context) async {
    String result = "";
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            width: SizeConfigs.screenWidth!,
            height: getShortestSide(200),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 2, color: AppColor.appMainColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  width: (MediaQuery.sizeOf(context).width) / 2.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        AppImages.carYellow,
                        width: getWidth(55),
                      ),
                      Text('Car',
                              style: AppTextStyle.comicNeue25BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                    ],
                  ),
                ).pOnly(right: 5).onInkTap(() {
                  Navigator.pop(context);
                  result = AppImages.carYellow;
                }),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  width: (MediaQuery.sizeOf(context).width) / 2.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        AppImages.bicycle,
                        width: getWidth(55),
                      ),
                      Text('Bike',
                              style: AppTextStyle.comicNeue25BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                    ],
                  ),
                ).onInkTap(() {
                  Navigator.pop(context);
                  result = AppImages.bicycle;
                }),
              ],
            ),
          ),
        );
      },
    );
    return result;
  }
}
