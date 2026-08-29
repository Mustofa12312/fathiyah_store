import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'audit_log_service.dart';
import 'stock_movement_service.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = Get.find<AuditLogService>();
  final StockMovementService _stockMovementService = Get.find<StockMovementService>();
  
  final CategoryService _categoryService = Get.find<CategoryService>();
  
  RxList<CategoryModel> get categories => _categoryService.categories;

  final products = <ProductModel>[].obs;

  Future<ProductService> init() async {
    _firestore.collection('products').snapshots().listen((snapshot) {
      products.value = snapshot.docs.map((doc) => ProductModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => print('ProductService Error: $e'));
    return this;
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
    
    await _auditLogService.logAction(
      action: 'CREATE',
      entity: 'PRODUCT',
      entityId: product.id,
      details: 'Menambahkan produk baru: ${product.name}',
    );
    
    if (product.stock > 0) {
      await _stockMovementService.recordMovement(
        productId: product.id,
        productName: product.name,
        quantity: product.stock,
        type: 'INITIAL',
        note: 'Stok awal penambahan produk',
      );
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    final oldProduct = products.firstWhereOrNull((p) => p.id == product.id);
    await _firestore.collection('products').doc(product.id).update(product.toJson());
    
    await _auditLogService.logAction(
      action: 'UPDATE',
      entity: 'PRODUCT',
      entityId: product.id,
      details: 'Mengubah data produk: ${product.name}',
    );

    if (oldProduct != null && oldProduct.stock != product.stock) {
      final diff = product.stock - oldProduct.stock;
      await _stockMovementService.recordMovement(
        productId: product.id,
        productName: product.name,
        quantity: diff,
        type: 'CORRECTION',
        note: 'Koreksi stok manual melalui edit produk',
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    final product = products.firstWhereOrNull((p) => p.id == id);
    await _firestore.collection('products').doc(id).delete();
    
    if (product != null) {
      await _auditLogService.logAction(
        action: 'DELETE',
        entity: 'PRODUCT',
        entityId: id,
        details: 'Menghapus produk: ${product.name}',
      );
    }
  }
}
