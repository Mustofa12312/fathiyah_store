// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/pos_controller.dart';


class CheckoutView extends GetView<PosController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Tagihan
            Center(
              child: Column(
                children: [
                  Text('Total Tagihan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp)),
                  SizedBox(height: 8.h),
                  Obx(() => Text(
                    CurrencyFormatter.formatRupiah(controller.saleService.cartTotal),
                    style: TextStyle(color: AppTheme.primary, fontSize: 32.sp, fontWeight: FontWeight.bold),
                  )),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Pemilihan Pelanggan
            Text('Pelanggan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            Obx(() {
              final selected = controller.saleService.selectedCustomer.value;
              return InkWell(
                onTap: () => _showCustomerPicker(context),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.divider),
                    borderRadius: BorderRadius.circular(12.r),
                    color: selected?.isVip == true ? AppTheme.vipGoldLight : AppTheme.surface,
                  ),
                  child: Row(
                    children: [
                      Icon(selected != null ? Icons.person : Icons.person_add_alt_1, color: AppTheme.primary),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected?.name ?? 'Pilih Pelanggan (Opsional)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            if (selected != null)
                              Text(
                                selected.isVip ? 'Pelanggan VIP ⭐' : 'Pelanggan Umum',
                                style: TextStyle(
                                  color: selected.isVip ? AppTheme.vipGold : AppTheme.textSecondary,
                                  fontWeight: selected.isVip ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            }),
            
            SizedBox(height: 24.h),
            
            // Input Nominal Uang
            Text('Nominal Uang Diterima', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.paidAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
              ),
            ),

            SizedBox(height: 16.h),
            
            // VIP Info Box
            Obx(() {
              final selected = controller.saleService.selectedCustomer.value;
              if (selected == null || !selected.isVip) {
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8.r)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade400),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Pelanggan UMUM wajib lunas. Tidak bisa menginput uang kurang dari tagihan.',
                          style: TextStyle(color: Colors.red.shade900, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: AppTheme.vipGoldLight, borderRadius: BorderRadius.circular(8.r)),
                child: Row(
                  children: [
                    Icon(Icons.star, color: AppTheme.vipGold),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Pelanggan VIP diizinkan membayar sebagian. Sisa pembayaran akan dicatat sebagai Piutang.',
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            SizedBox(height: 32.h),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.processPayment,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16.h)),
                child: const Text('Proses Transaksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Text('Pilih Pelanggan', style: Theme.of(context).textTheme.displayMedium),
              ),
              Expanded(
                child: Obx(() {
                  final customers = controller.customers;
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: customers.length,
                    separatorBuilder: (c,i) => Divider(height: 1, color: AppTheme.divider),
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: c.isVip ? AppTheme.vipGoldLight : AppTheme.divider,
                          child: Icon(c.isVip ? Icons.star : Icons.person, color: c.isVip ? AppTheme.vipGold : AppTheme.textSecondary),
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.phone),
                        onTap: () {
                          controller.selectCustomer(c);
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: TextButton(
                  onPressed: () {
                    controller.selectCustomer(null);
                    Get.back();
                  },
                  child: const Text('Tanpa Pelanggan (Umum)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
