import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService extends GetxService {
  // Dummy Categories
  final categories = <CategoryModel>[
    CategoryModel(id: 'cat_1', name: 'Minuman'),
    CategoryModel(id: 'cat_2', name: 'Sembako'),
    CategoryModel(id: 'cat_3', name: 'Makanan Ringan'),
    CategoryModel(id: 'cat_4', name: 'Kebutuhan Mandi'),
  ].obs;

  // Dummy Products
  final products = <ProductModel>[
    ProductModel(
      id: 'prod_1',
      name: 'Kopi Kapal Api',
      categoryId: 'cat_1',
      unit: 'Sachet',
      purchasePrice: 1000,
      sellingPrice: 1500,
      stock: 5, // low stock
      minimumStock: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Beras Bulog 5Kg',
      categoryId: 'cat_2',
      unit: 'Sak',
      purchasePrice: 50000,
      sellingPrice: 55000,
      stock: 20, // good stock
      minimumStock: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_3',
      name: 'Minyak Goreng Bimoli 1L',
      categoryId: 'cat_2',
      unit: 'Pouch',
      purchasePrice: 15000,
      sellingPrice: 17500,
      stock: 0, // out of stock
      minimumStock: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ].obs;

  Future<ProductService> init() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return this;
  }

  void addProduct(ProductModel product) {
    products.add(product);
  }

  void updateProduct(ProductModel updatedProduct) {
    final index = products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      products[index] = updatedProduct;
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
  }
}
