import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/product_service.dart';
import '../../data/services/category_service.dart';
import '../../data/services/customer_service.dart';
import '../../data/services/sale_service.dart';
import '../../data/services/expense_service.dart';
import '../../data/services/shift_service.dart';
import '../../data/services/audit_log_service.dart';
import '../../data/services/stock_movement_service.dart';
import '../../data/services/shop_service.dart';
import '../../data/services/printer_service.dart';
import '../../data/services/backup_service.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/sync_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (Permanent & Immediate)
    Get.put(ConnectivityService(), permanent: true).init();
    Get.put(AuthService(), permanent: true).init();
    Get.put(SyncService(), permanent: true).init();
    Get.put(AuditLogService(), permanent: true).init();

    // Repositories (Lazy)
    Get.lazyPut<ProductRepository>(() => FirebaseProductRepository(), fenix: true);
    Get.lazyPut<CustomerRepository>(() => FirebaseCustomerRepository(), fenix: true);

    // Business Services (Lazy)
    Get.lazyPut(() => StockMovementService(), fenix: true);
    Get.lazyPut(() => ShiftService()..init(), fenix: true);
    Get.lazyPut(() => ShopService()..init(), fenix: true);
    Get.lazyPut(() => CategoryService()..init(), fenix: true);
    Get.lazyPut(() => ProductService()..init(), fenix: true);
    Get.lazyPut(() => CustomerService()..init(), fenix: true);
    Get.lazyPut(() => SaleService()..init(), fenix: true);
    Get.lazyPut(() => ExpenseService()..init(), fenix: true);
    Get.lazyPut(() => PrinterService()..init(), fenix: true);
    Get.lazyPut(() => BackupService(), fenix: true);
  }
}
