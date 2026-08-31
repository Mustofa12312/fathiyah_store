import 'package:get/get.dart';
import '../controllers/debt_controller.dart';

class DebtBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DebtController>(DebtController());
  }
}
