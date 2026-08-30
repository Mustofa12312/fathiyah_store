// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../repositories/product_repository.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'audit_log_service.dart';
import 'stock_movement_service.dart';
import 'category_service.dart';

class ProductService extends GetxService {
  final ProductRepository _repository = Get.find<ProductRepository>();
  final AuditLogService _auditLogService = Get.find<AuditLogService>();
  final StockMovementService _stockMovementService =
      Get.find<StockMovementService>();

  final CategoryService _categoryService = Get.find<CategoryService>();

  RxList<CategoryModel> get categories => _categoryService.categories;

  final products = <ProductModel>[].obs;

  Future<ProductService> init() async {
    _repository.streamProducts().listen((fetchedProducts) {
      products.value = fetchedProducts;
    }, onError: (e) => debugPrint('ProductService Error: $e'));
    return this;
  }

  Future<void> addProduct(ProductModel product) async {
    await _repository.addProduct(product);

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
    await _repository.updateProduct(product);

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
    await _repository.deleteProduct(id);

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
