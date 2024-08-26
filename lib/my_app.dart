import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:driver/constants/app_theme.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/views/pages/splash.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'constants/app_strings.dart';
import 'package:driver/services/router.service.dart' as router;
import 'package:flutter/services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.primaryColor,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.light,
    ));*/

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    return AdaptiveTheme(
      light: AppTheme().lightTheme(),
      dark: AppTheme().darkTheme(),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp(
          navigatorKey: AppService().navigatorKey,
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          onGenerateRoute: router.generateRoute,
          // initialRoute: _startRoute,
          localizationsDelegates: LocalizeAndTranslate.delegates,
          locale: LocalizeAndTranslate.getLocale(),
          supportedLocales: LocalizeAndTranslate.getLocals(),
          home: const SplashPage(),
          theme: theme,
          darkTheme: darkTheme,
        );
      },
    );
  }
}
