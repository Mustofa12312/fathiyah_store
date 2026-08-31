// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:get/get.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/sale_model.dart';

class DebtController extends GetxController {
  final SaleService _saleService = Get.find<SaleService>();
  final CustomerService _customerService = Get.find<CustomerService>();

  // Map of customer ID to total debt
  Map<String, int> get customerDebts => _saleService.getDebtsByCustomer();

  List<CustomerModel> get customersWithDebt {
    final debts = customerDebts;
    if (debts.isEmpty) return [];

    return _customerService.customers.where((c) => debts.containsKey(c.id)).toList();
  }

  List<SaleModel> getUnpaidSalesFor(String customerId) {
    return _saleService.getUnpaidSalesForCustomer(customerId);
  }

  void payDebt(String saleId, int amount) {
    _saleService.payDebt(saleId, amount, 'Cash');
    update(); // Force UI to rebuild since sales list items are modified
  }
}
