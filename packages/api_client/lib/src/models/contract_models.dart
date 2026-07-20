class UsageRightsDto {
  const UsageRightsDto({
    required this.organicReuse,
    required this.paidAmplification,
    required this.durationDays,
    required this.territory,
    this.channels = const [],
    this.exclusivityCategory,
    this.exclusivityDays,
  });

  final bool organicReuse;
  final bool paidAmplification;
  final int durationDays;
  final String territory;
  final List<String> channels;
  final String? exclusivityCategory;
  final int? exclusivityDays;

  factory UsageRightsDto.fromJson(Map<String, dynamic> json) {
    final channels = json['channels'];
    return UsageRightsDto(
      organicReuse: json['organicReuse'] as bool? ?? false,
      paidAmplification: json['paidAmplification'] as bool? ?? false,
      durationDays: json['durationDays'] as int? ?? 0,
      territory: json['territory'] as String? ?? '',
      channels: channels is List
          ? channels.map((e) => e.toString()).toList()
          : const [],
      exclusivityCategory: json['exclusivityCategory'] as String?,
      exclusivityDays: json['exclusivityDays'] as int?,
    );
  }
}

class ContractAcceptanceDto {
  const ContractAcceptanceDto({
    required this.party,
    required this.acceptedByUserId,
    required this.contentHash,
    this.acceptedAt,
  });

  final String party;
  final String acceptedByUserId;
  final String contentHash;
  final String? acceptedAt;

  factory ContractAcceptanceDto.fromJson(Map<String, dynamic> json) {
    return ContractAcceptanceDto(
      party: json['party'] as String? ?? '',
      acceptedByUserId: json['acceptedByUserId'] as String? ?? '',
      contentHash: json['contentHash'] as String? ?? '',
      acceptedAt: json['acceptedAt']?.toString(),
    );
  }
}

class ContractDto {
  const ContractDto({
    required this.id,
    required this.collaborationId,
    required this.status,
    required this.contentHash,
    this.templateKey,
    this.templateVersion,
    this.pdfUrl,
    this.pdfFileId,
    this.usageRights,
    this.acceptances = const [],
    this.bothPartiesAccepted = false,
    this.createdAt,
  });

  final String id;
  final String collaborationId;
  final String status;
  final String contentHash;
  final String? templateKey;
  final String? templateVersion;
  final String? pdfUrl;
  final String? pdfFileId;
  final UsageRightsDto? usageRights;
  final List<ContractAcceptanceDto> acceptances;
  final bool bothPartiesAccepted;
  final String? createdAt;

  factory ContractDto.fromJson(Map<String, dynamic> json) {
    final rights = json['usageRights'];
    final acceptances = json['acceptances'] as List<dynamic>? ?? const [];
    return ContractDto(
      id: json['id'] as String,
      collaborationId: json['collaborationId'] as String? ?? '',
      status: json['status'] as String? ?? 'generated',
      contentHash: json['contentHash'] as String? ?? '',
      templateKey: json['templateKey'] as String?,
      templateVersion: json['templateVersion'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
      pdfFileId: json['pdfFileId'] as String?,
      usageRights: rights is Map<String, dynamic>
          ? UsageRightsDto.fromJson(rights)
          : null,
      acceptances: acceptances
          .map(
            (e) => ContractAcceptanceDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      bothPartiesAccepted: json['bothPartiesAccepted'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
    );
  }
}
