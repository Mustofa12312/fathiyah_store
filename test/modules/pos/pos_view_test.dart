import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fathiyah_store/app/modules/pos/views/pos_view.dart';
import 'package:fathiyah_store/app/modules/pos/controllers/pos_controller.dart';
import 'package:fathiyah_store/app/data/services/sale_service.dart';
import 'package:fathiyah_store/app/data/services/product_service.dart';
import 'package:fathiyah_store/app/data/services/category_service.dart';
import 'package:fathiyah_store/app/data/services/customer_service.dart';
import 'package:fathiyah_store/app/data/services/shift_service.dart';
import 'package:fathiyah_store/app/data/services/auth_service.dart';
import 'package:fathiyah_store/app/data/models/user_model.dart';
import 'package:fathiyah_store/app/data/models/shift_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'pos_view_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PosController>(),
  MockSpec<SaleService>(),
  MockSpec<ProductService>(),
  MockSpec<CategoryService>(),
  MockSpec<CustomerService>(),
  MockSpec<ShiftService>(),
  MockSpec<AuthService>()
])
void main() {
  setUp(() {
    final mockAuth = MockAuthService();
    when(mockAuth.currentUser).thenReturn(Rx<UserModel?>(null));

    final mockShift = MockShiftService();
    when(mockShift.currentShift).thenReturn(Rx<ShiftModel?>(null));

    final mockSale = MockSaleService();
    when(mockSale.cartItems).thenReturn(<CartItem>[].obs);
    when(mockSale.cartTotal).thenReturn(0.0);

    Get.put<AuthService>(mockAuth);
    Get.put<ShiftService>(mockShift);
    Get.put<SaleService>(mockSale);
    Get.put<ProductService>(MockProductService());
    Get.put<CategoryService>(MockCategoryService());
    Get.put<CustomerService>(MockCustomerService());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('PosView renders Kasir title', (WidgetTester tester) async {
    // We cannot easily test the full PosView because it relies on ScreenUtilInit
    // Let's wrap it properly.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (context, child) => GetMaterialApp(
          home: child,
        ),
        child: const PosView(),
      ),
    );

    // Initial load might have some async operations
    await tester.pumpAndSettle();

    // Verify if the title Kasir is present
    expect(find.text('Kasir'), findsWidgets);
  });
}
