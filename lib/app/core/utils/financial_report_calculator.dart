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

  ChartDataPayload getChartData() {
    final now = DateTime.now();
    List<String> labels = [];
    List<double> omzetData = [];
    List<double> expenseData = [];

    if (filter == 'Bulan Ini') {
      labels = ['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4'];
      omzetData = List.filled(4, 0.0);
      expenseData = List.filled(4, 0.0);
      
      final currentMonthSales = sales.where((s) => s.createdAt.year == now.year && s.createdAt.month == now.month);
      for (var s in currentMonthSales) {
        int week = (s.createdAt.day - 1) ~/ 7;
        if (week > 3) week = 3;
        omzetData[week] += s.totalAmount;
      }
      
      final currentMonthExpense = expenses.where((s) => s.createdAt.year == now.year && s.createdAt.month == now.month);
      for (var s in currentMonthExpense) {
        int week = (s.createdAt.day - 1) ~/ 7;
        if (week > 3) week = 3;
        expenseData[week] += s.amount;
      }
    } else if (filter == 'Semua' || filter == 'Tahun Ini') {
      labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      omzetData = List.filled(12, 0.0);
      expenseData = List.filled(12, 0.0);
      
      final currentYearSales = sales.where((s) => s.createdAt.year == now.year);
      for (var s in currentYearSales) {
        omzetData[s.createdAt.month - 1] += s.totalAmount;
      }
      
      final currentYearExpense = expenses.where((s) => s.createdAt.year == now.year);
      for (var s in currentYearExpense) {
        expenseData[s.createdAt.month - 1] += s.amount;
      }
    } else {
      labels = List.filled(7, '');
      omzetData = List.filled(7, 0.0);
      expenseData = List.filled(7, 0.0);
      
      final indoDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        labels[i] = indoDays[date.weekday - 1];
        
        omzetData[i] = sales.where((s) {
          return s.createdAt.year == date.year && s.createdAt.month == date.month && s.createdAt.day == date.day;
        }).fold(0.0, (sum, s) => sum + s.totalAmount);
        
        expenseData[i] = expenses.where((s) {
          return s.createdAt.year == date.year && s.createdAt.month == date.month && s.createdAt.day == date.day;
        }).fold(0.0, (sum, s) => sum + s.amount);
      }
    }
    
    return ChartDataPayload(labels, omzetData, expenseData);
  }
}

class ChartDataPayload {
  final List<String> labels;
  final List<double> omzet;
  final List<double> expense;

  ChartDataPayload(this.labels, this.omzet, this.expense);
}
