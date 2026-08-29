import 'package:get/get.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/services/product_service.dart';

class ReportController extends GetxController {
  final SaleService _saleService = Get.find<SaleService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final ProductService _productService = Get.find<ProductService>();

  // Helper to check if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // 1. Omzet (Total Penjualan)
  double get todayOmzet {
    return _saleService.sales.where((s) => _isToday(s.createdAt)).fold(0, (sum, s) => sum + s.totalAmount);
  }

  // 2. Cash In Hand (Uang Tunai Masuk Hari Ini)
  double get todayCashInHand {
    return _saleService.sales.where((s) => _isToday(s.createdAt)).fold(0, (sum, s) => sum + s.paidAmount);
  }

  // 3. Modal Barang Terjual (COGS)
  double get todayCapital {
    double totalCapital = 0;
    final todaySales = _saleService.sales.where((s) => _isToday(s.createdAt));
    
    for (var sale in todaySales) {
      for (var item in sale.items) {
        // Cari harga modal dari master produk
        final product = _productService.products.firstWhereOrNull((p) => p.id == item.productId);
        if (product != null) {
          totalCapital += (product.capitalPrice * item.quantity);
        }
      }
    }
    return totalCapital;
  }

  // 4. Laba Kotor (Omzet - Modal)
  double get todayGrossProfit => todayOmzet - todayCapital;

  // 5. Total Pengeluaran (Expense)
  double get todayExpense => _expenseService.getTotalExpenseByDate(DateTime.now());

  // 6. Laba Bersih (Laba Kotor - Pengeluaran)
  double get todayNetProfit => todayGrossProfit - todayExpense;

  void refreshData() {
    update();
  }
}
