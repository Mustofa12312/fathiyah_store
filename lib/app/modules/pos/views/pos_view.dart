import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/pos_controller.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'checkout_view.dart';

import 'package:fathiyah_store/app/data/services/auth_service.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PosController()); // Ensure controller is loaded
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir / Mesin POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleBarcodeScannerPage(),
                ),
              );
              if (res is String && res != '-1') {
                // If scanned, search the product and add to cart if found
                controller.searchQuery.value = res;
                final products = controller.filteredProducts;
                if (products.length == 1) {
                  controller.saleService.addToCart(products.first);
                  Get.snackbar('Berhasil', '${products.first.name} ditambahkan ke keranjang');
                  controller.searchQuery.value = ''; // clear search
                } else if (products.isEmpty) {
                  Get.snackbar('Tidak Ditemukan', 'Barcode $res tidak cocok dengan barang apapun');
                }
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final authService = Get.find<AuthService>();
        final isAdmin = authService.isAdmin;
        final shift = controller.shiftService.currentShift.value;

        if (!isAdmin && shift == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_clock, size: 80.r, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('Shift Belum Dibuka', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text('Anda harus membuka shift terlebih dahulu\nsebelum dapat melakukan transaksi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => _showOpenShiftDialog(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Buka Shift Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search Bar
            Container(
              padding: EdgeInsets.all(16.w),
              color: AppTheme.background,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'Cari barang (nama/barcode)...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                  ),
                ),
              ),
            ),
          
          // Product and Cart Split View
          Expanded(
            child: Column(
              children: [
                // Product List
                Expanded(
                  flex: 3,
                  child: Obx(() {
                    final products = controller.filteredProducts;
                    if (products.isEmpty) {
                      return const Center(child: Text('Tidak ada produk.'));
                    }
                    
                    return ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: products.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isOutOfStock = product.stock <= 0;
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            title: Text(
                              product.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppTheme.textPrimary),
                            ),
                            subtitle: Text(
                              isOutOfStock ? 'Stok Habis' : 'Stok: ${product.stock}',
                              style: TextStyle(
                                color: isOutOfStock ? Colors.red : AppTheme.textSecondary,
                                fontSize: 13.sp,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  CurrencyFormatter.formatRupiah(product.sellingPrice),
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isOutOfStock ? Colors.grey.shade100 : AppTheme.accent.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color: isOutOfStock ? Colors.grey : AppTheme.accent,
                                      size: 24.sp,
                                    ),
                                    onPressed: isOutOfStock ? null : () => controller.saleService.addToCart(product),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                
                // Cart Items List
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                          child: Row(
                            children: [
                              Icon(Icons.shopping_cart_outlined, color: AppTheme.primary, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Keranjang Belanja',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppTheme.divider),
                        Expanded(
                          child: Obx(() {
                            final cartItems = controller.saleService.cartItems;
                            if (cartItems.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.remove_shopping_cart_outlined, color: Colors.grey.shade300, size: 48.sp),
                                    SizedBox(height: 8.h),
                                    Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey.shade500)),
                                  ],
                                ),
                              );
                            }
                            
                            return ListView.separated(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              itemCount: cartItems.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.divider),
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              CurrencyFormatter.formatRupiah(item.product.sellingPrice),
                                              style: TextStyle(color: AppTheme.primary, fontSize: 13.sp, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.background,
                                          borderRadius: BorderRadius.circular(20.r),
                                          border: Border.all(color: AppTheme.divider),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => controller.saleService.updateQuantity(item.product.id, item.quantity - 1),
                                              borderRadius: BorderRadius.horizontal(left: Radius.circular(20.r)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                                child: Icon(Icons.remove, color: Colors.red.shade400, size: 18.sp),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                                              child: Text(
                                                '${item.quantity}',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => controller.saleService.updateQuantity(item.product.id, item.quantity + 1),
                                              borderRadius: BorderRadius.horizontal(right: Radius.circular(20.r)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                                child: Icon(Icons.add, color: AppTheme.primary, size: 18.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Cart Summary Bottom Bar
          Obx(() {
            final cartCount = controller.saleService.cartItems.length;
            final cartTotal = controller.saleService.cartTotal;
            
            if (cartCount == 0) return const SizedBox.shrink();
            
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$cartCount Barang',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
                          ),
                          Text(
                            CurrencyFormatter.formatRupiah(cartTotal),
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.to(() => const CheckoutView()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      ),
                      child: const Text('Bayar Sekarang'),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
      }),
    );
  }

  void _showOpenShiftDialog(BuildContext context) {
    final startBalanceController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Buka Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan modal awal (uang tunai di laci kasir):'),
            SizedBox(height: 12.h),
            TextField(
              controller: startBalanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Modal Awal (Rp)',
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountStr = startBalanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final amount = double.tryParse(amountStr) ?? 0.0;
              
              Get.back();
              // Show loading
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
              
              await controller.shiftService.openShift(amount);
              
              Get.back(); // close loading
              Get.snackbar('Shift Dibuka', 'Selamat bertugas!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Mulai Shift'),
          ),
        ],
      ),
    );
  }
}
