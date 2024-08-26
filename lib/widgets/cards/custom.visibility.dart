import 'package:flutter/material.dart';
import 'package:driver/utils/ui_spacer.dart';

class CustomVisibility extends StatelessWidget {
  const CustomVisibility({required this.child, this.visible = true, super.key});

  final Widget child;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return visible ? child : UiSpacer.emptySpace();
  }
}
