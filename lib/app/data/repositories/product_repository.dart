import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/stock_movement_model.dart';

abstract class ProductRepository {
  Stream<List<ProductModel>> streamProducts();
  Future<void> addProduct(ProductModel product, {StockMovementModel? stockMovement});
  Future<void> updateProduct(ProductModel product, {StockMovementModel? stockMovement});
  Future<void> deleteProduct(String id);
}

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;

  FirebaseProductRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ProductModel>> streamProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> addProduct(ProductModel product, {StockMovementModel? stockMovement}) async {
    final batch = _firestore.batch();
    
    final productRef = _firestore.collection('products').doc(product.id);
    batch.set(productRef, product.toJson());
    
    if (stockMovement != null) {
      final movementRef = _firestore.collection('stock_movements').doc(stockMovement.id);
      batch.set(movementRef, stockMovement.toJson());
    }
    
    await batch.commit();
  }

  @override
  Future<void> updateProduct(ProductModel product, {StockMovementModel? stockMovement}) async {
    final batch = _firestore.batch();
    
    final productRef = _firestore.collection('products').doc(product.id);
    batch.update(productRef, product.toJson());
    
    if (stockMovement != null) {
      final movementRef = _firestore.collection('stock_movements').doc(stockMovement.id);
      batch.set(movementRef, stockMovement.toJson());
    }
    
    await batch.commit();
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
