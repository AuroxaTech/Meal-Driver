import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants/app_routes.dart';
import '../models/day_order_total.dart';
import '../models/order.dart';
import '../requests/order.request.dart';
import '../services/app.service.dart';
import 'base.view_model.dart';

class CompletedOrdersViewModel extends MyBaseViewModel {
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  Map<String, DayOrderTotal> dateTotals = {};
  List<String> orderDates = [];
  double total = 0;

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
    fetchOrders();
  }

  dispose() {
    super.dispose();

    refreshOrderStream?.cancel();
    addOrderToListStream?.cancel();
  }

  fetchOrders({bool initialLoading = true}) async {
    if (initialLoading) {
      dateTotals.clear();
      orderDates.clear();
      orders.clear();
      setBusy(true);
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOrders = await orderRequest.getOrders(
        page: queryPage,
        status: "delivered",
      );

      for(Order order in mOrders){
        String date =
        DateFormat("EEEE dd/MM/yyyy").format(order.createdAt);
        if (!orderDates.contains(date)) {
          order.showDateHeader = true;
          orderDates.add(date);
        }
      }


      if (!initialLoading) {
        orders.addAll(mOrders);
        refreshController.loadComplete();
      } else {
        refreshController.refreshCompleted();
        orders = mOrders;
      }
      total = 0;
      clearErrors();
      for (int i = 0; i < orders.length; i++) {
        total += orders[i].total ?? 0.00;
      }
      print('Total ======> ${orders[0].total}');
      processDateTotals();


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

  processDateTotals() {
    dateTotals.clear();
    print("Starting processDateTotals with orders count: ${orders.length}");
    for (Order order in orders) {
      String date = DateFormat("EEEE dd/MM/yyyy").format(order.createdAt);
      double driverFee = order.commission?.driver ?? 0;
      print("Order date: $date, Driver Fee: $driverFee");

      DayOrderTotal? orderDayTotal;
      if (dateTotals.containsKey(date)) {
        orderDayTotal = dateTotals[date];
      }

      if (orderDayTotal != null) {
        orderDayTotal.count += 1;
        orderDayTotal.total += driverFee;
        print("Updated DayOrderTotal: ${orderDayTotal.total}");
      } else {
        orderDayTotal = DayOrderTotal(day: date, count: 1, total: driverFee);
        print("New DayOrderTotal: ${orderDayTotal.total}");
      }
      dateTotals[date] = orderDayTotal;
    }
  }

}
