import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/models/category_model.dart';

class ProductController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  final searchQuery = ''.obs;
  
  // Computed property to get filtered products
  List<ProductModel> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return _productService.products;
    }
    return _productService.products.where((p) => 
      p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
      (p.barcode != null && p.barcode!.contains(searchQuery.value))
    ).toList();
  }

  List<CategoryModel> get categories => _productService.categories;

  String getCategoryName(String categoryId) {
    return categories.firstWhereOrNull((c) => c.id == categoryId)?.name ?? 'Unknown';
  }

  void deleteProduct(String id) {
    _productService.deleteProduct(id);
  }
}
