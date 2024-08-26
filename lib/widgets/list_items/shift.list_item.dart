import 'package:flutter/material.dart';
import 'package:driver/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../models/shift.dart';

class ShiftListItem extends StatelessWidget {
  const ShiftListItem({
    required this.title,
    required this.shifts,
    this.onPayPressed,
    required this.orderPressed,
    super.key,
  });

  final String title;
  final List<Shift> shifts;
  final Function? onPayPressed;
  final Function(Shift shift) orderPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: title.text.xl2.bold.color(AppColor.primaryColor).make()),
        ...shifts.map<Widget>((shift) {
          Color color = shift.shiftRequestStatus == 0
              ? Colors.red
              : shift.shiftRequestStatus == 1
                  ? Colors.green
                  : shift.shiftRequestStatus == 2
                      ? Colors.amber
                      : AppColor.primaryColor;
          String infoText = shift.shiftRequestStatus == 0
              ? "Request Rejected"
              : shift.shiftRequestStatus == 1
                  ? "Request Accepted"
                  : shift.shiftRequestStatus == 2
                      ? "Request Pending"
                      : "Accept Shift";
          return Row(
            children: [
              "${shift.startAt} - ${shift.endAt}"
                  .text
                  .xl
                  .bold
                  .color(color)
                  .make()
                  .expand(),
              if (shift.shiftRequestStatus == -1)
                infoText.text.lg.color(color).bold.make(),
            ],
          )
              .onInkTap(() => orderPressed.call(shift))
              .box
              .clip(Clip.antiAlias)
              .padding(const EdgeInsets.all(10))
              .margin(const EdgeInsets.only(bottom: 10.0))
              .border(color: color, width: 2.5)
              .color(Colors.white)
              .withRounded()
              .make();
        }),
      ],
    );
  }
}
