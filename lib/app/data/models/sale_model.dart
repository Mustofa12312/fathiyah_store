// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price; // Harga saat transaksi
  final double subtotal; // quantity * price

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
      price: json['price'],
      subtotal: json['subtotal'],
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
  final double subtotal;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus; // 'lunas', 'sebagian', 'belum_dibayar'
  final String paymentMethod;
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
      subtotal: (json['subtotal'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'],
      paymentMethod: json['paymentMethod'],
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
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
