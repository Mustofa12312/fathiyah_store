import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/supervisor_auth_dialog.dart';
import '../controllers/transaction_controller.dart';
import '../../pos/views/receipt_view.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        final sales = controller.saleService.sales;
        
        if (sales.isEmpty) {
          return Center(
            child: Text(
              'Belum ada transaksi',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            final isVoided = sale.transactionStatus == 'voided';
            
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: isVoided ? Colors.red.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isVoided ? Colors.red.shade200 : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.w),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRX-${sale.id.substring(0, 8).toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: isVoided ? TextDecoration.lineThrough : null),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(sale.totalAmount),
                      style: TextStyle(fontWeight: FontWeight.bold, color: isVoided ? Colors.red : AppTheme.primary),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Text('${DateFormat('dd MMM yyyy HH:mm').format(sale.createdAt)} • Kasir: ${sale.cashierName}'),
                    if (isVoided)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text('TRANSAKSI DIBATALKAN (VOID)', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      color: Colors.white,
                      child: SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.receipt),
                              title: const Text('Lihat Struk'),
                              onTap: () {
                                Get.back();
                                Get.to(() => ReceiptView(sale: sale));
                              },
                            ),
                            if (!isVoided)
                              ListTile(
                                leading: const Icon(Icons.cancel, color: Colors.red),
                                title: const Text('Batalkan Transaksi (Void)', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Get.back();
                                  SupervisorAuthDialog.show(
                                    actionDescription: 'Pembatalan transaksi memerlukan otorisasi Supervisor.',
                                    onSuccess: () => _showVoidConfirmationDialog(context, controller, sale.id),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  void _showVoidConfirmationDialog(BuildContext context, TransactionController controller, String saleId) {
    Get.defaultDialog(
      title: 'Batalkan Transaksi',
      middleText: 'Apakah Anda yakin ingin membatalkan transaksi ini? Stok barang akan dikembalikan dan nominal kas akan disesuaikan.',
      textConfirm: 'Ya, Batalkan',
      textCancel: 'Tidak',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: AppTheme.textPrimary,
      onConfirm: () {
        controller.voidTransaction(saleId);
        Get.back();
      },
    );
  }
}
