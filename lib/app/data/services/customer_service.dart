import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import 'audit_log_service.dart';

class CustomerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = Get.find<AuditLogService>();
  final customers = <CustomerModel>[].obs;

  Future<CustomerService> init() async {
    _firestore.collection('customers').snapshots().listen((snapshot) {
      customers.value = snapshot.docs.map((doc) => CustomerModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => print('CustomerService Error: $e'));
    return this;
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').doc(customer.id).set(customer.toJson());
    
    await _auditLogService.logAction(
      action: 'CREATE',
      entity: 'CUSTOMER',
      entityId: customer.id,
      details: 'Menambahkan pelanggan baru: ${customer.name}',
    );
  }

  Future<void> updateCustomer(CustomerModel updatedCustomer) async {
    await _firestore.collection('customers').doc(updatedCustomer.id).update(updatedCustomer.toJson());
    
    await _auditLogService.logAction(
      action: 'UPDATE',
      entity: 'CUSTOMER',
      entityId: updatedCustomer.id,
      details: 'Mengubah data pelanggan: ${updatedCustomer.name}',
    );
  }

  Future<void> deleteCustomer(String id) async {
    final customer = customers.firstWhereOrNull((c) => c.id == id);
    await _firestore.collection('customers').doc(id).delete();
    
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
      await _firestore.collection('customers').doc(customerId).update({'type': newType});
      
      await _auditLogService.logAction(
        action: 'UPDATE',
        entity: 'CUSTOMER',
        entityId: customerId,
        details: 'Mengubah status VIP pelanggan ${customer.name} menjadi ${newType.toUpperCase()}',
      );
    }
  }
}
