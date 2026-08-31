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
class FakeAuthService extends GetxService implements AuthService {
  @override
  Rx<UserModel?> get currentUser => Rx<UserModel?>(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeShiftService extends GetxService implements ShiftService {
  @override
  Rx<ShiftModel?> get currentShift => Rx<ShiftModel?>(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSaleService extends GetxService implements SaleService {
  @override
  RxList<CartItem> get cartItems => <CartItem>[].obs;
  @override
  int get cartTotal => 0;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProductService extends GetxService implements ProductService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class FakeCategoryService extends GetxService implements CategoryService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class FakeCustomerService extends GetxService implements CustomerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    Get.put<AuthService>(FakeAuthService());
    Get.put<ShiftService>(FakeShiftService());
    Get.put<SaleService>(FakeSaleService());
    Get.put<ProductService>(FakeProductService());
    Get.put<CategoryService>(FakeCategoryService());
    Get.put<CustomerService>(FakeCustomerService());
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
