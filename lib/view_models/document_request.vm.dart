import 'dart:io';

import 'package:driver/models/user.dart';
import 'package:driver/requests/auth.request.dart';
import 'package:driver/services/alert.service.dart';
import 'package:driver/services/auth.service.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class DocumentRequestViewModel extends MyBaseViewModel {
  //
  final AuthRequest _authRequest = AuthRequest();
  User? currentUser;
  List<File> selectedDocuments = [];
  //
  void initialise() {
    currentUser = AuthServices.currentUser;
    fetchMyProfile();
  }

  fetchMyProfile() async {
    setBusy(true);
    try {
      currentUser = await _authRequest.getMyDetails();
    } catch (error) {
      print(error);
    }
    setBusy(false);
  }

  //
  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  submitDocuments() async {
    //if no document is selected
    if (selectedDocuments.isEmpty) {
      toastError("Please select a document".tr());
      return;
    }

    setBusyForObject(selectedDocuments, true);

    try {
      //
      final apiResponse = await _authRequest.submitDocumentsRequest(
        docs: selectedDocuments,
      );

      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Document Request".tr(),
          text: "${apiResponse.message}",
        );
        //
        fetchMyProfile();
        //
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }

    setBusyForObject(selectedDocuments, false);
  }
}
