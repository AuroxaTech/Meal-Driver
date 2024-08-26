import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/models/user.dart';
import 'package:driver/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../utils/size_utils.dart';
import '../../../view_models/profile.vm.dart';
import '../../../view_models/setting.vm.dart';
import '../../../widgets/busy_indicator.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key, required this.profileViewModel});

  final ProfileViewModel profileViewModel;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SettingViewModel>.reactive(
      viewModelBuilder: () => SettingViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: false,
          body: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return SafeArea(
                  top: true,
                  bottom: false,
                  child: VStack(
                    [
                      Stack(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.backArrowSign,
                                  fit: BoxFit.contain,
                                  width: 50,
                                  height: 30,
                                ).onInkTap(() => Navigator.pop(context)),
                                Text("Settings",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle
                                            .comicNeue30BoldTextStyle(
                                                color: AppColor.appMainColor))
                                    .px12(),
                              ]),
                          Positioned(
                            left: 0,
                            top: 50,
                            child: Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: AppColor.appMainColor,
                                  borderRadius: BorderRadius.circular(
                                      getShortestSide(35))),
                              child: Text("Account",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.comicNeue18BoldTextStyle(
                                      color: Colors.white)),
                            ).h(40),
                          ),
                          Positioned(
                              right: 10,
                              top: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: AppColor.appMainColor,
                                          borderRadius: BorderRadius.circular(
                                              getShortestSide(200)),
                                          border: Border.all(
                                              width: 2,
                                              color: AppColor.appMainColor)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            getShortestSide(200)),
                                        child: CachedNetworkImage(
                                          imageUrl: profileViewModel
                                                  .currentUser?.photo ??
                                              "",
                                          errorWidget: (context, imageUrl, _) =>
                                              Image.asset(
                                            AppImages.user,
                                            fit: BoxFit.cover,
                                          ),
                                          width: getShortestSide(200),
                                          height: getShortestSide(200),
                                          fit: BoxFit.cover,
                                          progressIndicatorBuilder: (context,
                                                  imageURL, progress) =>
                                              const BusyIndicator().centered(),
                                        ),
                                      )),
                                  Text(profileViewModel.currentUser!.name,
                                      style:
                                          AppTextStyle.comicNeue18BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ],
                              ))
                        ],
                      ).h(128).px12().py8(),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text("Documents",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).h(70),
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text("Payment",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).h(70).onTap(model.openBankAccountDetails)
                              ],
                            ).py(20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text("Tax Info",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).onInkTap(() async {
                                  model.taxInfo = await openTaxInfoDialog(
                                      context, model.taxInfo);
                                  newState(() {});
                                }).h(70),
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text("Address",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).h(70)
                              ],
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text("Name/Email\nNumber",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).onInkTap(() {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DialogUserForm(
                                          profileViewModel.currentUser);
                                    },
                                  );
                                }).h(90),
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text("Change\nPassword",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).h(90).onTap(() {
                                  model.openChangePassword();
                                })
                              ],
                            ),
                            FittedBox(
                              child: Container(
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    color: AppColor.appMainColor,
                                    borderRadius: BorderRadius.circular(
                                        getShortestSide(35))),
                                child: Text("Device",
                                    textAlign: TextAlign.center,
                                    style:
                                        AppTextStyle.comicNeue18BoldTextStyle(
                                            color: Colors.white)),
                              ).h(40).py12(),
                            ).py20(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text(
                                      "Navigation:\n${model.navigationOption}",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).onInkTap(() async {
                                  model.navigationOption =
                                      await openNavigationDialog(
                                          context,
                                          model.navigationOption,
                                          model.navigationLabels);
                                  newState(() {});
                                }).h(90),
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text(
                                      "Location:\n${model.locationOption}",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).h(90).onInkTap(() async {
                                  model.locationOption =
                                      await openLocationDialog(
                                          context,
                                          model.locationOption,
                                          model.locationLabels);
                                  newState(() {});
                                })
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Text(
                                      "Night Mode:\n${model.nightModeOption}",
                                      textAlign: TextAlign.center,
                                      style:
                                          AppTextStyle.comicNeue25BoldTextStyle(
                                              color: AppColor.appMainColor)),
                                ).onInkTap(() async {
                                  model.nightModeOption =
                                      await openNightModeDialog(
                                          context,
                                          model.nightModeOption,
                                          model.nightModeLabels);
                                  newState(() {});
                                }).h(90),
                                Container(
                                  alignment: Alignment.center,
                                  width: SizeConfigs.screenWidth! / 2.4,
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          getShortestSide(30)),
                                      border: Border.all(
                                          width: 2,
                                          color: AppColor.appMainColor)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Sound:${model.soundValue}',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyle
                                              .comicNeue25BoldTextStyle(
                                                  color:
                                                      AppColor.appMainColor)),
                                      Text('Vibration:${model.vibrationValue}',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyle
                                              .comicNeue25BoldTextStyle(
                                                  color:
                                                      AppColor.appMainColor)),
                                    ],
                                  ),
                                ).h(90).onInkTap(() async {
                                  model = await openDialog(context, model);
                                  newState(() {});
                                })
                              ],
                            ).py20(),
                            Container(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment.center,
                                width: SizeConfigs.screenWidth! / 2.4,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        getShortestSide(30)),
                                    border: Border.all(
                                        width: 2,
                                        color: AppColor.appMainColor)),
                                child: Text(
                                    "Communication:\n${model.communicationOption}",
                                    textAlign: TextAlign.center,
                                    style:
                                        AppTextStyle.comicNeue25BoldTextStyle(
                                            color: AppColor.appMainColor)),
                              ).h(90).w(SizeConfigs.screenWidth! / 1.5),
                            ).onInkTap(() async {
                              model.communicationOption =
                                  await openCommunicationDialog(
                                      context,
                                      model.communicationOption,
                                      model.communicationLabels);
                              newState(() {});
                            }).pOnly(bottom: 10),
                          ],
                        ).p20(),
                      )),
                    ],
                  ));
            },
          ),
        );
      },
    );
  }

  Future<SettingViewModel> openDialog(
      BuildContext context, SettingViewModel model) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return Container(
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
                          border: Border.all(
                              width: 2, color: AppColor.appMainColor)),
                      width: (MediaQuery.sizeOf(context).width) / 2.3,
                      child: Text('Sound:${model.soundValue}',
                              style: AppTextStyle.comicNeue20BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                    ).pOnly(right: 5).onInkTap(() {
                      if (model.soundValue == "ON") {
                        model.soundValue = "OFF";
                      } else {
                        model.soundValue = "ON";
                      }
                      newState(() {});
                    }),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 2, color: AppColor.appMainColor)),
                      width: (MediaQuery.sizeOf(context).width) / 2.3,
                      child: Text('Vibration:${model.vibrationValue}',
                              style: AppTextStyle.comicNeue20BoldTextStyle(
                                  color: AppColor.appMainColor))
                          .p4(),
                    ).onInkTap(() {
                      if (model.vibrationValue == "ON") {
                        model.vibrationValue = "OFF";
                      } else {
                        model.vibrationValue = "ON";
                      }
                      newState(() {});
                      newState(() {});
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    return model;
  }

  Future<String> openNavigationDialog(
      BuildContext context, String selectedOption, List<String> label) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
                  alignment: Alignment.center,
                  height: 140,
                  width: SizeConfigs.screenWidth! -
                      (SizeConfigs.screenWidth! / 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppColor.appMainColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 2, color: AppColor.appMainColor)),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.clear, // Specify the icon you want to use
                            color: Colors.white,
                            // Set the color you want for the icon
                            size: 20, // Set the size of the icon
                          ),
                        ).onInkTap(() {
                          Navigator.pop(context);
                        }),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: label.length,
                          shrinkWrap: false,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: SizeConfigs.screenWidth! / 2.5,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      width: label[index] == selectedOption
                                          ? 4
                                          : 2,
                                      color: AppColor.appMainColor)),
                              child: Text(label[index],
                                  style: AppTextStyle.comicNeue20BoldTextStyle(
                                      color: AppColor.appMainColor)),
                            ).p2().onInkTap(() {
                              selectedOption = label[index];
                              print(
                                  'selectedOption is===============$selectedOption');
                              newState(() {});
                            }).pOnly(right: 5);
                          },
                        ),
                      ).pOnly(left: 5),

                      // SizedBox(
                      //   height: 30.0 * label.length,
                      //   child: ListView.builder(
                      //     itemCount: label.length,
                      //     itemBuilder: (context, index) {
                      //       return CustomRadioPage(
                      //         size: 15.0,
                      //         activeColor: AppColor.appMainColor,
                      //         value: label[index],
                      //         groupValue: selectedOption,
                      //         onChanged: (value) {
                      //           newState((){
                      //             selectedOption = '$value';
                      //           });
                      //         },
                      //         label: label[index],
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ));
            },
          ),
        );
      },
    );
    return selectedOption;
  }

  Future<String> openNightModeDialog(
      BuildContext context, String selectedOption, List<String> label) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
                  alignment: Alignment.center,
                  height: 140,
                  width: SizeConfigs.screenWidth! / 1.01,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppColor.appMainColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 2, color: AppColor.appMainColor)),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.clear, // Specify the icon you want to use
                            color: Colors.white,
                            // Set the color you want for the icon
                            size: 20, // Set the size of the icon
                          ),
                        ).onInkTap(() {
                          Navigator.pop(context);
                        }),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: label.length,
                          shrinkWrap: false,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: SizeConfigs.screenWidth! / 4,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      width: label[index] == selectedOption
                                          ? 4
                                          : 2,
                                      color: AppColor.appMainColor)),
                              child: Text(label[index],
                                  style: AppTextStyle.comicNeue20BoldTextStyle(
                                      color: AppColor.appMainColor)),
                            ).p2().onInkTap(() {
                              selectedOption = label[index];
                              print(
                                  'selectedOption is===============$selectedOption');
                              newState(() {});
                            }).pOnly(right: 5);
                          },
                        ),
                      ).pOnly(left: 5),

                      // SizedBox(
                      //   height: 30.0 * label.length,
                      //   child: ListView.builder(
                      //     itemCount: label.length,
                      //     itemBuilder: (context, index) {
                      //       return CustomRadioPage(
                      //         size: 15.0,
                      //         activeColor: AppColor.appMainColor,
                      //         value: label[index],
                      //         groupValue: selectedOption,
                      //         onChanged: (value) {
                      //           newState((){
                      //             selectedOption = '$value';
                      //           });
                      //         },
                      //         label: label[index],
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ));
            },
          ),
        );
      },
    );

    return selectedOption;
  }

  Future<String> openCommunicationDialog(
      BuildContext context, String selectedOption, List<String> label) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
                  alignment: Alignment.center,
                  height: 140,
                  width: SizeConfigs.screenWidth! -
                      (SizeConfigs.screenWidth! / 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppColor.appMainColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 2, color: AppColor.appMainColor)),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.clear, // Specify the icon you want to use
                            color: Colors.white,
                            // Set the color you want for the icon
                            size: 20, // Set the size of the icon
                          ),
                        ).onInkTap(() {
                          Navigator.pop(context);
                        }),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: label.length,
                          shrinkWrap: false,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: SizeConfigs.screenWidth! / 2.5,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      width: label[index] == selectedOption
                                          ? 4
                                          : 2,
                                      color: AppColor.appMainColor)),
                              child: Text(label[index],
                                  style: AppTextStyle.comicNeue20BoldTextStyle(
                                      color: AppColor.appMainColor)),
                            ).p2().onInkTap(() {
                              selectedOption = label[index];
                              print(
                                  'selectedOption is===============$selectedOption');
                              newState(() {});
                            }).pOnly(right: 5);
                          },
                        ),
                      ).pOnly(left: 5),

                      // SizedBox(
                      //   height: 30.0 * label.length,
                      //   child: ListView.builder(
                      //     itemCount: label.length,
                      //     itemBuilder: (context, index) {
                      //       return CustomRadioPage(
                      //         size: 15.0,
                      //         activeColor: AppColor.appMainColor,
                      //         value: label[index],
                      //         groupValue: selectedOption,
                      //         onChanged: (value) {
                      //           newState((){
                      //             selectedOption = '$value';
                      //           });
                      //         },
                      //         label: label[index],
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ));
            },
          ),
        );
      },
    );

    return selectedOption;
  }

  Future<String> openLocationDialog(
      BuildContext context, String selectedOption, List<String> label) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) newState) {
              return Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 8),
                  alignment: Alignment.center,
                  height: 140,
                  width: SizeConfigs.screenWidth! -
                      (SizeConfigs.screenWidth! / 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 2, color: AppColor.appMainColor)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppColor.appMainColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 2, color: AppColor.appMainColor)),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(5),
                          child: const Icon(
                            Icons.clear, // Specify the icon you want to use
                            color: Colors.white,
                            // Set the color you want for the icon
                            size: 20, // Set the size of the icon
                          ),
                        ).onInkTap(() {
                          Navigator.pop(context);
                        }),
                      ),
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: ListView.builder(
                          itemCount: label.length,
                          shrinkWrap: false,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: SizeConfigs.screenWidth! / 4,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      width: label[index] == selectedOption
                                          ? 4
                                          : 2,
                                      color: AppColor.appMainColor)),
                              child: Text(label[index],
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.comicNeue20BoldTextStyle(
                                      color: AppColor.appMainColor)),
                            ).p2().onInkTap(() {
                              selectedOption = label[index];
                              print(
                                  'selectedOption is===============$selectedOption');
                              newState(() {});
                            }).pOnly(right: 5);
                          },
                        ),
                      ).pOnly(left: 5),

                      // SizedBox(
                      //   height: 30.0 * label.length,
                      //   child: ListView.builder(
                      //     itemCount: label.length,
                      //     itemBuilder: (context, index) {
                      //       return CustomRadioPage(
                      //         size: 15.0,
                      //         activeColor: AppColor.appMainColor,
                      //         value: label[index],
                      //         groupValue: selectedOption,
                      //         onChanged: (value) {
                      //           newState((){
                      //             selectedOption = '$value';
                      //           });
                      //         },
                      //         label: label[index],
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ));
            },
          ),
        );
      },
    );

    return selectedOption;
  }

  Future<String> openTaxInfoDialog(BuildContext context, String taxInfo) async {
    String hintText = 'Please enter SIN number ...';
    bool isEnable = taxInfo.isEmpty ? true : false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) newState) {
                return Container(
                  width: MediaQuery.sizeOf(context).width - 20,
                  //height: MediaQuery.sizeOf(context).longestSide /4,
                  padding: const EdgeInsets.fromLTRB(10, 15, 5, 15),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(width: 4, color: AppColor.appMainColor)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text('TaxInfo:',
                            style: AppTextStyle.comicNeue25BoldTextStyle(
                                color: AppColor.appMainColor)),
                      ).px8().py4(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              width: 2, color: AppColor.appMainColor),
                        ),
                        child: TextFormField(
                          maxLength: 9,
                          style: AppTextStyle.comicNeue20BoldTextStyle(
                              color: AppColor.appMainColor),
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: AppTextStyle.comicNeue20BoldTextStyle(
                                color: AppColor.appMainColor),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLines: 1,
                          onChanged: (value) {
                            newState(() {});
                            if (value.isEmpty) {
                              hintText = 'Please enter SIN number ...';
                            } else if (value.length == 9) {}
                          },
                          keyboardType: TextInputType.number,
                          onTap: () {
                            hintText = '';
                            newState(() {});
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter SIN number';
                            } else if (value.length < 9) {
                              return 'Please enter exactly 9 digits';
                            } else if (value.length > 9) {
                              return 'Please enter only 9 digits';
                            }
                            return null;
                          },
                        ),
                      ).px8(),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.sizeOf(context).width / 2,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: AppColor.appMainColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                width: 2, color: AppColor.appMainColor),
                          ),
                          child: Text('Submit',
                                  style: AppTextStyle.comicNeue25BoldTextStyle(
                                      color: Colors.white))
                              .p8(),
                        ).px8().onInkTap(() {
                          Navigator.of(context).pop();
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
    return taxInfo;
  }
}

class DialogUserForm extends StatefulWidget {
  const DialogUserForm(this.currentUser, {super.key});

  final User? currentUser;

  @override
  State<DialogUserForm> createState() => _DialogFormState();
}

class _DialogFormState extends State<DialogUserForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        height: 340,
        width: SizeConfigs.screenWidth! - (SizeConfigs.screenWidth! / 6),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(width: 2, color: AppColor.appMainColor)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('Name : ${widget.currentUser!.name}',
                    style: AppTextStyle.comicNeue20BoldTextStyle(
                        color: AppColor.appMainColor)),
              ).px8().py4(),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('Email : ${widget.currentUser!.email}',
                    style: AppTextStyle.comicNeue20BoldTextStyle(
                        color: AppColor.appMainColor)),
              ).px8().py4(),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                          decoration: BoxDecoration(
                              color: AppColor.appMainColor,
                              borderRadius:
                                  BorderRadius.circular(getShortestSide(230)),
                              border: Border.all(
                                  width: 2, color: AppColor.appMainColor)),
                          child: _image != null
                              ? CircleAvatar(
                                  radius: getShortestSide(117),
                                  // Set the radius based on the desired width/height
                                  backgroundImage: FileImage(
                                      _image!), // Use FileImage to load the image from file
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.currentUser?.photo ?? "",
                                  errorWidget: (context, imageUrl, _) =>
                                      Image.asset(
                                    AppImages.user,
                                    fit: BoxFit.cover,
                                  ),
                                  width: getShortestSide(230),
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, imageURL, progress) =>
                                          const BusyIndicator().centered(),
                                ))
                      .py4(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                        color: AppColor.appMainColor,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(width: 2, color: AppColor.appMainColor)),
                    child: Text('Upload',
                        style: AppTextStyle.comicNeue18BoldTextStyle(
                            color: Colors.white)),
                  ).onInkTap(() {
                    getImage();
                  }).pOnly(left: 15, bottom: 15),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(width: 2, color: AppColor.appMainColor)),
                    child: Text('Cancel',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.comicNeue20BoldTextStyle(
                            color: AppColor.appMainColor)),
                  ).onInkTap(() {
                    Navigator.of(context).pop();
                  }).expand(),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(width: 2, color: AppColor.appMainColor)),
                    child: Text('Submit',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.comicNeue20BoldTextStyle(
                            color: AppColor.appMainColor)),
                  ).onInkTap(() {
                    // You can perform your submission logic here
                    String name = _nameController.text;
                    String number = _numberController.text;
                    String email = _emailController.text;
                    // Use these variables for your submission
                    // After submission, close the dialog
                    Navigator.of(context).pop();
                  }).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
