// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import '../../core/utils/money_engine.dart';

class ExpenseModel {
  final String id;
  final String description;
  final int amount;
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
      amount: MoneyEngine.parse(json['amount']),
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
