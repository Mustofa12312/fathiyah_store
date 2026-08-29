// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
class AuditLogModel {
  final String id;
  final String userId;
  final String userName;
  final String action; // 'CREATE', 'UPDATE', 'DELETE'
  final String entity; // 'PRODUCT', 'CUSTOMER', 'SALE', 'USER', 'EXPENSE'
  final String entityId;
  final String details;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.details,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json, String documentId) {
    return AuditLogModel(
      id: documentId,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      action: json['action'] ?? '',
      entity: json['entity'] ?? '',
      entityId: json['entityId'] ?? '',
      details: json['details'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'action': action,
      'entity': entity,
      'entityId': entityId,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
