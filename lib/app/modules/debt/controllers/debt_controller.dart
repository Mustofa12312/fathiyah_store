import 'package:get/get.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/sale_model.dart';

class DebtController extends GetxController {
  final SaleService _saleService = Get.find<SaleService>();
  final CustomerService _customerService = Get.find<CustomerService>();

  final RxMap<String, int> customerDebts = <String, int>{}.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDebts();
  }

  Future<void> fetchDebts() async {
    isLoading.value = true;
    final debts = await _saleService.getDebtsByCustomer();
    customerDebts.assignAll(debts);
    isLoading.value = false;
  }

  List<CustomerModel> get customersWithDebt {
    if (customerDebts.isEmpty) return [];
    return _customerService.customers.where((c) => customerDebts.containsKey(c.id)).toList();
  }

  Future<List<SaleModel>> getUnpaidSalesFor(String customerId) async {
    return await _saleService.getUnpaidSalesForCustomer(customerId);
  }

  Future<void> payDebt(String saleId, int amount) async {
    await _saleService.payDebt(saleId, amount, 'Cash');
    await fetchDebts(); // Refresh data
  }
}
