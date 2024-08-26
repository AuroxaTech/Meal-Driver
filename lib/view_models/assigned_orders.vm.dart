import 'dart:async';

import 'package:flutter/material.dart';
import 'package:driver/constants/app_routes.dart';
import 'package:driver/models/order.dart';
import 'package:driver/requests/order.request.dart';
import 'package:driver/services/app.service.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../services/auth.service.dart';

class AssignedOrdersViewModel extends MyBaseViewModel {
  //
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  double total = 0;

  //
  int queryPage = 1;
  RefreshController refreshController = RefreshController();
  StreamSubscription? refreshOrderStream;
  StreamSubscription? addOrderToListStream;

  void initialise() async {
    refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) {
        fetchOrders();
      }
    });
    //add order to list of already shown assigned orders
    addOrderToListStream = AppService().addToAssignedOrders.listen((order) {
      orders.insert(0, order);
    });

    //
    await fetchOrders();
  }

  dispose() {
    super.dispose();

    refreshOrderStream?.cancel();
    addOrderToListStream?.cancel();
  }

  //
  fetchOrders({bool initialLoading = true}) async {
    if (initialLoading) {
      orders.clear();
      setBusy(true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOrders = await orderRequest.getOrders(
        page: queryPage,
        type: "assigned",
      );

      final today = DateTime.now();
      final todayOrders = mOrders.where((element) {
        DateTime formattedDate =
            DateFormat("dd MMM yyyy").parse(element.formattedDate);
        if (today.year == formattedDate.year &&
            today.month == formattedDate.month &&
            today.day == formattedDate.day) {
          return true;
        }
        return false;
      }).toList();
      if (!initialLoading) {
        orders.addAll(todayOrders);
        refreshController.loadComplete();
      } else {
        orders = todayOrders;
      }
      total = 0;
      clearErrors();
      for (int i = 0; i < orders.length; i++) {
        total += orders[i].total ?? 0.00;
      }
      notifyListeners();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  //
  openPaymentPage(Order order) async {
    launchUrlString(order.paymentLink);
  }

  //
  openOrderDetails(Order order) async {
    final result =
        await Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
      AppRoutes.orderDetailsRoute,
      arguments: order,
    );

    //
    if (result != null && (result is Order || result is bool)) {
      fetchOrders();
    }
  }
}
