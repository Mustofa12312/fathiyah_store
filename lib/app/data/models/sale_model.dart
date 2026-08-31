import '../../core/utils/money_engine.dart';

class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final int price; // Harga saat transaksi
  final int subtotal; // quantity * price

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: MoneyEngine.parse(json['price']),
      subtotal: MoneyEngine.parse(json['subtotal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

class SaleModel {
  final String id;
  final String? customerId;
  final String customerType; // 'general' or 'vip'
  final String cashierId;
  final String cashierName;
  final int subtotal;
  final int totalAmount;
  final int paidAmount;
  final int remainingAmount;
  final String paymentStatus; // 'lunas', 'sebagian', 'belum_dibayar'
  final String paymentMethod;
  final List<Map<String, dynamic>>? splitPayments;
  final String transactionStatus; // 'active', 'voided', 'refunded'
  final List<SaleItemModel> items;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    this.customerId,
    required this.customerType,
    required this.cashierId,
    required this.cashierName,
    required this.subtotal,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.splitPayments,
    this.transactionStatus = 'active',
    required this.items,
    required this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json, String documentId) {
    return SaleModel(
      id: documentId,
      customerId: json['customerId'],
      customerType: json['customerType'],
      cashierId: json['cashierId'],
      cashierName: json['cashierName'],
      subtotal: MoneyEngine.parse(json['subtotal']),
      totalAmount: MoneyEngine.parse(json['totalAmount']),
      paidAmount: MoneyEngine.parse(json['paidAmount']),
      remainingAmount: MoneyEngine.parse(json['remainingAmount']),
      paymentStatus: json['paymentStatus'] ?? 'belum_dibayar',
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      splitPayments: json['splitPayments'] != null 
          ? List<Map<String, dynamic>>.from(json['splitPayments']) 
          : null,
      transactionStatus: json['transactionStatus'] ?? 'active',
      items: (json['items'] as List).map((i) => SaleItemModel.fromJson(i)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerType': customerType,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'subtotal': subtotal,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'splitPayments': splitPayments,
      'transactionStatus': transactionStatus,
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
