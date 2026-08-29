import 'package:get/get.dart';
import '../models/customer_model.dart';

class CustomerService extends GetxService {
  final customers = <CustomerModel>[
    CustomerModel(
      id: 'cust_1',
      name: 'Ahmad',
      phone: '081234567890',
      address: 'Jl. Merdeka No. 1',
      type: 'vip',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CustomerModel(
      id: 'cust_2',
      name: 'Budi Santoso',
      phone: '085678901234',
      address: 'Komp. Melati Blok B/2',
      type: 'general',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    CustomerModel(
      id: 'cust_3',
      name: 'Siti Rahma',
      phone: '089912345678',
      type: 'vip',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ].obs;

  Future<CustomerService> init() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return this;
  }

  void addCustomer(CustomerModel customer) {
    customers.add(customer);
  }

  void updateCustomer(CustomerModel updatedCustomer) {
    final index = customers.indexWhere((c) => c.id == updatedCustomer.id);
    if (index != -1) {
      customers[index] = updatedCustomer;
    }
  }

  void deleteCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
  }

  void toggleVipStatus(String customerId) {
    final index = customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final customer = customers[index];
      final newType = customer.type == 'vip' ? 'general' : 'vip';
      customers[index] = customer.copyWith(type: newType);
    }
  }
}
