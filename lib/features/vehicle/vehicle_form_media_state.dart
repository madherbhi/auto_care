import 'package:auto_care/utils/media_helper.dart';
import 'package:auto_care/features/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/string_helper.dart';

/// Shared media state and capture rules for add / detail vehicle forms.
class VehicleFormMediaState {
  VehicleFormMediaState({
    this.videoPath,
    List<String>? imagePaths,
    this.licenceImagePath,
  }) : imagePaths = List.of(imagePaths ?? const []);

  String? videoPath;
  final List<String> imagePaths;
  String? licenceImagePath;

  VehicleRecord toRecord({
    required String vehicleNo,
    required String type,
    required String location,
    required String ownerName,
    required String ownerContact,
    required String userName,
  }) {
    return VehicleRecord(
      vehicleNo: vehicleNo,
      type: type,
      location: location,
      ownerName: ownerName,
      ownerContact: ownerContact,
      userName: userName,
      videoPath: videoPath,
      imagePaths: List.unmodifiable(imagePaths),
      licenceImagePath: licenceImagePath,
    );
  }

  String? photoBlockedMessage() {
    if (imagePaths.length >= MediaHelper.maxImages) {
      return StringHelper.maxImagesReached;
    }
    return null;
  }

  String? licenceBlockedMessage() {
    if (imagePaths.length < MediaHelper.maxImages) {
      return StringHelper.captureSixImagesFirst;
    }
    return null;
  }
}
