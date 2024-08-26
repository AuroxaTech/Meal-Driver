import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:driver/constants/app_languages.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/utils/utils.dart';
import 'package:driver/widgets/custom_grid_view.dart';

import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class AppLanguageSelector extends StatelessWidget {
  const AppLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: VStack(
        [
          //
          "Select your preferred language"
              .tr()
              .text
              .xl
              .semiBold
              .make()
              .py20()
              .px12(),
          UiSpacer.divider(),

          //
          CustomGridView(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.all(12),
            dataSet: AppLanguages.codes,
            itemBuilder: (ctx, index) {
              return VStack(
                [
                  //
                  Flag.fromString(
                    AppLanguages.flags[index],
                    height: 40,
                    width: 40,
                  ),
                  UiSpacer.verticalSpace(space: 5),
                  //
                  AppLanguages.names[index].text.lg.make(),
                ],
                crossAlignment: CrossAxisAlignment.center,
                alignment: MainAxisAlignment.center,
              )
                  .onTap(() {
                    _onSelected(context, AppLanguages.codes[index]);
                  })
                  .box
                  .roundedSM
                  .color(context.canvasColor)
                  .make();
            },
          ).expand(),
          // VStack(
          //   [
          //     ...(AppLanguages.codes.mapIndexed((code, index) {
          //       return MenuItem(
          //         title: AppLanguages.names[index],
          //         suffix: Flag.fromString(
          //           AppLanguages.flags[index],
          //           height: 24,
          //           width: 24,
          //         ),
          //         onPressed: () => _onSelected(context, code),
          //       );
          //     }).toList()),
          //   ],
          // ).scrollVertical().expand(),
        ],
      ),
    ).hThreeForth(context);
  }

  void _onSelected(BuildContext context, String code) async {
    await AuthServices.setLocale(code);
    await Utils.setJiffyLocale();
    //
    await LocalizeAndTranslate.setLanguageCode(code);
    //
    Navigator.pop(context);
  }
}
