import 'package:auto_care/features/vehicle/models/vehicle_image_capture.dart';
import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';


class VehicleFormMediaState {
  VehicleFormMediaState({
    this.videoPath,
    List<String>? imagePaths,
    List<VehicleImageMetadata>? imageMetadata,
    List<String>? rcImages,
  })  : imagePaths = List<String>.from(imagePaths ?? const []),
        imageMetadata = List<VehicleImageMetadata>.from(
          imageMetadata ?? const [],
        ) {
    final rc = List<String>.from(rcImages ?? const []);
    if (rc.isNotEmpty) _rcFrontPath = rc.first;
    if (rc.length > 1) _rcBackPath = rc[1];
    _fillMissingMetadata();
  }

  String? videoPath;
  final List<String> imagePaths;
  final List<VehicleImageMetadata> imageMetadata;

  String? _rcFrontPath;
  String? _rcBackPath;

  String? get rcFrontPath => _rcFrontPath;

  String? get rcBackPath => _rcBackPath;

  void setRcFront(String path) => _rcFrontPath = path;

  void setRcBack(String path) => _rcBackPath = path;

  List<String> get rcImages => [
        if (_rcFrontPath != null) _rcFrontPath!,
        if (_rcBackPath != null) _rcBackPath!,
      ];

  void _fillMissingMetadata() {
    while (imageMetadata.length < imagePaths.length) {
      imageMetadata.add(
        VehicleImageMetadata(
          capturedAt: DateTime.now(),
          indexNumber: CaptureMetadataService.nextIndexNumber(),
        ),
      );
    }
  }

  void addImage(VehicleImageCapture capture) {
    imagePaths.add(capture.path);
    imageMetadata.add(capture.metadata);
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= imagePaths.length) return;
    imagePaths.removeAt(index);
    if (index < imageMetadata.length) {
      imageMetadata.removeAt(index);
    }
  }

  int nextIndexNumber() {
    if (imageMetadata.isEmpty) {
      return CaptureMetadataService.nextIndexNumber();
    }

    var highest = imageMetadata.first.indexNumber;
    for (final data in imageMetadata) {
      if (data.indexNumber > highest) {
        highest = data.indexNumber;
      }
    }
    return highest + 1;
  }

  VehicleRecord toRecord({
    required String vehicleNo,
    required String segmentType,
    required String caseType,
    required String vehicleMake,
    required String vehicleModel,
    required String location,
    required String ownerName,
    required String ownerContact,
    required String userName,
  }) {
    return VehicleRecord(
      vehicleNo: vehicleNo,
      segmentType: segmentType,
      caseType: caseType,
      vehicleMake: vehicleMake,
      vehicleModel: vehicleModel,
      location: location,
      ownerName: ownerName,
      ownerContact: ownerContact,
      userName: userName,
      videoPath: videoPath,
      imagePaths: List.unmodifiable(imagePaths),
      imageMetadata: List.unmodifiable(imageMetadata),
      rcImages: rcImages,
    );
  }
}
