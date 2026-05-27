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
  LoginRequest({required this.mailId, required this.password});

  final String mailId;
  final String password;

  Map<String, dynamic> toJson() {
    return {'mailId': mailId, 'password': password};
  }
}

class LoginResponse {
  LoginResponse({required this.token, this.username});

  final String token;
  final String? username;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = _readToken(json);
    final resolvedUsername = _readUsername(json);
    return LoginResponse(
      token: token,
      username: resolvedUsername,
    );
  }

  static String _readToken(Map<String, dynamic> json) {
    for (final source in _jsonSources(json)) {
      final token = (source['token'] ?? source['accessToken'] ?? '')
          .toString()
          .trim();
      if (token.isNotEmpty) return token;
    }
    return '';
  }

  static String? _readUsername(Map<String, dynamic> json) {
    for (final source in _jsonSources(json)) {
      for (final key in const ['username', 'userName', 'name', 'displayName']) {
        final resolved = (source[key] ?? '').toString().trim();
        if (resolved.isNotEmpty && !resolved.contains('@')) return resolved;
      }
    }
    return null;
  }

  static Iterable<Map<String, dynamic>> _jsonSources(
    Map<String, dynamic> json,
  ) sync* {
    yield json;
    final data = json['data'];
    if (data is Map) {
      yield Map<String, dynamic>.from(data);
    }
    final user = json['user'];
    if (user is Map) {
      yield Map<String, dynamic>.from(user);
    }
  }
}

class BankCode {
  BankCode({required this.id, required this.bankCode, required this.bankName});

  final int? id;
  final String bankCode;
  final String bankName;

  factory BankCode.fromJson(Map<String, dynamic> json) {
    final parsedId = int.tryParse((json['id'] ?? '').toString());
    return BankCode(
      id: parsedId,
      bankCode: (json['bankCode'] ?? '').toString().trim(),
      bankName: (json['bankName'] ?? '').toString().trim(),
    );
  }
}
