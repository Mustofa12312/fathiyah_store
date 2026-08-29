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

    return SafeArea(
      child: Column(
        children: [
          // Header & Search
          Container(
            padding: EdgeInsets.all(24.w),
            color: AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Produk',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => const ProductFormView());
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        backgroundColor: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Cari nama produk atau barcode...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
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
                  child: Text(
                    'Tidak ada produk ditemukan',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
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
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final isOutOfStock = product.stock <= 0;
    final isLowStock = product.stock > 0 && product.stock <= product.minimumStock;
    
    Color stockColor = AppTheme.accent; // Green = Good
    if (isOutOfStock) {
      stockColor = Colors.red.shade500;
    } else if (isLowStock) {
      stockColor = AppTheme.vipGold;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.to(() => ProductFormView(product: product));
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Product Image Placeholder
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.inventory_2_outlined, color: AppTheme.textSecondary),
              ),
              SizedBox(width: 16.w),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      controller.getCategoryName(product.categoryId),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      CurrencyFormatter.formatRupiah(product.sellingPrice),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stock Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
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
                    SizedBox(height: 4.h),
                    Text(
                      'Stok Menipis',
                      style: TextStyle(
                        color: stockColor,
                        fontSize: 10.sp,
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
