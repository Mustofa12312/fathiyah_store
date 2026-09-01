import 'dart:io';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
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
    ever(_productService.products, (_) => update());
  }

  int get totalStockAssetValue {
    int total = 0;
    for (var product in _productService.products) {
      if (product.stock > 0) {
        total += (product.purchasePrice * product.stock);
      }
    }
    return total;
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
  int get filteredOmzet => _calculator.filteredOmzet;

  // 2. Cash In Hand
  int get filteredCashInHand => _calculator.filteredCashInHand;

  // 3. Modal Barang Terjual
  int get filteredCapital => _calculator.filteredCapital;

  // 4. Laba Kotor
  int get filteredGrossProfit => _calculator.filteredGrossProfit;

  // 5. Total Pengeluaran
  int get filteredExpense => _calculator.filteredExpense;

  // 6. Laba Bersih
  int get filteredNetProfit => _calculator.filteredNetProfit;

  void refreshData() {
    update();
  }

  ChartDataPayload get chartData => _calculator.getChartData();
  
  String get chartTitle {
    switch (selectedFilter.value) {
      case 'Bulan Ini': return 'Tren Bulan Ini';
      case 'Semua': 
      case 'Tahun Ini': return 'Tren Tahun Ini';
      default: return 'Tren 7 Hari Terakhir';
    }
  }

  Future<void> exportExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Laporan'];
      excel.setDefaultSheet('Laporan');

      // Add Headers
      sheetObject.appendRow([TextCellValue('Laporan Keuangan Le\' iil store')]);
      sheetObject.appendRow([TextCellValue('Filter: ${selectedFilter.value}')]);
      sheetObject.appendRow([TextCellValue('Tanggal Cetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}')]);
      sheetObject.appendRow([TextCellValue('')]);
      
      // Add Column Headers
      sheetObject.appendRow([
        TextCellValue('Kategori'), 
        TextCellValue('Nominal (Rp)')
      ]);

      // Add Data Rows
      sheetObject.appendRow([TextCellValue('Omzet (Total Penjualan)'), IntCellValue(filteredOmzet)]);
      sheetObject.appendRow([TextCellValue('Uang Tunai Masuk'), IntCellValue(filteredCashInHand)]);
      sheetObject.appendRow([TextCellValue('Modal Terjual (COGS)'), IntCellValue(filteredCapital)]);
      sheetObject.appendRow([TextCellValue('Laba Kotor'), IntCellValue(filteredGrossProfit)]);
      sheetObject.appendRow([TextCellValue('Total Pengeluaran'), IntCellValue(filteredExpense)]);
      sheetObject.appendRow([TextCellValue('Laba Bersih'), IntCellValue(filteredNetProfit)]);

      var fileBytes = excel.save();
      
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/Laporan_Leiil_Store_${DateFormat('ddMMMyyyy').format(DateTime.now())}.xlsx';
      final File file = File(filePath);
      
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        await Share.shareXFiles([XFile(filePath)], text: 'Laporan Keuangan Le\' iil store');
      }

    } catch (e) {
      Get.snackbar('Error', 'Gagal mengekspor laporan: $e');
    }
  }
}
