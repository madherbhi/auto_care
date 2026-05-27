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
    required this.mailId,
    required this.password,
  });

  final String mailId;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'mailId': mailId,
      'password': password,
    };
  }
}

class LoginResponse {
  LoginResponse({
    required this.token,
    this.username,
  });

  final String token;
  final String? username;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final resolvedUsername = (json['username'] ??
            json['userName'] ??
            json['name'] ??
            '')
        .toString()
        .trim();
    return LoginResponse(
      token: (json['token'] ?? '').toString(),
      username: resolvedUsername.isEmpty ? null : resolvedUsername,
    );
  }
}

