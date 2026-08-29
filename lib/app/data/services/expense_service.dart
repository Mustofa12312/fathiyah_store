import 'package:get/get.dart';
import '../models/expense_model.dart';

class ExpenseService extends GetxService {
  final expenses = <ExpenseModel>[].obs;

  void addExpense(ExpenseModel expense) {
    expenses.add(expense);
  }

  List<ExpenseModel> getExpensesByDate(DateTime date) {
    return expenses.where((e) {
      return e.createdAt.year == date.year &&
             e.createdAt.month == date.month &&
             e.createdAt.day == date.day;
    }).toList();
  }

  double getTotalExpenseByDate(DateTime date) {
    return getExpensesByDate(date).fold(0, (sum, e) => sum + e.amount);
  }
}
