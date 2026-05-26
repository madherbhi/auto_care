import 'package:auto_care/features/Authentication/models/auth_models.dart';
import 'package:auto_care/features/Authentication/services/auth_service.dart';
import 'package:auto_care/utils/user_session.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController({AuthService? service})
      : _service = service ?? AuthService();

  final AuthService _service;

  final RxBool isRegistering = false.obs;
  final RxBool isLoggingIn = false.obs;
  final RxnString errorMessage = RxnString();

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
      errorMessage.value = e.toString();
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
    return login(username: username, password: password);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (isLoggingIn.value) return false;

    isLoggingIn.value = true;
    errorMessage.value = null;
    try {
      final request = LoginRequest(
        username: username,
        password: password,
      );
      final response = await _service.login(request);
      UserSession.setUserName(username);
      UserSession.setAuthToken(response.token);
      await UserSession.persist();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoggingIn.value = false;
    }
  }
}

