import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/models/expense_model.dart';
import '../../../core/errors/app_exceptions.dart';

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
      final ex = ValidationException('Keterangan dan nominal pengeluaran wajib diisi (minimal Rp 1)');
      Get.snackbar(
        ex.prefix, 
        ex.message, 
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: Icon(Icons.error_outline_rounded, color: Colors.red.shade900),
      );
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
