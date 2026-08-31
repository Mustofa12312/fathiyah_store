// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import 'shift_service.dart';

class ExpenseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ShiftService _shiftService = Get.find<ShiftService>();
  final expenses = <ExpenseModel>[].obs;

  Future<ExpenseService> init() async {
    _firestore.collection('expenses').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      expenses.value = snapshot.docs.map((doc) => ExpenseModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => debugPrint('ExpenseService Error: $e'));
    return this;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).set(expense.toJson());
    
    // Assume all current expenses are cash since no paymentMethod exists in ExpenseModel yet
    await _shiftService.recordCashExpense(expense.amount);
  }

  List<ExpenseModel> getExpensesByDate(DateTime date) {
    return expenses.where((e) {
      return e.createdAt.year == date.year &&
             e.createdAt.month == date.month &&
             e.createdAt.day == date.day;
    }).toList();
  }

  int getTotalExpenseByDate(DateTime date) {
    return getExpensesByDate(date).fold(0, (total, e) => total + e.amount);
  }
}
