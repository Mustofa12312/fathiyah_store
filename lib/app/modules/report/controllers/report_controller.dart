// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'dart:io';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/expense_service.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/financial_report_calculator.dart';

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

  FinancialReportCalculator get _calculator {
    return FinancialReportCalculator(
      sales: _saleService.sales,
      expenses: _expenseService.expenses,
      products: _productService.products,
      filter: selectedFilter.value,
    );
  }



  // 1. Omzet
  double get filteredOmzet => _calculator.filteredOmzet;

  // 2. Cash In Hand
  double get filteredCashInHand => _calculator.filteredCashInHand;

  // 3. Modal Barang Terjual
  double get filteredCapital => _calculator.filteredCapital;

  // 4. Laba Kotor
  double get filteredGrossProfit => _calculator.filteredGrossProfit;

  // 5. Total Pengeluaran
  double get filteredExpense => _calculator.filteredExpense;

  // 6. Laba Bersih
  double get filteredNetProfit => _calculator.filteredNetProfit;

  void refreshData() {
    update();
  }

  // Data for Chart (Last 7 days omzet)
  List<double> getWeeklyOmzetData() {
    return _calculator.getWeeklyOmzetData();
  }
  
  List<double> getWeeklyExpenseData() {
    return _calculator.getWeeklyExpenseData();
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
