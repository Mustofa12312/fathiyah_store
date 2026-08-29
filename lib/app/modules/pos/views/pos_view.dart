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
              color: AppTheme.surface,
              child: TextField(
                onChanged: (value) => controller.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Cari barang (nama/barcode)...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
                ),
              ),
            ),
          
          // Product List Grid
          Expanded(
            child: Obx(() {
              final products = controller.filteredProducts;
              if (products.isEmpty) {
                return const Center(child: Text('Tidak ada produk.'));
              }
              
              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.w,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isOutOfStock = product.stock <= 0;
                  
                  return Card(
                    child: InkWell(
                      onTap: isOutOfStock ? null : () => controller.saleService.addToCart(product),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.divider,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                              ),
                              child: Icon(Icons.inventory_2_outlined, color: AppTheme.textSecondary, size: 40.sp),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  CurrencyFormatter.formatRupiah(product.sellingPrice),
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  isOutOfStock ? 'Stok Habis' : 'Stok: ${product.stock}',
                                  style: TextStyle(
                                    color: isOutOfStock ? Colors.red : AppTheme.textSecondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
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
                    color: Colors.black.withOpacity(0.05),
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
                      onPressed: () => _showCartBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      ),
                      child: const Text('Cek Keranjang'),
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

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keranjang', style: Theme.of(context).textTheme.displayMedium),
                  TextButton(
                    onPressed: () {
                      controller.saleService.clearCart();
                      Get.back();
                    },
                    child: Text('Kosongkan', style: TextStyle(color: Colors.red.shade400)),
                  ),
                ],
              ),
            ),
            
            // Cart Items
            Expanded(
              child: Obx(() {
                final items = controller.saleService.cartItems;
                return ListView.separated(
                  padding: EdgeInsets.all(24.w),
                  itemCount: items.length,
                  separatorBuilder: (c, i) => Divider(color: AppTheme.divider, height: 32.h),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              SizedBox(height: 4.h),
                              Text(CurrencyFormatter.formatRupiah(item.product.sellingPrice), style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        // Qty control
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => controller.saleService.updateQuantity(item.product.id, item.quantity - 1),
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppTheme.primary,
                            ),
                            Text('${item.quantity}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            IconButton(
                              onPressed: () => controller.saleService.updateQuantity(item.product.id, item.quantity + 1),
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
            
            // Checkout Footer
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                border: Border(top: BorderSide(color: AppTheme.divider)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: TextStyle(fontSize: 16.sp)),
                        Obx(() => Text(
                          CurrencyFormatter.formatRupiah(controller.saleService.cartTotal),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: AppTheme.primary),
                        )),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // close cart
                          Get.to(() => const CheckoutView()); // to checkout
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: const Text('Lanjut ke Pembayaran'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
