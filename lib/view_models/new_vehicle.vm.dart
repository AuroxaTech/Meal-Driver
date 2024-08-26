import 'dart:io';

import 'package:flutter/material.dart';
import 'package:driver/models/vehicle.dart';
import 'package:driver/requests/general.request.dart';
import 'package:driver/requests/vehicle.request.dart';
import 'package:driver/services/alert.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'base.view_model.dart';

class NewVehicleViewModel extends MyBaseViewModel {
  //the textediting controllers
  TextEditingController carMakeTEC = TextEditingController();
  TextEditingController carModelTEC = TextEditingController();
  List<String> types = ["Regular", "Taxi"];
  List<VehicleType> vehicleTypes = [];
  String selectedDriverType = "regular";
  List<CarMake> carMakes = [];
  List<CarModel> carModels = [];
  CarMake? selectedCarMake;
  CarModel? selectedCarModel;
  List<File> selectedDocuments = [];

  final GeneralRequest _generalRequest = GeneralRequest();
  VehicleRequest vehicleRequest = VehicleRequest();

  NewVehicleViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() {
    fetchVehicleTypes();
    fetchCarMakes();
  }

  void fetchVehicleTypes() async {
    setBusyForObject(vehicleTypes, true);
    try {
      vehicleTypes = await _generalRequest.getVehicleTypes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(vehicleTypes, false);
  }

  void fetchCarMakes() async {
    setBusyForObject(carMakes, true);
    try {
      carMakes = await _generalRequest.getCarMakes();
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carMakes, false);
  }

  void fetchCarModel() async {
    setBusyForObject(carModels, true);
    try {
      carModels = await _generalRequest.getCarModels(
        carMakeId: selectedCarMake?.id,
      );
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(carModels, false);
  }

  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  onCarMakeSelected(CarMake value) {
    selectedCarMake = value;
    carMakeTEC.text = value.name;
    notifyListeners();
    fetchCarModel();
  }

  onCarModelSelected(CarModel value) {
    selectedCarModel = value;
    carModelTEC.text = value.name;
    notifyListeners();
  }

  void processSave() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //

      setBusy(true);

      try {
        Map<String, dynamic> mValues = formBuilderKey.currentState!.value;
        final carData = {
          "car_make_id": selectedCarMake?.id,
          "car_model_id": selectedCarModel?.id,
        };

        final values = {...mValues, ...carData};
        Map<String, dynamic> params = Map.from(values);

        final apiResponse = await vehicleRequest.newVehicleRequest(
          vals: params,
          docs: selectedDocuments,
        );

        if (apiResponse.allGood) {
          await AlertService.success(
            title: "New Vehicle".tr(),
            text: "${apiResponse.message}",
          );
          Navigator.pop(viewContext,true);
        } else {
          toastError("${apiResponse.message}");
        }
      } catch (error) {
        toastError("$error");
      }

      setBusy(false);
    }
  }
}
