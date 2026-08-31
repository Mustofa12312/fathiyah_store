// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import '../../core/utils/money_engine.dart';

class ShiftModel {
  final String id;
  final String cashierId;
  final String cashierName;
  final DateTime startTime;
  final DateTime? endTime;
  final int startBalance;
  final int? endBalance;
  final int totalSalesCash;
  final int totalExpensesCash;
  final String status; // 'open' or 'closed'

  ShiftModel({
    required this.id,
    required this.cashierId,
    required this.cashierName,
    required this.startTime,
    this.endTime,
    required this.startBalance,
    this.endBalance,
    this.totalSalesCash = 0,
    this.totalExpensesCash = 0,
    this.status = 'open',
  });

  int get expectedBalance => startBalance + totalSalesCash - totalExpensesCash;
  int get difference => (endBalance ?? 0) - expectedBalance;

  factory ShiftModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ShiftModel(
      id: documentId,
      cashierId: json['cashierId'] ?? '',
      cashierName: json['cashierName'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      startBalance: MoneyEngine.parse(json['startBalance']),
      endBalance: json['endBalance'] != null ? MoneyEngine.parse(json['endBalance']) : null,
      totalSalesCash: MoneyEngine.parse(json['totalSalesCash']),
      totalExpensesCash: MoneyEngine.parse(json['totalExpensesCash']),
      status: json['status'] ?? 'open',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cashierId': cashierId,
      'cashierName': cashierName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startBalance': startBalance,
      'endBalance': endBalance,
      'totalSalesCash': totalSalesCash,
      'totalExpensesCash': totalExpensesCash,
      'status': status,
    };
  }

  ShiftModel copyWith({
    String? id,
    String? cashierId,
    String? cashierName,
    DateTime? startTime,
    DateTime? endTime,
    int? startBalance,
    int? endBalance,
    int? totalSalesCash,
    int? totalExpensesCash,
    String? status,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startBalance: startBalance ?? this.startBalance,
      endBalance: endBalance ?? this.endBalance,
      totalSalesCash: totalSalesCash ?? this.totalSalesCash,
      totalExpensesCash: totalExpensesCash ?? this.totalExpensesCash,
      status: status ?? this.status,
    );
  }
}
