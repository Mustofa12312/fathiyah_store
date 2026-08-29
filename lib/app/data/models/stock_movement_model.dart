class StockMovementModel {
  final String id;
  final String productId;
  final int quantity;
  final String type; // 'in', 'out', 'correction', 'waste'
  final String userId;
  final String notes;
  final DateTime createdAt;

  StockMovementModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.type,
    required this.userId,
    required this.notes,
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json, String documentId) {
    return StockMovementModel(
      id: documentId,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      type: json['type'] as String,
      userId: json['userId'] as String,
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'type': type,
      'userId': userId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
