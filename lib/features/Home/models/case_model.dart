import 'package:auto_care/models/vehicle_record_list_model.dart';

class CaseModel {
  const CaseModel({
    required this.id,
    required this.caseType,
    required this.createdAt,
    required this.location,
    required this.proposedOwnerContactNo,
    required this.proposedOwnerName,
    required this.segmentType,
    required this.status,
    required this.userName,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleNumber,
  });

  final int id;
  final String caseType;
  final String createdAt;
  final String location;
  final String proposedOwnerContactNo;
  final String proposedOwnerName;
  final String segmentType;
  final String status;
  final String userName;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleNumber;

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: int.tryParse((json['id'] ?? '').toString()) ?? 0,
      caseType: (json['caseType'] ?? '').toString().trim(),
      createdAt: (json['createdAt'] ?? '').toString().trim(),
      location: (json['location'] ?? '').toString().trim(),
      proposedOwnerContactNo:
          (json['proposedOwnerContactNo'] ?? '').toString().trim(),
      proposedOwnerName: (json['proposedOwnerName'] ?? '').toString().trim(),
      segmentType: (json['segmentType'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      userName: (json['userName'] ?? '').toString().trim(),
      vehicleMake: (json['vehicleMake'] ?? '').toString().trim(),
      vehicleModel: (json['vehicleModel'] ?? '').toString().trim(),
      vehicleNumber: (json['vehicleNumber'] ?? '').toString().trim(),
    );
  }

  factory CaseModel.fromVehicleRecord(VehicleRecord record, {int id = 0}) {
    return CaseModel(
      id: id,
      caseType: record.caseType,
      createdAt: '',
      location: record.location,
      proposedOwnerContactNo: record.ownerContact,
      proposedOwnerName: record.ownerName,
      segmentType: record.segmentType,
      status: 'Pending',
      userName: record.userName,
      vehicleMake: record.vehicleMake,
      vehicleModel: record.vehicleModel,
      vehicleNumber: record.vehicleNo,
    );
  }

  String get displayCaseType {
    if (caseType.isEmpty) return caseType;
    return caseType[0].toUpperCase() + caseType.substring(1);
  }

  VehicleRecord toVehicleRecord() {
    return VehicleRecord(
      vehicleNo: vehicleNumber,
      segmentType: segmentType,
      caseType: displayCaseType,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      location: location,
      ownerName: proposedOwnerName,
      ownerContact: proposedOwnerContactNo,
      userName: userName,
    );
  }
}
