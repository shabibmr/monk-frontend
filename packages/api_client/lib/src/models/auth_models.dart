class PublicUserDto {
  const PublicUserDto({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.fullName,
    this.phone,
    this.tcAcceptedAt,
    this.emailVerifiedAt,
    this.createdAt,
  });

  final String id;
  final String email;
  final String role;
  final String status;
  final String? fullName;
  final String? phone;
  final DateTime? tcAcceptedAt;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;

  factory PublicUserDto.fromJson(Map<String, dynamic> json) {
    return PublicUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      tcAcceptedAt: _parseDate(json['tcAcceptedAt']),
      emailVerifiedAt: _parseDate(json['emailVerifiedAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

class TokenPairDto {
  const TokenPairDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  factory TokenPairDto.fromJson(Map<String, dynamic> json) {
    return TokenPairDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }
}

class LoginResponseDto {
  const LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final PublicUserDto user;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      user: PublicUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class RegisterResponseDto {
  const RegisterResponseDto({
    required this.user,
    this.verificationTokenDev,
  });

  final PublicUserDto user;
  final String? verificationTokenDev;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      user: PublicUserDto.fromJson(json['user'] as Map<String, dynamic>),
      verificationTokenDev: json['verificationTokenDev'] as String?,
    );
  }
}

class SessionDto {
  const SessionDto({
    required this.id,
    required this.current,
    this.userAgent,
    this.ipAddress,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final bool current;
  final String? userAgent;
  final String? ipAddress;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    return SessionDto(
      id: json['id'] as String,
      current: json['current'] as bool? ?? false,
      userAgent: json['userAgent'] as String?,
      ipAddress: json['ipAddress'] as String?,
      createdAt: _parseDate(json['createdAt']),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }
}

class SessionsListDto {
  const SessionsListDto({required this.data});
  final List<SessionDto> data;

  factory SessionsListDto.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? const [];
    return SessionsListDto(
      data: list
          .map((e) => SessionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
