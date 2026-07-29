import 'dart:convert';

import 'package:auto_care/constants/api_endpoints.dart';
import 'package:auto_care/features/Authentication/models/auth_models.dart';
import 'package:auto_care/services/api_client.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<void> register(RegisterRequest request) async {
    final body = request.toJson();
    final response = await _client.post(
      ApiEndpoints.authRegister,
      body: body,
      endpointName: 'AUTH_REGISTER',
      userHint: request.username,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          'Registration failed. Please try again.',
        ),
      );
    }
  }

  Future<void> forgotPassword({
    required String mailId,
    required String password,
    required String confirmPassword,
  }) async {
    final body = {
      'mailId': mailId.trim(),
      'password': password,
      'confirmPassword': confirmPassword,
    };
    final response = await _client.patch(
      ApiEndpoints.authForgotPassword,
      body: body,
      endpointName: 'AUTH_FORGOT_PASSWORD',
      userHint: mailId,
    );

    if (response.statusCode != 200) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          'Unable to reset password. Please try again.',
        ),
      );
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _client.post(
      ApiEndpoints.authLogin,
      body: request.toJson(),
      endpointName: 'AUTH_LOGIN',
      userHint: request.mailId,
    );

    if (response.statusCode != 200) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          'Login failed. Please check your credentials.',
        ),
      );
    }

    final Map<String, dynamic> json = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};
    return LoginResponse.fromJson(json);
  }

  Future<List<BankCode>> fetchBankCodes({String? token}) async {
    final response = await _client.get(
      ApiEndpoints.bankCodes,
      token: token,
      endpointName: 'BANK_CODES',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _client.apiErrorMessage(
          response.body,
          'Unable to fetch bank list. Please try again.',
        ),
      );
    }

    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : [];
    final rawList = decoded is List
        ? decoded
        : (decoded is Map<String, dynamic> && decoded['data'] is List
              ? decoded['data'] as List
              : const []);

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(BankCode.fromJson)
        .where((bank) => bank.bankName.isNotEmpty && bank.bankCode.isNotEmpty)
        .toList();
  }
}
