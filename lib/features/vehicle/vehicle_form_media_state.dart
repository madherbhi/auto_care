import 'package:auto_care/models/vehicle_image_capture.dart';
import 'package:auto_care/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/capture_metadata_service.dart';

/// Shared media state for add / detail vehicle forms.
class VehicleFormMediaState {
  VehicleFormMediaState({
    this.videoPath,
    List<String>? imagePaths,
    List<VehicleImageMetadata>? imageMetadata,
    this.rcFrontPath,
    this.rcBackPath,
  }) : images = _buildInitialImages(imagePaths, imageMetadata);

  String? videoPath;
  final List<VehicleImageCapture> images;
  String? rcFrontPath;
  String? rcBackPath;

  List<String> get imagePaths =>
      images.map((capture) => capture.path).toList(growable: false);

  List<VehicleImageMetadata> get imageMetadata =>
      images.map((capture) => capture.metadata).toList(growable: false);

  static List<VehicleImageCapture> _buildInitialImages(
    List<String>? imagePaths,
    List<VehicleImageMetadata>? imageMetadata,
  ) {
    if (imagePaths == null || imagePaths.isEmpty) return [];

    return List.generate(imagePaths.length, (index) {
      final metadata = imageMetadata != null && index < imageMetadata.length
          ? imageMetadata[index]
          : VehicleImageMetadata(
              capturedAt: DateTime.now(),
              indexNumber: CaptureMetadataService.nextIndexNumber(),
            );
      return VehicleImageCapture(path: imagePaths[index], metadata: metadata);
    });
  }

  void addImage(VehicleImageCapture capture) {
    images.add(capture);
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= images.length) return;
    images.removeAt(index);
  }

  int nextIndexNumber() {
    if (images.isEmpty) return CaptureMetadataService.nextIndexNumber();
    return images.map((e) => e.metadata.indexNumber).reduce((a, b) => a > b ? a : b) + 1;
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
