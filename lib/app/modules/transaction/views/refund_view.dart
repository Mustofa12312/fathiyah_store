import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/refund_controller.dart';
import '../../../data/models/sale_model.dart';

class RefundView extends StatelessWidget {
  final SaleModel sale;

  const RefundView({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    // Inject the controller scoped to this specific sale
    final controller = Get.put(RefundController(sale: sale));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Retur Barang TRX-${sale.id.substring(0, 6).toUpperCase()}'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: sale.items.length,
              itemBuilder: (context, index) {
                final item = sale.items[index];
                return _buildItemRow(controller, item);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Uang Kembali:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Obx(() => Text(
                        CurrencyFormatter.formatRupiah(controller.totalRefundAmount),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      )),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: controller.hasItemsToReturn 
                        ? () => _showConfirmationDialog(controller)
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text('Proses Retur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(RefundController controller, SaleItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                SizedBox(height: 4.h),
                Text(
                  '${item.quantity}x ${CurrencyFormatter.formatRupiah(item.price)}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Obx(() {
            final returnQty = controller.returnQuantities[item.productId] ?? 0;
            return Row(
              children: [
                IconButton(
                  onPressed: () => controller.decrementReturn(item.productId),
                  icon: Icon(Icons.remove_circle_outline, color: returnQty > 0 ? AppTheme.primary : Colors.grey),
                ),
                Text(
                  '$returnQty',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => controller.incrementReturn(item.productId, item.quantity),
                  icon: Icon(Icons.add_circle_outline, color: returnQty < item.quantity ? AppTheme.primary : Colors.grey),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showConfirmationDialog(RefundController controller) {
    Get.defaultDialog(
      title: 'Konfirmasi Retur',
      middleText: 'Apakah Anda yakin ingin memproses retur barang ini? Uang kas sebesar ${CurrencyFormatter.formatRupiah(controller.totalRefundAmount)} akan dipotong.',
      textConfirm: 'Ya, Proses',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange.shade800,
      cancelTextColor: AppTheme.textPrimary,
      onConfirm: () {
        Get.back();
        controller.processRefund();
      },
    );
  }
}
