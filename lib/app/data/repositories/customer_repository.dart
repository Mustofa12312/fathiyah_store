import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

abstract class CustomerRepository {
  Stream<List<CustomerModel>> streamCustomers();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<void> updateCustomerType(String customerId, String newType);
}

class FirebaseCustomerRepository implements CustomerRepository {
  final FirebaseFirestore _firestore;

  FirebaseCustomerRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<CustomerModel>> streamCustomers() {
    return _firestore.collection('customers').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').doc(customer.id).set(customer.toJson());
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _firestore.collection('customers').doc(customer.id).update(customer.toJson());
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _firestore.collection('customers').doc(id).delete();
  }

  @override
  Future<void> updateCustomerType(String customerId, String newType) async {
    await _firestore.collection('customers').doc(customerId).update({'type': newType});
  }
}
