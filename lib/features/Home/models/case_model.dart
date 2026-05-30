import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/string_helper.dart';

class CaseMedia {
  const CaseMedia({
    required this.id,
    required this.fileName,
    required this.url,
  });

  final int id;
  final String fileName;
  final String url;

  factory CaseMedia.fromJson(Map<String, dynamic> json) {
    return CaseMedia(
      id: int.tryParse((json['id'] ?? '').toString()) ?? 0,
      fileName: (json['fileName'] ?? '').toString().trim(),
      url: (json['url'] ?? '').toString().trim(),
    );
  }
}

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
    this.images = const [],
    this.rcImages = const [],
    this.videos = const [],
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
  final List<CaseMedia> images;
  final List<CaseMedia> rcImages;
  final List<CaseMedia> videos;

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
      images: _readMediaList(json['images']),
      rcImages: _readMediaList(json['rcImages']),
      videos: _readMediaList(json['videos']),
    );
  }

  static List<CaseMedia> _readMediaList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => CaseMedia.fromJson(Map<String, dynamic>.from(item)))
        .where((media) => media.url.isNotEmpty)
        .toList();
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
      segmentType: _uiSegmentType(segmentType),
      caseType: displayCaseType,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      location: location,
      ownerName: proposedOwnerName,
      ownerContact: proposedOwnerContactNo,
      userName: userName,
      imagePaths: images.map((m) => m.url).where((url) => url.isNotEmpty).toList(),
      videoPath: videos.isNotEmpty ? videos.first.url : null,
      rcImages: rcImages.map((m) => m.url).where((url) => url.isNotEmpty).toList(),
    );
  }

  CaseModel mergeMediaFrom(CaseModel other) {
    return CaseModel(
      id: id,
      caseType: caseType,
      createdAt: createdAt,
      location: location,
      proposedOwnerContactNo: proposedOwnerContactNo,
      proposedOwnerName: proposedOwnerName,
      segmentType: segmentType,
      status: status,
      userName: userName,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      vehicleNumber: vehicleNumber,
      images: images.isNotEmpty ? images : other.images,
      rcImages: rcImages.isNotEmpty ? rcImages : other.rcImages,
      videos: videos.isNotEmpty ? videos : other.videos,
    );
  }

  static String _uiSegmentType(String apiValue) {
    final trimmed = apiValue.trim();
    if (trimmed.toLowerCase() == 'cars' || trimmed.toLowerCase() == 'car') {
      return 'Car';
    }
    for (final option in StringHelper.segmentTypeOptions) {
      if (option.toLowerCase() == trimmed.toLowerCase()) return option;
    }
    return trimmed;
  }
}
