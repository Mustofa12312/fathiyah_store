import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/report_controller.dart';
import '../../expense/views/expense_list_view.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put here because it's part of Dashboard tab
    final controller = Get.put(ReportController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshData(),
          )
        ],
      ),
      body: GetBuilder<ReportController>(
        builder: (c) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Highlight: Cash in Hand
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Uang Tunai di Laci (Cash in Hand)', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                      SizedBox(height: 8.h),
                      Text(
                        CurrencyFormatter.formatRupiah(c.todayCashInHand),
                        style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Omzet', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                              Text(CurrencyFormatter.formatRupiah(c.todayOmzet), style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Piutang Baru', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                              Text(CurrencyFormatter.formatRupiah(c.todayOmzet - c.todayCashInHand), style: TextStyle(color: AppTheme.vipGold, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Laba & Pengeluaran
                Text('Analisis Laba/Rugi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                SizedBox(height: 12.h),

                _buildReportCard('Laba Kotor (Omzet - Modal)', c.todayGrossProfit, Icons.trending_up, Colors.green),
                _buildReportCard('Pengeluaran Hari Ini', c.todayExpense, Icons.trending_down, Colors.red, onTap: () => Get.to(() => const ExpenseListView())),
                
                SizedBox(height: 12.h),
                Divider(color: AppTheme.divider, thickness: 2),
                SizedBox(height: 12.h),
                
                _buildReportCard('Laba Bersih', c.todayNetProfit, Icons.account_balance, AppTheme.primary, isHighlight: true),
                
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const ExpenseListView()),
                    icon: const Icon(Icons.outbound),
                    label: const Text('Kelola Pengeluaran Toko'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade700),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(String title, double amount, IconData icon, Color color, {bool isHighlight = false, VoidCallback? onTap}) {
    final card = Card(
      color: isHighlight ? AppTheme.surface : Colors.white,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isHighlight ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal, fontSize: 14.sp)),
            ),
            Text(
              CurrencyFormatter.formatRupiah(amount),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: color),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ]
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: card,
      );
    }
    return card;
  }
}
