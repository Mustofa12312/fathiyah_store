import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = Get.find<CategoryService>();
  
  final searchQuery = ''.obs;

  List<CategoryModel> get categories => _categoryService.categories;

  List<CategoryModel> get filteredCategories {
    if (searchQuery.value.isEmpty) {
      return categories;
    }
    return categories.where((c) => 
      c.name.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  void deleteCategory(CategoryModel category) {
    Get.defaultDialog(
      title: 'Hapus Kategori?',
      middleText: 'Apakah Anda yakin ingin menghapus kategori "${category.name}"?',
      textConfirm: 'Ya, Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _categoryService.deleteCategory(category.id, category.name);
        Get.back();
        Get.snackbar('Sukses', 'Kategori berhasil dihapus');
      },
    );
  }
}
