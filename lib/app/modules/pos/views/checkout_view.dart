// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/pos_controller.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class CheckoutView extends GetView<PosController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.sp),
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Pembayaran',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Tagihan Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Total Tagihan', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          Obx(() => Text(
                            CurrencyFormatter.formatRupiah(controller.saleService.cartTotal),
                            style: TextStyle(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.bold),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Pemilihan Pelanggan
                    Text('Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textSecondary)),
                    SizedBox(height: 8.h),
                    Obx(() {
                      final selected = controller.saleService.selectedCustomer.value;
                      final isVip = selected?.isVip == true;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: isVip ? AppTheme.vipGold : Colors.grey.shade100, width: isVip ? 2 : 1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showCustomerPicker(context),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: isVip ? AppTheme.vipGoldLight : AppTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      selected != null ? Icons.person_rounded : Icons.person_add_alt_1_rounded,
                                      color: isVip ? AppTheme.vipGold : AppTheme.primary,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selected?.name ?? 'Pilih Pelanggan (Opsional)',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary),
                                        ),
                                        if (selected != null)
                                          Text(
                                            isVip ? 'Pelanggan VIP ⭐' : 'Pelanggan Umum',
                                            style: TextStyle(
                                              color: isVip ? AppTheme.vipGold : AppTheme.textSecondary,
                                              fontSize: 12.sp,
                                              fontWeight: isVip ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    SizedBox(height: 24.h),
                    
                    // Input Nominal Uang
                    Text('Nominal Uang Diterima', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textSecondary)),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.paidAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        CurrencyTextInputFormatter.currency(
                          locale: 'id_ID',
                          decimalDigits: 0,
                          symbol: 'Rp ',
                        )
                      ],
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    
                    // Quick Cash Buttons
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _buildQuickCashButton('Uang Pas', controller.saleService.cartTotal),
                        _buildQuickCashButton('10.000', 10000),
                        _buildQuickCashButton('20.000', 20000),
                        _buildQuickCashButton('50.000', 50000),
                        _buildQuickCashButton('100.000', 100000),
                      ],
                    ),

                    SizedBox(height: 16.h),
                    
                    // VIP Info Box
                    Obx(() {
                      final selected = controller.saleService.selectedCustomer.value;
                      if (selected == null || !selected.isVip) {
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12.r)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.red.shade400, size: 20.sp),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Pelanggan UMUM wajib lunas. Tidak bisa menginput uang kurang dari tagihan.',
                                  style: TextStyle(color: Colors.red.shade900, fontSize: 13.sp),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(color: AppTheme.vipGoldLight, borderRadius: BorderRadius.circular(12.r)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.star_rounded, color: AppTheme.vipGold, size: 20.sp),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Pelanggan VIP diizinkan membayar sebagian. Sisa pembayaran akan dicatat sebagai Piutang.',
                                style: TextStyle(color: Colors.orange.shade900, fontSize: 13.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    SizedBox(height: 40.h),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 4,
                          shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                        ),
                        child: Text('Proses Transaksi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCashButton(String label, double amount) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppTheme.primary, width: 1),
      ),
      onPressed: () {
        controller.paidAmountController.text = CurrencyFormatter.formatRupiah(amount);
      },
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.textPrimary)),
                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final customers = controller.customers;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: c.isVip ? AppTheme.vipGold : Colors.grey.shade100),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          leading: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: c.isVip ? AppTheme.vipGoldLight : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                if (!c.isVip) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                              ]
                            ),
                            child: Icon(c.isVip ? Icons.star_rounded : Icons.person_rounded, color: c.isVip ? AppTheme.vipGold : AppTheme.textSecondary),
                          ),
                          title: Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          subtitle: Text(c.phone, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                          onTap: () {
                            controller.selectCustomer(c);
                            Get.back();
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.selectCustomer(null);
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary, width: 2),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text('Tanpa Pelanggan (Umum)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
