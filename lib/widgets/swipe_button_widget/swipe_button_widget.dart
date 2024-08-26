import 'package:flutter/material.dart';

class SwipeButtonWidget extends StatefulWidget {
  /// AcceptPointTransition from 0 to 1
  ///
  /// rightChildren & leftChildren is Stack
  const SwipeButtonWidget({
    super.key,
    this.childBeforeSwipe = const Icon(Icons.arrow_forward_ios),
    this.childAfterSwiped = const Icon(Icons.arrow_back_ios),
    this.height,
    this.width,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(0),
    this.colorBeforeSwipe = Colors.green,
    this.colorAfterSwiped = Colors.red,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black54,
        blurRadius: 6,
        offset: Offset(0, 4),
      ),
    ],
    this.borderRadius,
    this.duration = const Duration(milliseconds: 50),
    this.constraints,
    this.rightChildren = const [],
    this.leftChildren = const [],
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragRight,
    required this.onHorizontalDragLeft,
    this.acceptPointTransition = 0.5,
  }) : assert(acceptPointTransition <= 1 && acceptPointTransition >= 0);
  final Widget childBeforeSwipe, childAfterSwiped;
  final double? height, width;
  final EdgeInsetsGeometry margin, padding;
  final Color? colorBeforeSwipe, colorAfterSwiped;
  final List<BoxShadow> boxShadow;
  final BorderRadiusGeometry? borderRadius;
  final Duration duration;
  final BoxConstraints? constraints;
  final List<Widget> rightChildren;
  final List<Widget> leftChildren;
  final double acceptPointTransition;
  final void Function(DragUpdateDetails details) onHorizontalDragUpdate;
  final Future<bool> Function(DragEndDetails details) onHorizontalDragRight;
  final Future<bool> Function(DragEndDetails details) onHorizontalDragLeft;

  @override
  State<SwipeButtonWidget> createState() => _SwipeButtonWidgetStateful();
}

class _SwipeButtonWidgetStateful extends State<SwipeButtonWidget> {
  double xOffset = 0;
  double fullWidth = 0;

  double get startPoint => 0;

  double get widthWithoutSwapButton =>
      fullWidth == 0 ? 1 : fullWidth - sizeSwapButton.value.width;

  bool get isLeftSide => percentage <= widget.acceptPointTransition;

  bool get isRightSide => !isLeftSide;
  double previousPosition = 0;

  /// From 0 to 1
  double get percentage => xOffset / widthWithoutSwapButton;
  ValueNotifier<Size> sizeSwapButton = ValueNotifier<Size>(const Size(0, 0));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.height,
      width: widget.width,
      constraints: widget.constraints,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: isLeftSide ? widget.colorBeforeSwipe : widget.colorAfterSwiped,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        fullWidth = constraints.maxWidth;
        return Stack(
          children: [
            ...isLeftSide ? widget.leftChildren : widget.rightChildren,
            AnimatedContainer(
              duration: widget.duration,
              transform: Matrix4.translationValues(xOffset, 0, 0),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onHorizontalDragUpdate: (e) {
                  if (e.globalPosition.dx <= widthWithoutSwapButton) {
                    xOffset = e.globalPosition.dx;
                    widget.onHorizontalDragUpdate(e);
                    setState(() {});
                  }
                },
                onHorizontalDragEnd: (e) async {
                  bool isActive = false;
                  if (isLeftSide) {
                    if (previousPosition != startPoint) {
                      isActive = await widget.onHorizontalDragLeft(e);
                      isActive ? moveToLeft() : moveToRight();
                    } else {
                      moveToLeft();
                    }
                  } else {
                    if (previousPosition != widthWithoutSwapButton) {
                      isActive = await widget.onHorizontalDragRight(e);
                      isActive ? moveToRight() : moveToLeft();
                    } else {
                      moveToRight();
                    }
                  }
                  previousPosition = xOffset;
                  setState(() {});
                },
                child: SizeTrackingWidget(
                  sizeValueNotifier: sizeSwapButton,
                  child: isLeftSide
                      ? widget.childBeforeSwipe
                      : widget.childAfterSwiped,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void moveToRight() {
    xOffset = fullWidth - sizeSwapButton.value.width;
  }

  void moveToLeft() {
    xOffset = startPoint;
  }
}

class SizeTrackingWidget extends StatefulWidget {
  final Widget child;
  final ValueNotifier<Size> sizeValueNotifier;

  const SizeTrackingWidget(
      {super.key, required this.sizeValueNotifier, required this.child});

  @override
  State<SizeTrackingWidget> createState() => _SizeTrackingWidgetState();
}

class _SizeTrackingWidgetState extends State<SizeTrackingWidget> {
  late final RenderBox renderBox;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSize();
    });
  }

  _getSize() {
    renderBox = context.findRenderObject() as RenderBox;
    widget.sizeValueNotifier.value = renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (BuildContext context, Size value, Widget? child) {
        return widget.child;
      },
      valueListenable: widget.sizeValueNotifier,
    );
  }

  @override
  void dispose() {
    widget.sizeValueNotifier.dispose();
    super.dispose();
  }
}
