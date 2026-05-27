import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/user_session.dart';

/// Maps form [VehicleRecord] values to the cases/create API query parameters.
class CreateCaseRequest {
  const CreateCaseRequest({
    required this.segmentType,
    required this.caseType,
    required this.vehicleNumber,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.location,
    required this.proposedOwnerName,
    required this.proposedOwnerContactNo,
    required this.userName,
    this.status = 'ACTIVE',
    this.imagePaths = const [],
    this.videoPath,
    this.rcImages = const [],

  });

  final String segmentType;
  final String caseType;
  final String vehicleNumber;
  final String vehicleMake;
  final String vehicleModel;
  final String location;
  final String proposedOwnerName;
  final String proposedOwnerContactNo;
  final String userName;
  final String status;
      final List<String> imagePaths;
  final String? videoPath;
  final List<String> rcImages;


  factory CreateCaseRequest.fromVehicleRecord(VehicleRecord record) {
    final userName = record.userName.trim().isNotEmpty
        ? record.userName.trim()
        : (UserSession.resolvedUserName()?.trim() ?? '');

    return CreateCaseRequest(
      segmentType: _apiValue(record.segmentType),
      caseType: _apiValue(record.caseType),
      vehicleNumber: record.vehicleNo.trim(),
      vehicleMake: record.vehicleMake.trim(),
      vehicleModel: record.vehicleModel.trim(),
      location: record.location.trim(),
      proposedOwnerName: record.ownerName.trim(),
      proposedOwnerContactNo: record.ownerContact.trim(),
      userName: userName,
      imagePaths: List<String>.from(record.imagePaths),
      videoPath: record.videoPath,
      rcImages: List<String>.from(record.rcImages),     
    );
  }

  Map<String, String> toQueryParameters() {
    return {
      'segmentType': segmentType,
      'caseType': caseType,
      'vehicleNumber': vehicleNumber,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'location': location,
      'proposedOwnerName': proposedOwnerName,
      'proposedOwnerContactNo': proposedOwnerContactNo,
      'userName': userName,
      'status': status,
    };
  }

  VehicleRecord toVehicleRecord() {
    return VehicleRecord(
      vehicleNo: vehicleNumber,
      segmentType: segmentType,
      caseType: caseType,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      location: location,
      ownerName: proposedOwnerName,
      ownerContact: proposedOwnerContactNo,
      userName: userName,
      videoPath: videoPath,
      imagePaths: imagePaths,
      rcImages: rcImages,
    );
  }

  static String _apiValue(String display) => display.trim().toLowerCase();
}
