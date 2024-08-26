import 'package:flutter/material.dart';
import 'package:driver/utils/ui_spacer.dart';
import 'package:driver/widgets/states/empty.state.dart';
import 'package:driver/widgets/states/loading.shimmer.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomGridView extends StatelessWidget {
  //
  final Widget? title;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final List<dynamic> dataSet;
  final bool isLoading;
  final bool hasError;
  final bool justList;
  final bool reversed;
  final bool noScrollPhysics;
  final Axis scrollDirection;
  final EdgeInsets? padding;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  //
  final bool canRefresh;
  final RefreshController? refreshController;
  final Function? onRefresh;
  final Function? onLoading;
  final bool canPullUp;

  const CustomGridView({
    required this.dataSet,
    this.title,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.isLoading = false,
    this.hasError = false,
    this.justList = true,
    this.reversed = false,
    this.noScrollPhysics = false,
    this.scrollDirection = Axis.vertical,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,

    //
    this.canRefresh = false,
    this.refreshController,
    this.onRefresh,
    this.onLoading,
    this.canPullUp = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return justList
        ? _getBody()
        : VStack(
            [
              title ?? UiSpacer.emptySpace(),
              _getBody(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          );
  }

  Widget _getBody() {
    return isLoading
        ? loadingWidget ?? const LoadingShimmer()
        : hasError
            ? errorWidget ?? const EmptyState()
            : justList
                ? dataSet.isEmpty
                    ? emptyWidget ?? UiSpacer.emptySpace()
                    : _getBodyList()
                : Expanded(
                    child: _getBodyList(),
                  );
  }

  //
  Widget _getBodyList() {
    //

    return canRefresh
        ? SmartRefresher(
            scrollDirection: scrollDirection,
            enablePullDown: true,
            enablePullUp: canPullUp,
            controller: refreshController!,
            onRefresh: onRefresh != null ? () => onRefresh!() : null,
            onLoading: onLoading != null ? () => onLoading!() : null,
            child: _getListView(),
          )
        : _getListView();
  }

  //get listview
  Widget _getListView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      padding: padding,
      physics: noScrollPhysics ? const NeverScrollableScrollPhysics() : null,
      shrinkWrap: true,
      itemBuilder: itemBuilder,
      itemCount: dataSet.length,
      reverse: reversed,
      scrollDirection: scrollDirection,
    );
  }
}
