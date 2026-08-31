// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../controllers/debt_controller.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/sale_model.dart';

class DebtDetailView extends GetView<DebtController> {
  final CustomerModel customer;

  const DebtDetailView({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rincian Piutang: ${customer.name}'),
      ),
      body: FutureBuilder<List<SaleModel>>(
        future: controller.getUnpaidSalesFor(customer.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final unpaidSales = snapshot.data ?? [];
          
          if (unpaidSales.isEmpty) {
            return Center(
              child: Text('Tidak ada piutang aktif.', style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: unpaidSales.length,
            itemBuilder: (context, index) {
              final sale = unpaidSales[index];
              return _buildDebtCard(context, sale);
            },
          );
        },
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, SaleModel sale) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(sale.createdAt),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'TRX-${sale.id.substring(0, 6).toUpperCase()}',
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Belanja:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                Text(CurrencyFormatter.formatRupiah(sale.totalAmount), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sudah Dibayar:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                Text(CurrencyFormatter.formatRupiah(sale.paidAmount), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 8.h),
            Divider(color: AppTheme.divider),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sisa Piutang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text(
                  CurrencyFormatter.formatRupiah(sale.remainingAmount),
                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPaymentDialog(context, sale),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.vipGold,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bayar Cicilan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, SaleModel sale) {
    final TextEditingController amountController = TextEditingController();

    Get.defaultDialog(
      title: 'Bayar Cicilan',
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sisa tagihan: ${CurrencyFormatter.formatRupiah(sale.remainingAmount)}'),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyTextInputFormatter.currency(
                  locale: 'id_ID',
                  decimalDigits: 0,
                  symbol: 'Rp ',
                )
              ],
              decoration: const InputDecoration(
                labelText: 'Nominal Bayar',
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Proses Bayar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.primary,
      onConfirm: () {
        final amountStr = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final amount = int.tryParse(amountStr) ?? 0;
        
        if (amount <= 0) {
          Get.snackbar('Error', 'Masukkan nominal yang valid');
          return;
        }

        if (amount > sale.remainingAmount) {
          Get.snackbar('Error', 'Nominal melebihi sisa tagihan');
          return;
        }

        controller.payDebt(sale.id, amount).then((_) {
          Get.back(); // close dialog
          Get.snackbar('Sukses', 'Pembayaran berhasil dicatat', backgroundColor: Colors.green.shade100);
        });
      },
    );
  }
}
