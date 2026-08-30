import 'package:flutter_test/flutter_test.dart';
import 'package:fathiyah_store/app/core/utils/financial_report_calculator.dart';
import 'package:fathiyah_store/app/data/models/sale_model.dart';
import 'package:fathiyah_store/app/data/models/expense_model.dart';
import 'package:fathiyah_store/app/data/models/product_model.dart';

void main() {
  group('FinancialReportCalculator Tests', () {
    final now = DateTime.now();
    
    // Setup dummy data
    final List<ProductModel> dummyProducts = [
      ProductModel(
        id: 'p1', 
        name: 'Produk A', 
        categoryId: 'c1', 
        unit: 'Pcs', 
        purchasePrice: 10000, 
        sellingPrice: 15000, 
        stock: 50, 
        minimumStock: 5, 
        createdAt: now, 
        updatedAt: now
      ),
      ProductModel(
        id: 'p2', 
        name: 'Produk B', 
        categoryId: 'c1', 
        unit: 'Pcs', 
        purchasePrice: 20000, 
        sellingPrice: 30000, 
        stock: 30, 
        minimumStock: 5, 
        createdAt: now, 
        updatedAt: now
      ),
    ];

    final List<SaleModel> dummySales = [
      SaleModel(
        id: 's1',
        customerId: 'cust1',
        customerType: 'general',
        cashierId: 'cashier1',
        cashierName: 'Cashier 1',
        subtotal: 60000,
        totalAmount: 60000, // Total Omzet = 60000
        paidAmount: 60000,  // Cash in hand = 60000
        remainingAmount: 0,
        paymentStatus: 'lunas',
        paymentMethod: 'cash',
        items: [
          SaleItemModel(productId: 'p1', productName: 'Produk A', quantity: 2, price: 15000, subtotal: 30000), // Modal = 20000, Laba = 10000
          SaleItemModel(productId: 'p2', productName: 'Produk B', quantity: 1, price: 30000, subtotal: 30000), // Modal = 20000, Laba = 10000
        ],
        createdAt: now,
      ),
      SaleModel(
        id: 's2',
        customerId: 'cust2',
        customerType: 'general',
        cashierId: 'cashier1',
        cashierName: 'Cashier 1',
        subtotal: 15000,
        totalAmount: 15000, // Total Omzet = 15000
        paidAmount: 10000,  // Cash in hand = 10000 (Piutang 5000)
        remainingAmount: 5000,
        paymentStatus: 'sebagian',
        paymentMethod: 'cash',
        items: [
          SaleItemModel(productId: 'p1', productName: 'Produk A', quantity: 1, price: 15000, subtotal: 15000), // Modal = 10000, Laba = 5000
        ],
        createdAt: now, // Hari ini
      ),
    ];

    final List<ExpenseModel> dummyExpenses = [
      ExpenseModel(
        id: 'e1',
        description: 'Beli Lakban',
        amount: 5000,
        createdAt: now, // Hari ini
      ),
      ExpenseModel(
        id: 'e2',
        description: 'Beli Kresek',
        amount: 3000,
        createdAt: now.subtract(const Duration(days: 1)), // Kemarin, tidak boleh masuk filter "Hari Ini"
      )
    ];

    test('Filter "Hari Ini" calculates omzet and capital correctly', () {
      final calculator = FinancialReportCalculator(
        sales: dummySales,
        expenses: dummyExpenses,
        products: dummyProducts,
        filter: 'Hari Ini',
      );

      // Total Omzet = 60000 + 15000 = 75000
      expect(calculator.filteredOmzet, 75000);
      
      // Total Cash in Hand = 60000 + 10000 = 70000
      expect(calculator.filteredCashInHand, 70000);

      // Total Capital = (2 * 10000 + 1 * 20000) + (1 * 10000) = 40000 + 10000 = 50000
      expect(calculator.filteredCapital, 50000);

      // Laba Kotor = Omzet - Capital = 75000 - 50000 = 25000
      expect(calculator.filteredGrossProfit, 25000);
      
      // Pengeluaran "Hari Ini" hanya 'Beli Lakban' = 5000
      expect(calculator.filteredExpense, 5000);

      // Laba Bersih = Laba Kotor - Pengeluaran = 25000 - 5000 = 20000
      expect(calculator.filteredNetProfit, 20000);
    });

    test('Filter "Semua" calculates all expenses including past ones', () {
      final calculator = FinancialReportCalculator(
        sales: dummySales,
        expenses: dummyExpenses,
        products: dummyProducts,
        filter: 'Semua',
      );

      // Total Pengeluaran = Beli Lakban (5000) + Beli Kresek (3000) = 8000
      expect(calculator.filteredExpense, 8000);
    });
  });
}
