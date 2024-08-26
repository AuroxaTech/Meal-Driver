import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:driver/models/api_response.dart';
import 'package:driver/models/order.dart';
import 'package:driver/requests/order.request.dart';
import 'package:driver/view_models/base.view_model.dart';
import 'package:hand_signature/signature.dart';
import 'package:path_provider/path_provider.dart';

class OrderSignatureVerificationViewModel extends MyBaseViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  //
  final handSignatureControl = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  //
  OrderSignatureVerificationViewModel(BuildContext context, this.order) {
    viewContext = context;
  }

  Future<File> getSignatureImage() async {
    return await writeToFile(
      await handSignatureControl.toImage() ?? ByteData(0),
    );
  }

  submitSignature() async {
    setBusy(true);
    try {
      ApiResponse apiResponse = await orderRequest.updateOrderWithSignature(
        id: order.id,
        status: "delivered",
        signaturePath: (await getSignatureImage()).path,
      );
      clearErrors();
      //
      order = Order.fromJson(apiResponse.body["order"]);
      toastSuccessful(apiResponse.body["message"]);
      Navigator.pop(viewContext,order);
    } catch (error) {
      print("Error ==> $error");
      toastError("$error");
    }
    setBusy(false);
  }

  //
  Future<File> writeToFile(ByteData data) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = '$tempPath/file_01.tmp';
    return File(filePath).writeAsBytes(
      buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      ),
    );
  }
}
