import '../../data/models/sale_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/product_model.dart';

class FinancialReportCalculator {
  final List<SaleModel> sales;
  final List<ExpenseModel> expenses;
  final List<ProductModel> products;
  final String filter;

  FinancialReportCalculator({
    required this.sales,
    required this.expenses,
    required this.products,
    required this.filter,
  });

  bool _isWithinFilter(DateTime date) {
    final now = DateTime.now();
    switch (filter) {
      case 'Hari Ini':
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case 'Minggu Ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 7));
        return date.isAfter(start.subtract(const Duration(milliseconds: 1))) && date.isBefore(end);
      case 'Bulan Ini':
        return date.year == now.year && date.month == now.month;
      case 'Semua':
      default:
        return true;
    }
  }

  // 1. Omzet
  int get filteredOmzet {
    return sales.where((s) => _isWithinFilter(s.createdAt)).fold(0, (sum, s) => sum + s.totalAmount);
  }

  // 2. Cash In Hand
  int get filteredCashInHand {
    return sales.where((s) => _isWithinFilter(s.createdAt)).fold(0, (sum, s) => sum + s.paidAmount);
  }

  // 3. Modal Barang Terjual
  int get filteredCapital {
    int totalCapital = 0;
    final filteredSales = sales.where((s) => _isWithinFilter(s.createdAt));
    
    for (var sale in filteredSales) {
      for (var item in sale.items) {
        final productIndex = products.indexWhere((p) => p.id == item.productId);
        if (productIndex != -1) {
          totalCapital += (products[productIndex].purchasePrice * item.quantity);
        }
      }
    }
    return totalCapital;
  }

  // 4. Laba Kotor
  int get filteredGrossProfit => filteredOmzet - filteredCapital;

  // 5. Total Pengeluaran
  int get filteredExpense {
    return expenses.where((e) => _isWithinFilter(e.createdAt)).fold(0, (sum, e) => sum + e.amount);
  }

  // 6. Laba Bersih
  int get filteredNetProfit => filteredGrossProfit - filteredExpense;

  // Chart Data (Last 7 days omzet)
  List<double> getWeeklyOmzetData() {
    final now = DateTime.now();
    List<double> weeklyData = List.filled(7, 0.0);
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final omzet = sales.where((s) {
        return s.createdAt.year == date.year && s.createdAt.month == date.month && s.createdAt.day == date.day;
      }).fold(0, (sum, s) => sum + s.totalAmount);
      
      weeklyData[6 - i] = omzet.toDouble();
    }
    
    return weeklyData;
  }
  
  List<double> getWeeklyExpenseData() {
    final now = DateTime.now();
    List<double> weeklyData = List.filled(7, 0.0);
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final expense = expenses.where((s) {
        return s.createdAt.year == date.year && s.createdAt.month == date.month && s.createdAt.day == date.day;
      }).fold(0, (sum, s) => sum + s.amount);
      
      weeklyData[6 - i] = expense.toDouble();
    }
    
    return weeklyData;
  }
}
