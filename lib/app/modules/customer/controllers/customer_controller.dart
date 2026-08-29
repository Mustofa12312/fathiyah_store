// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
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
