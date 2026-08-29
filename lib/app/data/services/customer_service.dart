import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final customers = <CustomerModel>[].obs;

  Future<CustomerService> init() async {
    _firestore.collection('customers').snapshots().listen((snapshot) {
      customers.value = snapshot.docs.map((doc) => CustomerModel.fromJson(doc.data(), doc.id)).toList();
    });
    return this;
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').doc(customer.id).set(customer.toJson());
  }

  Future<void> updateCustomer(CustomerModel updatedCustomer) async {
    await _firestore.collection('customers').doc(updatedCustomer.id).update(updatedCustomer.toJson());
  }

  Future<void> deleteCustomer(String id) async {
    await _firestore.collection('customers').doc(id).delete();
  }

  Future<void> toggleVipStatus(String customerId) async {
    final customer = customers.firstWhereOrNull((c) => c.id == customerId);
    if (customer != null) {
      final newType = customer.type == 'vip' ? 'general' : 'vip';
      await _firestore.collection('customers').doc(customerId).update({'type': newType});
    }
  }
}
