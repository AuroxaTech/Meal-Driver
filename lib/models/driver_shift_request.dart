import 'dart:convert';

DriverShiftRequest driverShiftRequestFromJson(String str) =>
    DriverShiftRequest.fromJson(json.decode(str));

String driverShiftRequestToJson(DriverShiftRequest data) => json.encode(data.toJson());

class DriverShiftRequest {
  DriverShiftRequest({
    required this.id,
    required this.driverId,
    required this.shiftId,
    required this.status,
  });

  int id;
  int driverId;
  int shiftId;
  int status;

  factory DriverShiftRequest.fromJson(Map<String, dynamic> json) {
    return DriverShiftRequest(
      id: json["id"],
      driverId: json["driver_id"],
      shiftId: json["shift_id"],
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "driver_id": driverId,
        "shift_id": shiftId,
        "status": status,
      };
}
