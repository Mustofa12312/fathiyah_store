import 'package:get/get.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/services/customer_service.dart';

class CustomerController extends GetxController {
  final CustomerService _customerService = Get.find<CustomerService>();
  final searchQuery = ''.obs;

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
