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
import 'package:fathiyah_store/app/data/services/connectivity_service.dart';
import 'package:fathiyah_store/app/data/models/user_model.dart';
import 'package:fathiyah_store/app/data/models/shift_model.dart';
import 'package:fathiyah_store/app/data/models/product_model.dart';
import 'package:fathiyah_store/app/data/models/category_model.dart';
import 'package:fathiyah_store/app/data/models/customer_model.dart';
import 'package:fathiyah_store/app/data/services/printer_service.dart';
import 'package:fathiyah_store/app/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FakeAuthService extends GetxService implements AuthService {
  @override
  Rx<UserModel?> get currentUser => Rx<UserModel?>(null);
  @override
  bool get isAdmin => true;
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
  RxList<HoldOrderModel> get holdOrders => <HoldOrderModel>[].obs;
  @override
  int get cartTotal => 0;
  @override
  int get cartSubtotal => 0;
  @override
  int get calculatedDiscount => 0;
  @override
  RxString get discountType => ''.obs;
  @override
  RxDouble get discountPercent => 0.0.obs;
  @override
  RxInt get nominalDiscount => 0.obs;
  @override
  RxInt get discountAmount => 0.obs;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProductService extends GetxService implements ProductService {
  @override
  RxList<ProductModel> get products => <ProductModel>[].obs;
  @override
  RxList<CategoryModel> get categories => <CategoryModel>[].obs;
  @override
  RxBool get isLoading => false.obs;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCategoryService extends GetxService implements CategoryService {
  @override
  RxList<CategoryModel> get categories => <CategoryModel>[].obs;
  @override
  RxString get selectedCategory => 'Semua'.obs;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCustomerService extends GetxService implements CustomerService {
  @override
  RxList<CustomerModel> get customers => <CustomerModel>[].obs;
  @override
  Rx<CustomerModel?> get selectedCustomer => Rx<CustomerModel?>(null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePrinterService extends GetxService implements PrinterService {
  @override
  RxBool get isConnected => false.obs;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeConnectivityService extends GetxService implements ConnectivityService {
  @override
  RxBool get isOffline => false.obs;
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
    Get.put<ConnectivityService>(FakeConnectivityService());
    Get.put<PrinterService>(FakePrinterService());
    Get.put<PosController>(PosController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('PosView renders Kasir title', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1920));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (context, child) => GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const PosView(),
        ),
      ),
    );

    // Initial load might have some async operations
    await tester.pumpAndSettle();

    // Verify if the title Kasir is present
    expect(find.text('Kasir'), findsWidgets);
  });
}
