import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fathiyah_store/app/data/services/sale_service.dart';
import 'package:fathiyah_store/app/data/models/product_model.dart';
import 'package:fathiyah_store/app/data/services/product_service.dart';
import 'package:fathiyah_store/app/data/services/auth_service.dart';
import 'package:fathiyah_store/app/data/services/shift_service.dart';
import 'package:fathiyah_store/app/data/services/stock_movement_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'sale_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ProductService>(), MockSpec<AuthService>(), MockSpec<ShiftService>(), MockSpec<StockMovementService>()])
void main() {
  late SaleService saleService;

  setUp(() {
    // Inject mock dependencies
    Get.put<ProductService>(MockProductService());
    Get.put<AuthService>(MockAuthService());
    Get.put<ShiftService>(MockShiftService());
    Get.put<StockMovementService>(MockStockMovementService());

    // NOTE: Because SaleService calls FirebaseFirestore.instance on initialization,
    // we must ensure it doesn't crash. Normally we'd pass the firestore instance in constructor.
    // However, since we just test cart logic, it might work if we don't call init().
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
  });
}
