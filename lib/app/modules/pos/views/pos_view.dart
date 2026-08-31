// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/pos_controller.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'checkout_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/services/printer_service.dart';
import 'package:fathiyah_store/app/data/services/auth_service.dart';
import '../../../core/widgets/supervisor_auth_dialog.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PosController()); // Ensure controller is loaded
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() {
        final authService = Get.find<AuthService>();
        final isAdmin = authService.isAdmin;
        final shift = controller.shiftService.currentShift.value;

        if (!isAdmin && shift == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_clock_rounded, size: 80.r, color: Colors.grey.shade300),
                SizedBox(height: 16.h),
                Text('Shift Belum Dibuka', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                SizedBox(height: 8.h),
                Text('Anda harus membuka shift terlebih dahulu\nsebelum dapat melakukan transaksi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp)),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => _showOpenShiftDialog(context),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Buka Shift Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              // Header & Search
              Container(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
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
                          'Kasir',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                SimpleBarcodeScanner.streamBarcode(
                                  context,
                                  cancelButtonText: 'Selesai',
                                  isShowFlashIcon: true,
                                ).listen((res) {
                                  if (res != '-1') {
                                    HapticFeedback.vibrate();
                                    controller.searchQuery.value = res;
                                    final products = controller.filteredProducts;
                                    if (products.length == 1) {
                                      controller.saleService.addToCart(products.first);
                                      Get.snackbar('Berhasil', '${products.first.name} ditambahkan ke keranjang', snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
                                      controller.searchQuery.value = ''; // clear search
                                    } else if (products.isEmpty) {
                                      Get.snackbar('Tidak Ditemukan', 'Barcode $res tidak cocok dengan barang apapun', snackPosition: SnackPosition.TOP, backgroundColor: Colors.white);
                                    }
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Printer Status Indicator
                            Obx(() {
                              final isPrinterConnected = Get.find<PrinterService>().isConnected.value;
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: isPrinterConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPrinterConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                                      color: isPrinterConnected ? Colors.green : Colors.red,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      isPrinterConnected ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color: isPrinterConnected ? Colors.green : Colors.red,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
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
          
          // Product and Cart Split View
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                final layoutChildren = [
                // Product List
                Expanded(
                  flex: 3,
                  child: Obx(() {
                    final products = controller.filteredProducts;
                    if (products.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        title: 'Produk Tidak Ditemukan',
                        subtitle: 'Coba gunakan kata kunci atau barcode yang berbeda.',
                      );
                    }
                    
                    return ListView.builder(
                      padding: EdgeInsets.all(24.w),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isOutOfStock = product.stock <= 0;
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4)),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                // Icon or Image
                                Container(
                                  width: 50.w,
                                  height: 50.w,
                                  decoration: BoxDecoration(
                                    color: isOutOfStock ? Colors.grey.shade50 : AppTheme.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: product.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(child: SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 2))),
                                          errorWidget: (context, url, error) => Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 24.sp),
                                        )
                                      : Icon(Icons.inventory_2_rounded, color: isOutOfStock ? Colors.grey : AppTheme.primary, size: 24.sp),
                                ),
                                SizedBox(width: 16.w),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        isOutOfStock ? 'Stok Habis' : 'Stok: ${product.stock}',
                                        style: TextStyle(
                                          color: isOutOfStock ? Colors.red.shade400 : AppTheme.textSecondary,
                                          fontSize: 13.sp,
                                          fontWeight: isOutOfStock ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price & Add button
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatRupiah(product.sellingPrice),
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    InkWell(
                                      onTap: isOutOfStock ? null : () => controller.saleService.addToCart(product),
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: isOutOfStock ? Colors.grey.shade200 : AppTheme.accent,
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.add_shopping_cart_rounded, color: isOutOfStock ? Colors.grey : Colors.white, size: 16.sp),
                                            SizedBox(width: 6.w),
                                            Text(
                                              'Tambah',
                                              style: TextStyle(color: isOutOfStock ? Colors.grey : Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                  child: _buildCartList(),
                ),
                ];
                
                return isTablet
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          layoutChildren[0], // Left: Products
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                layoutChildren[1], // Right top: Cart List
                                _buildCartSummaryBottomBar(), // Right bottom: Summary
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: layoutChildren[0]), // Top: Products
                          // Bottom sheet cart for mobile
                        ],
                      );
              },
            ),
          ),
          
          // Cart Summary Bottom Bar for Mobile
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) return const SizedBox.shrink(); // Handled in split screen
              return _buildCartSummaryBottomBar();
            },
          ),
        ],
      ),
    );
  }),
);
}

  Widget _buildCartSummaryBottomBar() {
    return Obx(() {
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
                child: InkWell(
                  onTap: () => _showMobileCartSheet(Get.context!),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$cartCount Barang',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.keyboard_arrow_up_rounded, size: 16.sp, color: AppTheme.textSecondary),
                          ],
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
    });
  }

  void _showOpenShiftDialog(BuildContext context) {
    final startBalanceController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buka Shift', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16.h),
            const Text('Masukkan modal awal (uang tunai di laci kasir):'),
            SizedBox(height: 12.h),
            TextField(
              controller: startBalanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyTextInputFormatter.currency(
                  locale: 'id_ID',
                  decimalDigits: 0,
                  symbol: 'Rp ',
                )
              ],
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Modal Awal',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: () async {
                    final amountStr = startBalanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(amountStr) ?? 0.0;
                    
                    Get.back();
                    // Show loading
                    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                    
                    await controller.shiftService.openShift(amount);
                    
                    Get.back(); // close loading
                    Get.snackbar('Shift Dibuka', 'Selamat bertugas!', snackPosition: SnackPosition.TOP);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  child: const Text('Mulai Shift'),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showMobileCartSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(child: _buildCartList()),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildCartList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, -5)),
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
                const Spacer(),
                Obx(() {
                  final holdCount = controller.saleService.holdOrders.length;
                  return PopupMenuButton<String>(
                    icon: Stack(
                      children: [
                        const Icon(Icons.more_vert),
                        if (holdCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                              child: Text('$holdCount', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                            ),
                          ),
                      ],
                    ),
                    onSelected: (value) {
                      if (value == 'hold') {
                        _showHoldOrderDialog(Get.context!);
                      } else if (value == 'restore') {
                        _showRestoreOrderDialog(Get.context!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'hold',
                        child: Text('Tunda Pesanan (Hold)'),
                      ),
                      const PopupMenuItem(
                        value: 'restore',
                        child: Text('Daftar Pesanan Tertunda'),
                      ),
                    ],
                  );
                }),
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
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shopping_cart_outlined, color: Colors.grey.shade300, size: 48.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text('Keranjang masih kosong', style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp)),
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
                                  style: TextStyle(color: AppTheme.primary, fontSize: 14.sp, fontWeight: FontWeight.w700),
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
                                onTap: () {
                                  if (item.quantity == 1) {
                                    // If quantity will be 0 (deleted), require PIN
                                    SupervisorAuthDialog.show(
                                      actionDescription: 'Penghapusan item ${item.product.name} dari keranjang memerlukan izin Supervisor.',
                                      onSuccess: () => controller.saleService.updateQuantity(item.product.id, item.quantity - 1),
                                    );
                                  } else {
                                    // Just reducing quantity
                                    controller.saleService.updateQuantity(item.product.id, item.quantity - 1);
                                  }
                                },
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
    );
  }

  void _showHoldOrderDialog(BuildContext context) {
    if (controller.saleService.cartItems.isEmpty) {
      Get.snackbar('Gagal', 'Keranjang belanja masih kosong', backgroundColor: Colors.red.shade100);
      return;
    }
    
    final noteController = TextEditingController();
    Get.defaultDialog(
      title: 'Tunda Pesanan',
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Catatan (mis: Meja 1, Bapak A)',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.primary,
      onConfirm: () {
        controller.saleService.holdOrder(noteController.text.isEmpty ? 'Tanpa Catatan' : noteController.text);
        Get.back(); // close dialog
        if (MediaQuery.of(context).size.width <= 600) {
           Get.back(); // close bottom sheet if mobile
        }
      },
    );
  }

  void _showRestoreOrderDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daftar Pesanan Tertunda', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            const Divider(),
            Obx(() {
              final holds = controller.saleService.holdOrders;
              if (holds.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w), 
                  child: Center(child: Text('Tidak ada pesanan tertunda', style: TextStyle(color: Colors.grey.shade600)))
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: holds.length,
                itemBuilder: (context, index) {
                  final h = holds[index];
                  return ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.pause_circle_outline, color: AppTheme.primary),
                    ),
                    title: Text(h.note, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${h.items.length} Barang - ${h.time.hour.toString().padLeft(2, '0')}:${h.time.minute.toString().padLeft(2, '0')}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        controller.saleService.restoreOrder(h.id);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                      child: const Text('Lanjutkan'),
                    ),
                  );
                },
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
