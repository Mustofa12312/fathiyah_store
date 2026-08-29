import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final expenses = <ExpenseModel>[].obs;

  Future<ExpenseService> init() async {
    _firestore.collection('expenses').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      expenses.value = snapshot.docs.map((doc) => ExpenseModel.fromJson(doc.data(), doc.id)).toList();
    });
    return this;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection('expenses').doc(expense.id).set(expense.toJson());
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
