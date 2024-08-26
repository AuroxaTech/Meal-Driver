//import 'package:firestore_chat/firestore_chat.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/app_routes.dart';
import 'package:driver/models/notification.dart';
import 'package:driver/models/order.dart';
import 'package:driver/views/pages/auth/forgot_password.page.dart';
import 'package:driver/views/pages/auth/login.page.dart';
import 'package:driver/views/pages/shared/home.page.dart';
import 'package:driver/views/pages/notification/notification_details.page.dart';
import 'package:driver/views/pages/notification/notifications.page.dart';
import 'package:driver/views/pages/onboarding.page.dart';
import 'package:driver/views/pages/order/orders_details.page.dart';
import 'package:driver/views/pages/profile/change_password.page.dart';
import 'package:driver/views/pages/profile/edit_profile.page.dart';
import 'package:driver/views/pages/wallet/wallet.page.dart';

import '../view_models/profile.vm.dart';
import '../views/pages/profile/bank_account_details.page.dart';
import '../views/pages/profile/settings.page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.welcomeRoute:
      return MaterialPageRoute(builder: (context) => const OnboardingPage());

    case AppRoutes.loginRoute:
      return MaterialPageRoute(builder: (context) => const LoginPage());

    case AppRoutes.forgotPasswordRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());

    case AppRoutes.homeRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.homeRoute, arguments: Map()),
        builder: (context) => const HomePage(),
        // Directionality(
        //   textDirection: TextDirection.rtl,
        //   child: HomePage(),
        // ),
      );

    //order details page
    case AppRoutes.orderDetailsRoute:
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.orderDetailsRoute),
        builder: (context) => OrderDetailsPage(
          order: settings.arguments as Order,
        ),
      );
    //chat page
    case AppRoutes.chatRoute:
      return FirestoreChat().chatPageWidget(
        settings.arguments as ChatEntity,
      );

    //
    case AppRoutes.editProfileRoute:
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.editProfileRoute),
        builder: (context) => const EditProfilePage(),
      );
    //change password
    case AppRoutes.changePasswordRoute:
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.changePasswordRoute),
        builder: (context) => const ChangePasswordPage(),
      );

    //profile settings/actions
    case AppRoutes.notificationsRoute:
      return MaterialPageRoute(
        settings:
            RouteSettings(name: AppRoutes.notificationsRoute, arguments: Map()),
        builder: (context) => const NotificationsPage(),
      );

    //profile settings/actions
    case AppRoutes.settingPageRoute:
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.settingPageRoute),
        builder: (context) => SettingPage(
          profileViewModel: settings.arguments as ProfileViewModel,
        ),
      );

    //wallets
    case AppRoutes.walletRoute:
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.walletRoute),
        builder: (context) => const WalletPage(),
      );

    //
    case AppRoutes.notificationDetailsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(
            name: AppRoutes.notificationDetailsRoute, arguments: Map()),
        builder: (context) => NotificationDetailsPage(
          notification: settings.arguments as NotificationModel,
        ),
      );

    //change password
    case AppRoutes.bankAccountDetailsRoute:
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.bankAccountDetailsRoute),
        builder: (context) => const BankAccountDetailsPage(),
      );
    default:
      return MaterialPageRoute(builder: (context) => const OnboardingPage());
  }
}
