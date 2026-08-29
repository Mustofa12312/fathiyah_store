import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/category_controller.dart';
import 'category_form_view.dart';

class CategoryListView extends GetView<CategoryController> {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CategoryController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const CategoryFormView()),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppTheme.surface,
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: const InputDecoration(
                hintText: 'Cari kategori...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          
          // Category List
          Expanded(
            child: Obx(() {
              final categories = controller.filteredCategories;
              
              if (categories.isEmpty) {
                return const Center(child: Text('Kategori tidak ditemukan'));
              }
              
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: categories.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        category.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                      subtitle: category.description != null 
                          ? Text(category.description!) 
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.secondary),
                            onPressed: () => Get.to(() => CategoryFormView(category: category)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => controller.deleteCategory(category),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
