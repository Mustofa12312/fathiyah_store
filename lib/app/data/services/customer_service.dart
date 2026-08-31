import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../repositories/customer_repository.dart';
import '../models/customer_model.dart';
import 'audit_log_service.dart';

class CustomerService extends GetxService {
  final CustomerRepository _repository = Get.find<CustomerRepository>();
  final AuditLogService _auditLogService = Get.find<AuditLogService>();
  final customers = <CustomerModel>[].obs;

  Future<CustomerService> init() async {
    _repository.streamCustomers().listen((fetchedCustomers) {
      customers.value = fetchedCustomers;
    }, onError: (e) => debugPrint('CustomerService Error: $e'));
    return this;
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _repository.addCustomer(customer);
    
    await _auditLogService.logAction(
      action: 'CREATE',
      entity: 'CUSTOMER',
      entityId: customer.id,
      details: 'Menambahkan pelanggan baru: ${customer.name}',
    );
  }

  Future<void> updateCustomer(CustomerModel updatedCustomer) async {
    await _repository.updateCustomer(updatedCustomer);
    
    await _auditLogService.logAction(
      action: 'UPDATE',
      entity: 'CUSTOMER',
      entityId: updatedCustomer.id,
      details: 'Mengubah data pelanggan: ${updatedCustomer.name}',
    );
  }

  Future<void> deleteCustomer(String id) async {
    final customer = customers.firstWhereOrNull((c) => c.id == id);
    await _repository.deleteCustomer(id);
    
    if (customer != null) {
      await _auditLogService.logAction(
        action: 'DELETE',
        entity: 'CUSTOMER',
        entityId: id,
        details: 'Menghapus pelanggan: ${customer.name}',
      );
    }
  }

  Future<void> toggleVipStatus(String customerId) async {
    final customer = customers.firstWhereOrNull((c) => c.id == customerId);
    if (customer != null) {
      final newType = customer.type == 'vip' ? 'general' : 'vip';
      await _repository.updateCustomerType(customerId, newType);
      
      await _auditLogService.logAction(
        action: 'UPDATE',
        entity: 'CUSTOMER',
        entityId: customerId,
        details: 'Mengubah status VIP pelanggan ${customer.name} menjadi ${newType.toUpperCase()}',
      );
    }
  }
}
