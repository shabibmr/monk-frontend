import 'package:api_client/api_client.dart';
import 'package:monk_shared/monk_shared.dart';

import '../../domain/entities/user.dart';

User mapUser(PublicUserDto dto) {
  return User(
    id: dto.id,
    email: dto.email,
    role: UserRole.fromApi(dto.role),
    status: UserStatus.fromApi(dto.status),
    fullName: dto.fullName,
    phone: dto.phone,
  );
}

DeviceSession mapSession(SessionDto dto) {
  return DeviceSession(
    id: dto.id,
    current: dto.current,
    userAgent: dto.userAgent,
    ipAddress: dto.ipAddress,
    createdAt: dto.createdAt,
  );
}
