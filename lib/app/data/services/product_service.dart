import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Dummy Categories for now (or move to Firestore later)
  final categories = <CategoryModel>[
    CategoryModel(id: 'cat_1', name: 'Minuman'),
    CategoryModel(id: 'cat_2', name: 'Sembako'),
    CategoryModel(id: 'cat_3', name: 'Makanan Ringan'),
    CategoryModel(id: 'cat_4', name: 'Kebutuhan Mandi'),
  ].obs;

  final products = <ProductModel>[].obs;

  Future<ProductService> init() async {
    _firestore.collection('products').snapshots().listen((snapshot) {
      products.value = snapshot.docs.map((doc) => ProductModel.fromJson(doc.data(), doc.id)).toList();
    });
    return this;
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }

  Future<void> updateProduct(ProductModel updatedProduct) async {
    await _firestore.collection('products').doc(updatedProduct.id).update(updatedProduct.toJson());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
