import 'package:get/get.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/auth_service.dart';

class TransactionController extends GetxController {
  final SaleService saleService = Get.find<SaleService>();
  final AuthService authService = Get.find<AuthService>();

  bool get isAdmin => authService.isAdmin;

  void voidTransaction(String saleId) {
    saleService.voidTransaction(saleId);
  }
}
