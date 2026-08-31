import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../pos/controllers/pos_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../report/controllers/report_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../product/controllers/product_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DashboardController>(DashboardController());
    Get.lazyPut(() => PosController());
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => ReportController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => ProductController());
  }
}
