class VehicleRecord {
  const VehicleRecord({
    required this.vehicleNo,
    required this.type,
    required this.location,
    required this.ownerName,
    required this.ownerContact,
    required this.userName,
    this.videoPath,
    this.imagePaths = const [],
    this.licenceImagePath,
  });

  final String vehicleNo;
  final String type;
  final String location;
  final String ownerName;
  final String ownerContact;
  final String userName;
  final String? videoPath;
  final List<String> imagePaths;
  final String? licenceImagePath;

  VehicleRecord copyWith({
    String? vehicleNo,
    String? type,
    String? location,
    String? ownerName,
    String? ownerContact,
    String? userName,
    String? videoPath,
    List<String>? imagePaths,
    String? licenceImagePath,
  }) {
    return VehicleRecord(
      vehicleNo: vehicleNo ?? this.vehicleNo,
      type: type ?? this.type,
      location: location ?? this.location,
      ownerName: ownerName ?? this.ownerName,
      ownerContact: ownerContact ?? this.ownerContact,
      userName: userName ?? this.userName,
      videoPath: videoPath ?? this.videoPath,
      imagePaths: imagePaths ?? this.imagePaths,
      licenceImagePath: licenceImagePath ?? this.licenceImagePath,
    );
  }
}

/// Sample vehicle details keyed by registration number for list → detail navigation.
final Map<String, VehicleRecord> kSampleVehiclesByRegNo = {
  'AP39FG8236': const VehicleRecord(
    vehicleNo: 'AP39FG8236',
    type: 'CAR',
    location: 'Vijayawada',
    ownerName: 'Mr. Kumar',
    ownerContact: '9876543210',
    userName: 'Mr. Raju',
  ),
  'AP39FG8237': const VehicleRecord(
    vehicleNo: 'AP39FG8237',
    type: 'CAR',
    location: 'Guntur',
    ownerName: 'Mr. Raju',
    ownerContact: '8987656765',
    userName: 'Mr. Kumar',
  ),
  'TS10AB1234': const VehicleRecord(
    vehicleNo: 'TS10AB1234',
    type: 'TRUCK',
    location: 'Hyderabad',
    ownerName: 'Ms. Priya',
    ownerContact: '9123456780',
    userName: 'Ms. Priya',
  ),
  'KA05CD9999': const VehicleRecord(
    vehicleNo: 'KA05CD9999',
    type: 'BIKE',
    location: 'Bangalore',
    ownerName: 'Mr. Ahmed',
    ownerContact: '9012345678',
    userName: 'Mr. Ahmed',
  ),
  'MH12XY0001': const VehicleRecord(
    vehicleNo: 'MH12XY0001',
    type: 'CAR',
    location: 'Mumbai',
    ownerName: 'Ms. Lee',
    ownerContact: '9988776655',
    userName: 'Ms. Lee',
  ),
  'TS08FE9076': const VehicleRecord(
    vehicleNo: 'TS08FE9076',
    type: 'CAR',
    location: 'Hyderabad',
    ownerName: 'Mr. Madhu',
    ownerContact: '8987656765',
    userName: 'Mr. Raju',
  ),
};
