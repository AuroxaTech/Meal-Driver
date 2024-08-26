import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:custom_faqs/custom_faqs.dart';
import 'package:flutter/material.dart';
import 'package:driver/views/pages/payment_account/payment_account.page.dart';
import 'package:driver/views/pages/profile/account_delete.page.dart';
import 'package:driver/views/pages/splash.page.dart';
import 'package:driver/widgets/bottomsheets/earning.bottomsheet.dart';
import 'package:driver/constants/api.dart';
import 'package:driver/constants/app_routes.dart';
import 'package:driver/constants/app_strings.dart';
import 'package:driver/models/user.dart';
import 'package:driver/requests/auth.request.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:driver/widgets/cards/language_selector.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:package_info/package_info.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/app_images.dart';

class ProfileViewModel extends MyBaseViewModel {
  //
  String appVersionInfo = "";
  String vehicleImage = AppImages.carYellow;
  User? currentUser;
  final List<Map<String, dynamic>> items = [
    {"image": AppImages.money, "text": "Earnings"},
    {"image": AppImages.percent, "text": "Promos"},
    {"image": AppImages.objectives, "text": "Schedule"},
    {"image": AppImages.trial, "text": "Settings"},
    {"image": AppImages.carYellow, "text": "Vehicle"},
    {"image": AppImages.creditCard, "text": "Payments"},
    {"image": AppImages.helpDesk, "text": "Help"},
    {"image": AppImages.transaction, "text": "Referral"},
    {"image": AppImages.book, "text": "About"},
    // Add more items as needed
  ];

  //
  final AuthRequest _authRequest = AuthRequest();

  ProfileViewModel(BuildContext context) {
    viewContext = context;
  }

  void initialise() async {
    //

    setBusy(true);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    appVersionInfo = "$versionName($versionCode)";
    currentUser = await AuthServices.getCurrentUser(force: true);
    setBusy(false);
  }

  /**
   * Edit Profile
   */

  openEditProfile() async {
    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.editProfileRoute,
    );

    if (result != null && result is bool && result) {
      initialise();
    }
  }

  /**
   * Change Password
   */

  openChangePassword() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.changePasswordRoute,
    );
  }

  openSettings(ProfileViewModel model) async {
    Navigator.of(viewContext)
        .pushNamed(AppRoutes.settingPageRoute, arguments: model);
  }

  /**
   * Delivery addresses
   */
  openDeliveryAddresses() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.deliveryAddressesRoute,
    );
  }

  //
  openFavourites() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.favouritesRoute,
    );
  }

  //Earning
  showEarning() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const EarningBottomSheet();
      },
    );
  }

  /**
   * Logout
   */
  logoutPressed() async {
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Logout".tr(),
      text: "Are you sure you want to logout?".tr(),
      onConfirmBtnTap: () {
        Navigator.pop(viewContext);
        processLogout();
        notifyListeners();
      },
    );
  }

  void processLogout() async {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.loading,
      title: "Logout".tr(),
      text: "Logging out Please wait...".tr(),
      barrierDismissible: false,
    );

    //
    final apiResponse = await _authRequest.logoutRequest();

    //
    Navigator.pop(viewContext);

    if (!apiResponse.allGood) {
      //
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Logout",
        text: apiResponse.message,
      );
    } else {
      //
      await AuthServices.logout();
      Navigator.of(viewContext).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SplashPage()),
        (route) => false,
      );
    }
    notifyListeners();
  }

  openWallet() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.walletRoute,
    );
  }

  openPaymentAccounts() async {
    Navigator.push(
        viewContext,
        MaterialPageRoute(
          builder: (context) => PaymentAccountPage(),
        ));
  }

  openNotification() async {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.notificationsRoute,
    );
  }

  /**
   * App Rating & Review
   */
  openReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (Platform.isAndroid) {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    } else if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      inAppReview.openStoreListing(appStoreId: AppStrings.appStoreId);
    }
  }

  openFaqs() {
    viewContext.nextPage(
      CustomFaqPage(
        title: 'Faqs'.tr(),
        link: Api.baseUrl + Api.faqs,
      ),
    );
  }

  //
  openPrivacyPolicy() async {
    final url = Api.privacyPolicy;
    openWebpageLink(url);
  }

  openTerms() {
    final url = Api.terms;
    openWebpageLink(url);
  }

  //
  openContactUs() async {
    final url = Api.contactUs;
    openWebpageLink(url);
  }

  openLivesupport() async {
    final url = Api.inappSupport;
    openWebpageLink(url);
  }

  //
  changeLanguage() async {
    showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return const AppLanguageSelector();
      },
    );
  }

  deleteAccount() {
    viewContext.nextPage(const AccountDeletePage());
  }
}
