import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fathiyah_store/app/data/services/sale_service.dart';
import 'package:fathiyah_store/app/data/models/product_model.dart';
import 'package:fathiyah_store/app/data/services/product_service.dart';
import 'package:fathiyah_store/app/data/services/auth_service.dart';
import 'package:fathiyah_store/app/data/services/shift_service.dart';
import 'package:fathiyah_store/app/data/services/stock_movement_service.dart';
import 'package:fathiyah_store/app/data/models/user_model.dart';

class FakeProductService extends GetxService implements ProductService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthService extends GetxService implements AuthService {
  @override
  Rx<UserModel?> get currentUser => Rx<UserModel?>(UserModel(id: '1', username: 'admin', name: 'Admin', role: 'admin', status: 'aktif'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeShiftService extends GetxService implements ShiftService {
  @override
  Future<void> recordCashSale(int amount) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStockMovementService extends GetxService implements StockMovementService {
  @override
  Future<void> recordMovement({required String productId, required String productName, required int quantity, required String type, String? note}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SaleService saleService;

  setUp(() {
    // Inject mock dependencies
    Get.put<ProductService>(FakeProductService());
    Get.put<AuthService>(FakeAuthService());
    Get.put<ShiftService>(FakeShiftService());
    Get.put<StockMovementService>(FakeStockMovementService());

    // NOTE: Because SaleService calls FirebaseFirestore.instance on initialization,
    // we must ensure it doesn't crash. Normally we'd pass the firestore instance in constructor.
    // However, since we just test cart logic, it might work if we don't call init().
    Get.testMode = true;
    saleService = SaleService();
  });

  tearDown(() {
    Get.reset();
  });

  group('SaleService Cart Logic', () {
    final testProduct = ProductModel(
      id: 'p1',
      name: 'Produk A',
      barcode: '123',
      purchasePrice: 10000,
      sellingPrice: 15000,
      stock: 10,
      minimumStock: 2,
      unit: 'pcs',
      categoryId: 'c1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('Add to cart should increase total and quantity', () {
      saleService.addToCart(testProduct);
      
      expect(saleService.cartItems.length, 1);
      expect(saleService.cartTotal, 15000);

      // Add same product again
      saleService.addToCart(testProduct);
      
      expect(saleService.cartItems.length, 1);
      expect(saleService.cartItems.first.quantity, 2);
      expect(saleService.cartTotal, 30000);
    });

    test('Cannot add to cart if stock is 0', () {
      final outOfStockProduct = testProduct.copyWith(stock: 0);
      saleService.addToCart(outOfStockProduct);
      
      // Should not be added
      expect(saleService.cartItems.length, 0);
    });

    test('Update quantity updates total correctly', () {
      saleService.addToCart(testProduct); // qty: 1
      saleService.updateQuantity('p1', 5);
      
      expect(saleService.cartItems.first.quantity, 5);
      expect(saleService.cartTotal, 75000);
    });

    test('Update quantity to 0 removes item', () {
      saleService.addToCart(testProduct); // qty: 1
      saleService.updateQuantity('p1', 0);
      
      expect(saleService.cartItems.length, 0);
    });

    test('Nominal discount reduces cartTotal correctly', () {
      saleService.addToCart(testProduct); // 15000
      saleService.addToCart(testProduct); // 30000
      
      expect(saleService.cartSubtotal, 30000);
      saleService.setNominalDiscount(5000);

      expect(saleService.calculatedDiscount, 5000);
      expect(saleService.cartTotal, 25000);
    });

    test('Percentage discount calculates discount proportionally', () {
      saleService.addToCart(testProduct); // 15000
      saleService.addToCart(testProduct); // 30000
      
      saleService.setPercentageDiscount(10.0); // 10% dari 30000 = 3000

      expect(saleService.calculatedDiscount, 3000);
      expect(saleService.cartTotal, 27000);
    });

    test('Discount cannot exceed subtotal and resets on clearCart', () {
      saleService.addToCart(testProduct); // 15000
      saleService.setNominalDiscount(20000); // Exceeds 15000

      // Clamped to subtotal (15000) so total is 0
      expect(saleService.calculatedDiscount, 15000);
      expect(saleService.cartTotal, 0);

      // clearCart should reset discount
      saleService.clearCart();
      expect(saleService.cartItems.length, 0);
      expect(saleService.calculatedDiscount, 0);
      expect(saleService.cartTotal, 0);
    });
  });

  group('SaleModel Payment Status & Debt Getters', () {
    test('isPaid, isPartial, isUnpaid and paymentStatusLabel behave correctly', () {
      final paidSale = SaleModel(
        id: 's1',
        invoiceNumber: 'INV001',
        items: [],
        subtotal: 100000,
        discount: 0,
        total: 100000,
        cashierId: 'u1',
        cashierName: 'Admin',
        createdAt: DateTime.now(),
        paymentStatus: 'lunas',
        paidAmount: 100000,
        remainingAmount: 0,
      );
      expect(paidSale.isPaid, true);
      expect(paidSale.isPartial, false);
      expect(paidSale.isUnpaid, false);
      expect(paidSale.paymentStatusLabel, 'Lunas');

      final partialSale = SaleModel(
        id: 's2',
        invoiceNumber: 'INV002',
        items: [],
        subtotal: 100000,
        discount: 0,
        total: 100000,
        cashierId: 'u1',
        cashierName: 'Admin',
        createdAt: DateTime.now(),
        paymentStatus: 'sebagian',
        paidAmount: 40000,
        remainingAmount: 60000,
      );
      expect(partialSale.isPaid, false);
      expect(partialSale.isPartial, true);
      expect(partialSale.isUnpaid, false);
      expect(partialSale.paymentStatusLabel, 'Sebagian');

      final unpaidSale = SaleModel(
        id: 's3',
        invoiceNumber: 'INV003',
        items: [],
        subtotal: 100000,
        discount: 0,
        total: 100000,
        cashierId: 'u1',
        cashierName: 'Admin',
        createdAt: DateTime.now(),
        paymentStatus: 'belum_dibayar',
        paidAmount: 0,
        remainingAmount: 100000,
      );
      expect(unpaidSale.isPaid, false);
      expect(unpaidSale.isPartial, false);
      expect(unpaidSale.isUnpaid, true);
      expect(unpaidSale.paymentStatusLabel, 'Belum Dibayar');

      // Test remainingAmount fallback when status is empty
      final unpaidFallbackSale = SaleModel(
        id: 's4',
        invoiceNumber: 'INV004',
        items: [],
        subtotal: 100000,
        discount: 0,
        total: 100000,
        cashierId: 'u1',
        cashierName: 'Admin',
        createdAt: DateTime.now(),
        paymentStatus: null,
        paidAmount: 0,
        remainingAmount: 100000,
      );
      expect(unpaidFallbackSale.isUnpaid, true);
      expect(unpaidFallbackSale.paymentStatusLabel, 'Belum Dibayar');
    });

    test('SaleService getDebtsByCustomer scans local sales correctly', () async {
      saleService.sales.addAll([
        SaleModel(
          id: 's_cust1_unpaid',
          invoiceNumber: 'INV-101',
          customerId: 'cust1',
          customerName: 'Budi VIP',
          items: [],
          subtotal: 50000,
          discount: 0,
          total: 50000,
          cashierId: 'u1',
          cashierName: 'Admin',
          createdAt: DateTime.now(),
          paymentStatus: 'belum_dibayar',
          paidAmount: 0,
          remainingAmount: 50000,
        ),
        SaleModel(
          id: 's_cust1_paid',
          invoiceNumber: 'INV-102',
          customerId: 'cust1',
          customerName: 'Budi VIP',
          items: [],
          subtotal: 30000,
          discount: 0,
          total: 30000,
          cashierId: 'u1',
          cashierName: 'Admin',
          createdAt: DateTime.now(),
          paymentStatus: 'lunas',
          paidAmount: 30000,
          remainingAmount: 0,
        ),
        SaleModel(
          id: 's_cust2_partial',
          invoiceNumber: 'INV-103',
          customerId: 'cust2',
          customerName: 'Siti VIP',
          items: [],
          subtotal: 80000,
          discount: 0,
          total: 80000,
          cashierId: 'u1',
          cashierName: 'Admin',
          createdAt: DateTime.now(),
          paymentStatus: 'sebagian',
          paidAmount: 30000,
          remainingAmount: 50000,
        ),
      ]);

      // Debts for cust1 should only return unpaid/partial
      final cust1Debts = await saleService.getDebtsByCustomer('cust1');
      expect(cust1Debts.length, 1);
      expect(cust1Debts.first.id, 's_cust1_unpaid');
      expect(cust1Debts.first.remainingAmount, 50000);

      // All sales for cust1 should return both paid and unpaid
      final cust1All = await saleService.getAllSalesForCustomer('cust1');
      expect(cust1All.length, 2);

      // Debts for cust2
      final cust2Debts = await saleService.getDebtsByCustomer('cust2');
      expect(cust2Debts.length, 1);
      expect(cust2Debts.first.id, 's_cust2_partial');
      expect(cust2Debts.first.remainingAmount, 50000);
    });
  });
}

