import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fathiyah_store/app/core/theme/app_theme.dart';
import 'package:fathiyah_store/app/core/utils/currency_formatter.dart';
import 'package:fathiyah_store/app/data/services/shift_service.dart';

class ShiftListView extends StatelessWidget {
  const ShiftListView({super.key});

  @override
  Widget build(BuildContext context) {
    final shiftService = Get.find<ShiftService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Laporan Shift Kasir', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
      ),
      body: Obx(() {
        final shifts = shiftService.shifts;

        if (shifts.isEmpty) {
          return const Center(child: Text('Belum ada riwayat shift.'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: shifts.length,
          itemBuilder: (context, index) {
            final shift = shifts[index];
            final bool isOpen = shift.status == 'open';

            final expectedBalance = shift.startBalance + shift.totalSalesCash - shift.totalExpensesCash;
            final variance = (shift.endBalance ?? 0) - expectedBalance;
            final bool isMinus = variance < 0;

            return Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                shift.cashierName.isNotEmpty ? shift.cashierName[0].toUpperCase() : '?',
                                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shift.cashierName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(shift.startTime),
                                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isOpen ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            isOpen ? 'AKTIF' : 'DITUTUP',
                            style: TextStyle(
                              color: isOpen ? Colors.green : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('Modal Awal', shift.startBalance, Colors.black87),
                        _buildStat('Penjualan', shift.totalSalesCash, Colors.green),
                        _buildStat('Pengeluaran', shift.totalExpensesCash, Colors.red),
                      ],
                    ),
                    if (!isOpen) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isMinus ? Colors.red.withValues(alpha: 0.05) : Colors.green.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: isMinus ? Colors.red.shade100 : Colors.green.shade100),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Uang Seharusnya (Sistem):', style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                                Text(CurrencyFormatter.formatRupiah(expectedBalance), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Uang Fisik Kasir:', style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                                Text(CurrencyFormatter.formatRupiah(shift.endBalance ?? 0), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Selisih:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                Text(
                                  (variance > 0 ? '+' : '') + CurrencyFormatter.formatRupiah(variance),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isMinus ? Colors.red : (variance == 0 ? Colors.green : Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStat(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary)),
        SizedBox(height: 4.h),
        Text(
          CurrencyFormatter.formatRupiah(amount),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: color),
        ),
      ],
    );
  }
}
