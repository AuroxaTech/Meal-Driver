import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/utils/utils.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:velocity_x/velocity_x.dart';

class BasePage extends StatefulWidget {
  final bool showAppBar;
  final bool showLeadingAction;
  final bool showCart;
  final Function? onBackPressed;
  final String? title;
  final Widget body;
  final Widget? bottomSheet;
  final Widget? fab;
  final bool isLoading;
  final bool extendBodyBehindAppBar;
  final double? elevation;
  final Color? appBarItemColor;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Widget? leading;

  const BasePage({
    this.showAppBar = false,
    this.showLeadingAction = false,
    this.leading,
    this.showCart = false,
    this.onBackPressed,
    this.title = "",
    required this.body,
    this.bottomSheet,
    this.fab,
    this.isLoading = false,
    this.appBarColor,
    this.elevation,
    this.extendBodyBehindAppBar = false,
    this.appBarItemColor,
    this.backgroundColor,
    super.key,
  });

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: LocalizeAndTranslate.getLocale().languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.background,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        appBar: widget.showAppBar
            ? AppBar(
                backgroundColor: widget.appBarColor ?? context.primaryColor,
                automaticallyImplyLeading: widget.showLeadingAction,
                elevation: widget.elevation,
                leading: widget.showLeadingAction
                    ? widget.leading ??
                        IconButton(
                          icon: Icon(
                            !Utils.isArabic
                                ? FlutterIcons.arrow_left_fea
                                : FlutterIcons.arrow_right_fea,
                          ),
                          onPressed: (widget.onBackPressed != null)
                              ? () => widget.onBackPressed!()
                              : () => Navigator.pop(context),
                        )
                    : null,
                title: Text(
                  "${widget.title}",
                ),
              )
            : null,
        body: VStack(
          [
            //
            widget.isLoading
                ? LinearProgressIndicator()
                : UiSpacer.emptySpace(),

            //
            widget.body.expand(),
          ],
        ),
        bottomSheet: widget.bottomSheet,
        floatingActionButton: widget.fab,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
