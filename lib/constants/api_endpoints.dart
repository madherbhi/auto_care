abstract final class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://35.154.202.121:8080';

  // Auth
  static const String authRegister = '$baseUrl/auth/register';
  static const String authForgotPassword = '$baseUrl/auth/forgot/password';
  static const String authLogin = '$baseUrl/auth/login';

  // Cases & banks
  static const String bankCodes = '$baseUrl/api/v1/get/banks/codes';
  static const String casesAll = '$baseUrl/api/v1/get/all/cases/';
  static const String casesCreate = '$baseUrl/api/v1/create';

  static String casesUpdate(int caseId) => '$baseUrl/api/v1/update/$caseId';

  static String segmentGuideBy(String segmentType) =>
      '$baseUrl/api/v1/segment/guide/by/$segmentType';
}
