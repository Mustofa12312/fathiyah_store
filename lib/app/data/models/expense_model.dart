class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final DateTime createdAt;
  final String? cashierId;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.cashierId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ExpenseModel(
      id: documentId,
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      cashierId: json['cashierId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'cashierId': cashierId,
    };
  }
}
