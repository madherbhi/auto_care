import 'package:auto_care/models/vehicle_image_capture.dart';
import 'package:auto_care/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';

/// Holds video, photos, and RC uploads for the vehicle form.
class VehicleFormMediaState {
  VehicleFormMediaState({
    this.videoPath,
    List<String>? imagePaths,
    List<VehicleImageMetadata>? imageMetadata,
    this.rcFrontPath,
    this.rcBackPath,
  })  : imagePaths = List<String>.from(imagePaths ?? const []),
        imageMetadata = List<VehicleImageMetadata>.from(
          imageMetadata ?? const [],
        ) {
    _fillMissingMetadata();
  }

  String? videoPath;
  final List<String> imagePaths;
  final List<VehicleImageMetadata> imageMetadata;
  String? rcFrontPath;
  String? rcBackPath;

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
      rcFrontPath: rcFrontPath,
      rcBackPath: rcBackPath,
    );
  }
}
