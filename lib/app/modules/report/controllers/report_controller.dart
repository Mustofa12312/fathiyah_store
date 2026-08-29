// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'dart:io';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/services/product_service.dart';

class ReportController extends GetxController {
  final SaleService _saleService = Get.find<SaleService>();
  final ExpenseService _expenseService = Get.find<ExpenseService>();
  final ProductService _productService = Get.find<ProductService>();

  final RxString selectedFilter = 'Hari Ini'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_saleService.sales, (_) => update());
    ever(_expenseService.expenses, (_) => update());
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  bool _isWithinFilter(DateTime date) {
    final now = DateTime.now();
    switch (selectedFilter.value) {
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
  double get filteredOmzet {
    return _saleService.sales.where((s) => _isWithinFilter(s.createdAt)).fold(0, (sum, s) => sum + s.totalAmount);
  }

  // 2. Cash In Hand
  double get filteredCashInHand {
    return _saleService.sales.where((s) => _isWithinFilter(s.createdAt)).fold(0, (sum, s) => sum + s.paidAmount);
  }

  // 3. Modal Barang Terjual
  double get filteredCapital {
    double totalCapital = 0;
    final filteredSales = _saleService.sales.where((s) => _isWithinFilter(s.createdAt));
    
    for (var sale in filteredSales) {
      for (var item in sale.items) {
        final product = _productService.products.firstWhereOrNull((p) => p.id == item.productId);
        if (product != null) {
          totalCapital += (product.purchasePrice * item.quantity);
        }
      }
    }
    return totalCapital;
  }

  // 4. Laba Kotor
  double get filteredGrossProfit => filteredOmzet - filteredCapital;

  // 5. Total Pengeluaran
  double get filteredExpense {
    return _expenseService.expenses.where((e) => _isWithinFilter(e.createdAt)).fold(0, (sum, e) => sum + e.amount);
  }

  // 6. Laba Bersih
  double get filteredNetProfit => filteredGrossProfit - filteredExpense;

  void refreshData() {
    update();
  }

  // Data for Chart (Last 7 days omzet)
  List<double> getWeeklyOmzetData() {
    final now = DateTime.now();
    List<double> weeklyData = List.filled(7, 0.0);
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final omzet = _saleService.sales.where((s) {
        return s.createdAt.year == date.year && s.createdAt.month == date.month && s.createdAt.day == date.day;
      }).fold(0.0, (sum, s) => sum + s.totalAmount);
      
      // Store in reverse order so index 0 is oldest day, index 6 is today
      weeklyData[6 - i] = omzet;
    }
    
    return weeklyData;
  }
  
  List<double> getWeeklyExpenseData() {
    final now = DateTime.now();
    List<double> weeklyData = List.filled(7, 0.0);
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final expense = _expenseService.expenses.where((s) {
        return s.createdAt.year == date.year && s.createdAt.month == date.month && s.createdAt.day == date.day;
      }).fold(0.0, (sum, s) => sum + s.amount);
      
      weeklyData[6 - i] = expense;
    }
    
    return weeklyData;
  }

  Future<void> exportCSV() async {
    try {
      List<List<dynamic>> rows = [
        ['Laporan Keuangan Fathiyah Store'],
        ['Filter', selectedFilter.value],
        ['Tanggal Cetak', DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())],
        [],
        ['Kategori', 'Nominal (Rp)'],
        ['Omzet (Total Penjualan)', filteredOmzet],
        ['Uang Tunai Masuk', filteredCashInHand],
        ['Total Piutang Baru', filteredOmzet - filteredCashInHand],
        ['Modal Terjual (COGS)', filteredCapital],
        ['Laba Kotor', filteredGrossProfit],
        ['Total Pengeluaran', filteredExpense],
        ['Laba Bersih', filteredNetProfit],
      ];

      String csvData = Csv().encode(rows);

      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/laporan_fathiyah_store.csv';
      final File file = File(filePath);

      await file.writeAsString(csvData);

      Get.snackbar('Sukses', 'Laporan berhasil diekspor ke $filePath');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengekspor laporan: $e');
    }
  }
}
