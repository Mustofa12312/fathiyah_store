// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
class StockMovementModel {
  final String id;
  final String productId;
  final String productName;
  final int quantity; // Positive for IN, Negative for OUT
  final String type; // 'INITIAL', 'PURCHASE', 'SALE', 'DAMAGE', 'LOSS', 'CORRECTION', 'RETURN'
  final String userId;
  final String userName;
  final String note;
  final DateTime createdAt;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.userId,
    required this.userName,
    this.note = '',
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json, String documentId) {
    return StockMovementModel(
      id: documentId,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'type': type,
      'userId': userId,
      'userName': userName,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
