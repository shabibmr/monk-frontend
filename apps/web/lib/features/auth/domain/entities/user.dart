import 'package:equatable/equatable.dart';
import 'package:monk_shared/monk_shared.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.fullName,
    this.phone,
  });

  final String id;
  final String email;
  final UserRole role;
  final UserStatus status;
  final String? fullName;
  final String? phone;

  @override
  List<Object?> get props => [id, email, role, status, fullName, phone];
}

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  @override
  List<Object?> get props => [user, accessToken, refreshToken, expiresIn];
}

class DeviceSession extends Equatable {
  const DeviceSession({
    required this.id,
    required this.current,
    this.userAgent,
    this.ipAddress,
    this.createdAt,
  });

  final String id;
  final bool current;
  final String? userAgent;
  final String? ipAddress;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, current, userAgent, ipAddress, createdAt];
}
