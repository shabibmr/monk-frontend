import 'package:equatable/equatable.dart';

class AgencyAsset extends Equatable {
  const AgencyAsset({
    required this.id,
    required this.cardId,
    required this.title,
    required this.fileUrl,
    required this.fileType,
    required this.status, // 'pending', 'approved', 'rejected'
    required this.uploadedBy,
    required this.uploadedAt,
    this.notes,
  });

  final String id;
  final String cardId;
  final String title;
  final String fileUrl;
  final String fileType;
  final String status;
  final String uploadedBy;
  final String uploadedAt;
  final String? notes;

  AgencyAsset copyWith({
    String? id,
    String? cardId,
    String? title,
    String? fileUrl,
    String? fileType,
    String? status,
    String? uploadedBy,
    String? uploadedAt,
    String? notes,
  }) {
    return AgencyAsset(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      title: title ?? this.title,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      status: status ?? this.status,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cardId,
        title,
        fileUrl,
        fileType,
        status,
        uploadedBy,
        uploadedAt,
        notes,
      ];
}
