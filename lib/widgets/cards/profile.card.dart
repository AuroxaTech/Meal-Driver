import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/app_images.dart';
import 'package:driver/view_models/profile.vm.dart';
import 'package:driver/views/pages/profile/manage_account.page.dart';
import 'package:driver/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/size_utils.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {super.key});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          //profile card
          (model.isBusy)
              ? const BusyIndicator().centered().p20()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: AppColor.appMainColor,
                            borderRadius:
                                BorderRadius.circular(getShortestSide(230)),
                            border: Border.all(
                                width: 2, color: AppColor.appMainColor)),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(getShortestSide(230)),
                          child: CachedNetworkImage(
                            imageUrl: model.currentUser!.photo,
                            errorWidget: (context, imageUrl, _) => Image.asset(
                              AppImages.user,
                              fit: BoxFit.cover,
                            ),
                            width: getShortestSide(230),
                            height: getShortestSide(230),
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, imageURL, progress) =>
                                    const BusyIndicator().centered(),
                          ),
                        )).py4(),
                    Text(model.currentUser!.name,
                        style: AppTextStyle.comicNeue30BoldTextStyle(
                            color: AppColor.appMainColor)),
                  ],
                ).px20().p8().onTap(() {
                  context.nextPage(const ManageAccountPage());
                }),
    ).wFull(context);
  }
}
