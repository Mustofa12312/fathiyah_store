class PaymentModel {
  final String id;
  final String saleId;
  final String customerId;
  final double amount;
  final String paymentMethod;
  final String cashierId;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.saleId,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    required this.cashierId,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json, String documentId) {
    return PaymentModel(
      id: documentId,
      saleId: json['saleId'],
      customerId: json['customerId'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      cashierId: json['cashierId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleId': saleId,
      'customerId': customerId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'cashierId': cashierId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
