import 'package:flutter/material.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:supercharged/supercharged.dart';

import '../models/driver_shift_request.dart';
import '../models/shift.dart';
import '../models/zone.dart';
import '../requests/shift.request.dart';
import '../services/toast.service.dart';

class ShiftsViewModel extends MyBaseViewModel {
  ShiftsViewModel(BuildContext context, {required this.tickerProvider}) {
    viewContext = context;
  }

  ShiftRequest shiftRequest = ShiftRequest();
  Map<String, List<Shift>> shifts = {};
  Map<int, Zone> allShifts = {};
  RefreshController refreshController = RefreshController();

  final TickerProvider tickerProvider;
  TabController? tabBarController;
  List<String> menus = ["New", "Accepted"];
  String selectedTabName = "New";
  int shiftStatus = -1;

  @override
  void initialise() async {
    //await fetchShifts();
  }

  void handleTabChange() {
    selectedTabName = menus[tabBarController!.index];
    filterShifts();
    //notifyListeners();
  }

  //
  Future<void> fetchShifts({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
      allShifts.clear();
    }

    try {
      Map<int, DriverShiftRequest> myShifts = await shiftRequest.getMyShifts();

      final mShifts = await shiftRequest.getShifts();
      if (!initialLoading) {
        refreshController.loadComplete();
      } else {
        allShifts.clear();
      }
      for (var shift in mShifts) {
        if (myShifts.isNotEmpty) {
          if (myShifts.containsKey(shift.id)) {
            shift.shiftRequestStatus = myShifts[shift.id]!.status;
          }
        }

        Zone? zone = allShifts[shift.zoneId];
        if (null != zone) {
          List<Shift>? zoneShifts = zone.shifts[shift.date];
          if (null != zoneShifts) {
            zoneShifts.add(shift);
          } else {
            zone.shifts[shift.date] = [shift];
          }
        } else {
          Zone zone = shift.zone;
          zone.shifts = {
            shift.date: <Shift>[shift]
          };
          allShifts[shift.zoneId] = zone;
        }
      }

      filterShifts();

      clearErrors();
    } catch (error) {
      print("Shift Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  void filterShifts() {
    if (selectedTabName == "Accepted") {
      shiftStatus = 1;
    } else if (selectedTabName == "Requested") {
      shiftStatus = 2;
    } else if (selectedTabName == "Rejected") {
      shiftStatus = 0;
    } else {
      shiftStatus = -1;
    }

    shifts.clear();
    for (Zone zone in allShifts.values) {
      zone.shifts.forEach((date, zoneDateShifts) {
        String title = "${zone.name} ($date)";
        print(title);
        List<Shift> filteredShifts = zoneDateShifts
            .filter((element) => element.shiftRequestStatus == shiftStatus)
            .toList();
        if (filteredShifts.isNotEmpty) {
          shifts[title] = filteredShifts;
        }
      });
    }

    notifyListeners();
  }

  onShiftClick(Shift shift) async {
    if (shift.shiftRequestStatus < 0) {
      setBusy(true);
      String message = await shiftRequest.requestShift(shiftId: shift.id);
      ToastService.toastSuccessful(message);
      fetchShifts();
    }
  }
}
