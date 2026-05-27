import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';

class VehicleRecord {
  const VehicleRecord({
    required this.vehicleNo,
    required this.segmentType,
    required this.caseType,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.location,
    required this.ownerName,
    required this.ownerContact,
    required this.userName,
    this.videoPath,
    this.imagePaths = const [],
    this.imageMetadata = const [],
      this.rcImages = const [],
  });

  final String vehicleNo;
  final String segmentType;
  final String caseType;
  final String vehicleMake;
  final String vehicleModel;
  final String location;
  final String ownerName;
  final String ownerContact;
  final String userName;
  final String? videoPath;
  final List<String> imagePaths;
  final List<VehicleImageMetadata> imageMetadata;
  final List<String> rcImages;

  VehicleRecord copyWith({
    String? vehicleNo,
    String? segmentType,
    String? caseType,
    String? vehicleMake,
    String? vehicleModel,
    String? location,
    String? ownerName,
    String? ownerContact,
    String? userName,
    String? videoPath,
    List<String>? imagePaths,
    List<VehicleImageMetadata>? imageMetadata,
    List<String>? rcImages,
  }) {
    return VehicleRecord(
      vehicleNo: vehicleNo ?? this.vehicleNo,
      segmentType: segmentType ?? this.segmentType,
      caseType: caseType ?? this.caseType,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      location: location ?? this.location,
      ownerName: ownerName ?? this.ownerName,
      ownerContact: ownerContact ?? this.ownerContact,
      userName: userName ?? this.userName,
      videoPath: videoPath ?? this.videoPath,
      imagePaths: imagePaths ?? this.imagePaths,
      imageMetadata: imageMetadata ?? this.imageMetadata,
      rcImages: rcImages ?? this.rcImages,
    );
  }
}

/// Sample vehicle details keyed by registration number for list → detail navigation.
final Map<String, VehicleRecord> kSampleVehiclesByRegNo = {
  'AP39FG8236': const VehicleRecord(
    vehicleNo: 'AP39FG8236',
    segmentType: 'Car',
    caseType: 'Valuation',
    vehicleMake: 'Hyundai',
    vehicleModel: 'i20',
    location: 'Vijayawada',
    ownerName: 'Mr. Kumar',
    ownerContact: '9876543210',
    userName: 'Mr. Raju',
  ),
  'AP39FG8237': const VehicleRecord(
    vehicleNo: 'AP39FG8237',
    segmentType: 'Car',
    caseType: 'Pre-inspection',
    vehicleMake: 'Maruti',
    vehicleModel: 'Swift',
    location: 'Guntur',
    ownerName: 'Mr. Raju',
    ownerContact: '8987656765',
    userName: 'Mr. Kumar',
  ),
  'TS10AB1234': const VehicleRecord(
    vehicleNo: 'TS10AB1234',
    segmentType: 'Commercial vehicle',
    caseType: 'Survey assessment',
    vehicleMake: 'Tata',
    vehicleModel: 'LPT',
    location: 'Hyderabad',
    ownerName: 'Ms. Priya',
    ownerContact: '9123456780',
    userName: 'Ms. Priya',
  ),
  'KA05CD9999': const VehicleRecord(
    vehicleNo: 'KA05CD9999',
    segmentType: 'Tractor/ harvester',
    caseType: 'Valuation',
    vehicleMake: 'Honda',
    vehicleModel: 'Activa',
    location: 'Bangalore',
    ownerName: 'Mr. Ahmed',
    ownerContact: '9012345678',
    userName: 'Mr. Ahmed',
  ),
  'MH12XY0001': const VehicleRecord(
    vehicleNo: 'MH12XY0001',
    segmentType: 'Car',
    caseType: 'Pre-inspection',
    vehicleMake: 'Toyota',
    vehicleModel: 'Innova',
    location: 'Mumbai',
    ownerName: 'Ms. Lee',
    ownerContact: '9988776655',
    userName: 'Ms. Lee',
  ),
  'TS08FE9076': const VehicleRecord(
    vehicleNo: 'TS08FE9076',
    segmentType: 'Car',
    caseType: 'Survey assessment',
    vehicleMake: 'Mahindra',
    vehicleModel: 'XUV700',
    location: 'Hyderabad',
    ownerName: 'Mr. Madhu',
    ownerContact: '8987656765',
    userName: 'Mr. Raju',
  ),
};
