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
class FakeProductService extends GetxService implements ProductService {
  @override
  Future<void> updateProduct(ProductModel product) async {}
}

class FakeAuthService extends GetxService implements AuthService {
  @override
  Rx<UserModel?> get currentUser => Rx<UserModel?>(UserModel(id: '1', username: 'admin', password: '123', name: 'Admin', role: 'admin', status: 'aktif'));
}

class FakeShiftService extends GetxService implements ShiftService {
  @override
  Future<void> recordCashSale(double amount) async {}
}

class FakeStockMovementService extends GetxService implements StockMovementService {
  @override
  Future<void> recordMovement({required String productId, required String productName, required int quantity, required String type, String? note}) async {}
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
