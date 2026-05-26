class RegisterRequest {
  RegisterRequest({
    required this.username,
    required this.password,
    required this.mailId,
    required this.mobileNumber,
    required this.companyName,
    required this.companyId,
    this.role = '',
    this.status = '',
  });

  final String username;
  final String password;
  final String mailId;
  final String mobileNumber;
  final String companyName;
  final String companyId;
  final String role;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'mailId': mailId,
      'mobileNumber': mobileNumber,
      'companyName': companyName,
      'companyId': companyId,
      'role': role,
      'status': status,
    };
  }
}

class LoginRequest {
  LoginRequest({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  LoginResponse({required this.token});

  final String token;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(token: (json['token'] ?? '').toString());
  }
}

