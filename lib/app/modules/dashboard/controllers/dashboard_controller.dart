import 'package:get/get.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/expense_service.dart';

class DashboardController extends GetxController {
  final currentIndex = 0.obs;

  final SaleService _saleService = Get.find<SaleService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();

  void changePage(int index) {
    currentIndex.value = index;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  double get todaySales {
    return _saleService.sales
        .where((s) => _isToday(s.createdAt))
        .fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  double get todayCashIn {
    return _saleService.sales
        .where((s) => _isToday(s.createdAt))
        .fold(0.0, (sum, item) => sum + item.paidAmount);
  }

  double get todayDebt {
    return _saleService.sales
        .where((s) => _isToday(s.createdAt))
        .fold(0.0, (sum, item) => sum + item.remainingAmount);
  }

  double get todayExpenses {
    return _expenseService.expenses
        .where((e) => _isToday(e.createdAt))
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}
