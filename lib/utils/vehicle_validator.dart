import 'package:auto_care/utils/string_helper.dart';

class VehicleValidator {
  VehicleValidator._();

  static final RegExp _vehicleNoPattern = RegExp(
    r'^[A-Za-z]{2}\s*[-]?\s*\d{1,2}\s*[-]?\s*[A-Za-z]{0,3}\s*[-]?\s*\d{4}$',
  );

  static final RegExp _phonePattern = RegExp(r'^[6-9]\d{9}$');

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? required(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? vehicleNumber(String? value) {
    final empty = required(value, message: StringHelper.vehicleNoRequired);
    if (empty != null) return empty;
    final normalized = value!.trim().replaceAll(RegExp(r'\s+'), '');
    if (!_vehicleNoPattern.hasMatch(normalized)) {
      return StringHelper.vehicleNoInvalid;
    }
    return null;
  }

  static String? contactNumber(String? value) {
    final empty = required(value, message: StringHelper.contactNumberRequired);
    if (empty != null) return empty;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (!_phonePattern.hasMatch(digits)) {
      return StringHelper.contactNumberInvalid;
    }
    return null;
  }

  static String? mobileNumber(String? value) {
    final empty = required(value, message: StringHelper.mobileNumberRequired);
    if (empty != null) return empty;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (!_phonePattern.hasMatch(digits)) {
      return StringHelper.mobileNumberInvalid;
    }
    return null;
  }

  static String? email(String? value) {
    final empty = required(value, message: StringHelper.emailRequired);
    if (empty != null) return empty;
    final trimmed = value!.trim();
    if (!_emailPattern.hasMatch(trimmed)) {
      return StringHelper.emailInvalid;
    }
    return null;
  }
}
