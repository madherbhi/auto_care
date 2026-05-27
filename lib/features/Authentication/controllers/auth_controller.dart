import 'package:auto_care/features/Authentication/models/auth_models.dart';
import 'package:auto_care/features/Authentication/services/auth_service.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController({AuthService? service}) : _service = service ?? AuthService();

  final AuthService _service;

  final RxBool isRegistering = false.obs;
  final RxBool isLoggingIn = false.obs;
  final RxnString errorMessage = RxnString();

  String _humanizeError(Object error) {
    final raw = error.toString().trim();
    return raw.startsWith('Exception: ') ? raw.substring(11).trim() : raw;
  }

  Future<bool> register({
    required String username,
    required String password,
    required String mobileNumber,
    required String email,
    required String companyName,
    required String companyId,
  }) async {
    if (isRegistering.value) return false;

    isRegistering.value = true;
    errorMessage.value = null;
    try {
      final request = RegisterRequest(
        username: username,
        password: password,
        mailId: email,
        mobileNumber: mobileNumber,
        companyName: companyName,
        companyId: companyId,
      );
      await _service.register(request);
      UserSession.setUserName(username);
      await UserSession.persist();
      return true;
    } catch (e) {
      errorMessage.value = _humanizeError(e);
      return false;
    } finally {
      isRegistering.value = false;
    }
  }

  Future<bool> registerAndLogin({
    required String username,
    required String password,
    required String mobileNumber,
    required String email,
    required String companyName,
    required String companyId,
  }) async {
    final registered = await register(
      username: username,
      password: password,
      mobileNumber: mobileNumber,
      email: email,
      companyName: companyName,
      companyId: companyId,
    );
    if (!registered) return false;
    return login(mailId: email, password: password);
  }

  Future<bool> login({required String mailId, required String password}) async {
    if (isLoggingIn.value) return false;

    isLoggingIn.value = true;
    errorMessage.value = null;
    try {
      final request = LoginRequest(mailId: mailId, password: password);
      final response = await _service.login(request);
      if (response.username != null && response.username!.trim().isNotEmpty) {
        UserSession.setUserName(response.username!);
      }
      UserSession.setAuthToken(response.token);
      await UserSession.persist();
      return true;
    } catch (e) {
      errorMessage.value = _humanizeError(e);
      return false;
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<List<BankCode>> fetchBankCodes() async {
    try {
      return await _service.fetchBankCodes(token: UserSession.authToken);
    } catch (e) {
      errorMessage.value = _humanizeError(e);
      rethrow;
    }
  }
}
