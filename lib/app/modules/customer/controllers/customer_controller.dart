import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/services/sale_service.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = Get.find<CustomerService>();
  final SaleService _saleService = Get.find<SaleService>();
  final searchQuery = ''.obs;
  final customerDebts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    customerDebts.value = await _saleService.getDebtsByCustomer();
  }

  List<CustomerModel> get filteredCustomers {
    if (searchQuery.value.isEmpty) {
      return _customerService.customers;
    }
    return _customerService.customers.where((c) => 
      c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
      c.phone.contains(searchQuery.value)
    ).toList();
  }

  void deleteCustomer(String id) {
    _customerService.deleteCustomer(id);
  }

  void toggleVipStatus(String id) {
    _customerService.toggleVipStatus(id);
  }
}
