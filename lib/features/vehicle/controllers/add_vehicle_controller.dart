import 'package:auto_care/features/Home/models/case_model.dart';
import 'package:auto_care/features/Home/services/cases_service.dart';
import 'package:auto_care/features/vehicle/models/create_case_request.dart';
import 'package:auto_care/features/vehicle/models/vehicle_record_list_model.dart';
import 'package:auto_care/utils/string_helper.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:get/get.dart';

class AddVehicleController extends GetxController {
  AddVehicleController({CasesService? service})
      : _service = service ?? CasesService();

  final CasesService _service;

  final RxBool isSubmitting = false.obs;
  final RxnString errorMessage = RxnString();

  String _humanizeError(Object error) {
    final raw = error.toString().trim();
    final message = raw.startsWith('Exception: ')
        ? raw.substring(11).trim()
        : raw;
    final lower = message.toLowerCase();
    if (lower.contains('broken pipe') ||
        lower.contains('socketexception') ||
        lower.contains('connection reset')) {
      return StringHelper.uploadConnectionLost;
    }
    return message;
  }

  Future<CaseModel?> createCase(VehicleRecord record) async {
    if (isSubmitting.value) return null;

    isSubmitting.value = true;
    errorMessage.value = null;
    try {
      final request = CreateCaseRequest.fromVehicleRecord(record);
      if (request.userName.isEmpty) {
        errorMessage.value = StringHelper.userNameRequired;
        return null;
      }

      final token = UserSession.authToken ?? '';
      final created = await _service.createCase(
        request: request,
        token: token,
      );
      return created;
    } catch (e) {
      errorMessage.value = _humanizeError(e);
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
