// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/product_controller.dart';
import 'product_form_view.dart';
import '../../../data/models/product_model.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring controller is available if not injected via binding yet
    Get.put(ProductController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ProductFormView()),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header & Search
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Produk',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.inventory_2_rounded, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau barcode...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: Obx(() {
                final products = controller.filteredProducts;
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64.w, color: Colors.grey.shade300),
                        SizedBox(height: 16.h),
                        Text(
                          'Tidak ada produk ditemukan',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: EdgeInsets.all(24.w).copyWith(bottom: 100.h), // Extra padding for FAB
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, product);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final isOutOfStock = product.stock <= 0;
    final isLowStock = product.stock > 0 && product.stock <= product.minimumStock;
    
    Color stockColor = AppTheme.accent; // Green
    Color bgColor = AppTheme.accent.withValues(alpha: 0.1);
    if (isOutOfStock) {
      stockColor = Colors.red.shade600;
      bgColor = Colors.red.shade50;
    } else if (isLowStock) {
      stockColor = Colors.orange.shade700;
      bgColor = Colors.orange.shade50;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => Get.to(() => ProductFormView(product: product)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Product Icon/Image
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.inventory_2_rounded, color: AppTheme.primary, size: 28.sp),
                ),
                SizedBox(width: 16.w),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.getCategoryName(product.categoryId),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        CurrencyFormatter.formatRupiah(product.sellingPrice),
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Stock Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isOutOfStock ? 'Habis' : '${product.stock} ${product.unit}',
                        style: TextStyle(
                          color: stockColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isLowStock && !isOutOfStock) ...[
                      SizedBox(height: 6.h),
                      Text(
                        'Stok Menipis',
                        style: TextStyle(
                          color: stockColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
