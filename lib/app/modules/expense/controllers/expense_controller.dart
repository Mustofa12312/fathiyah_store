// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/models/expense_model.dart';

class ExpenseController extends GetxController {
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  List<ExpenseModel> get todayExpenses => _expenseService.getExpensesByDate(DateTime.now());

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }

  void saveExpense() {
    final amountStr = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(amountStr) ?? 0;
    
    if (amount <= 0 || descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Harap isi keterangan dan nominal pengeluaran');
      return;
    }

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      description: descriptionController.text.trim(),
      amount: amount,
      createdAt: DateTime.now(),
      cashierId: 'cashier_1',
    );

    _expenseService.addExpense(expense);
    
    descriptionController.clear();
    amountController.clear();
    
    update(); // refresh list
    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar('Sukses', 'Pengeluaran berhasil dicatat', backgroundColor: Colors.green.shade100);
    });
  }
}
