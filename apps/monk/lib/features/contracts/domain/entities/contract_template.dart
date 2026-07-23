import 'package:equatable/equatable.dart';

class ContractTemplate extends Equatable {
  const ContractTemplate({
    required this.id,
    required this.key,
    required this.name,
    required this.body,
    this.parameters = const [],
    this.version = '1.0',
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String key;
  final String name;
  final String body;
  final List<String> parameters;
  final String version;
  final bool isActive;
  final String? createdAt;

  ContractTemplate copyWith({
    String? id,
    String? key,
    String? name,
    String? body,
    List<String>? parameters,
    String? version,
    bool? isActive,
    String? createdAt,
  }) {
    return ContractTemplate(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      body: body ?? this.body,
      parameters: parameters ?? this.parameters,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ContractTemplate.fromJson(Map<String, dynamic> json) {
    return ContractTemplate(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      version: json['version'] as String? ?? '1.0',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'body': body,
        'parameters': parameters,
        'version': version,
        'isActive': isActive,
        'createdAt': createdAt,
      };

  @override
  List<Object?> get props => [
        id,
        key,
        name,
        body,
        parameters,
        version,
        isActive,
        createdAt,
      ];
}
