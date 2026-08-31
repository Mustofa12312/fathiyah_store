// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/report_controller.dart';
import '../../expense/views/expense_list_view.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: GetBuilder<ReportController>(
          builder: (c) {
            return Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Analitik',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.refresh_rounded, color: AppTheme.primary),
                              onPressed: () => controller.refreshData(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Filter Waktu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Periode Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textSecondary)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: c.selectedFilter.value,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary, size: 20.sp),
                                items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Semua']
                                    .map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primary))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) c.setFilter(val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Body Scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cash in Hand Highlight
                        Container(
                          padding: EdgeInsets.all(24.w),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text('Uang Tunai Masuk', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14.sp)),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                CurrencyFormatter.formatRupiah(c.filteredCashInHand),
                                style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 24.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Total Omzet', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                                        SizedBox(height: 4.h),
                                        Text(CurrencyFormatter.formatRupiah(c.filteredOmzet), style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Container(width: 1, height: 30.h, color: Colors.white24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Piutang Baru', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                                        SizedBox(height: 4.h),
                                        Text(CurrencyFormatter.formatRupiah(c.filteredOmzet - c.filteredCashInHand), style: TextStyle(color: AppTheme.vipGold, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),
                        
                        // Chart Section
                        Text('Tren 7 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.textPrimary)),
                        SizedBox(height: 16.h),
                        Container(
                          height: 250.h,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: _buildBarChart(c),
                        ),

                        SizedBox(height: 32.h),
                        Text('Analisis Keuangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.textPrimary)),
                        SizedBox(height: 16.h),

                        _buildReportCard('Laba Kotor', 'Omzet - Modal', c.filteredGrossProfit, Icons.trending_up_rounded, Colors.green),
                        _buildReportCard('Pengeluaran', 'Biaya Operasional', c.filteredExpense, Icons.trending_down_rounded, Colors.red, onTap: () => Get.to(() => const ExpenseListView())),
                        
                        SizedBox(height: 8.h),
                        
                        _buildReportCard('Laba Bersih', 'Profit Akhir', c.filteredNetProfit, Icons.emoji_events_rounded, AppTheme.primary, isHighlight: true),
                        
                        SizedBox(height: 32.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Get.to(() => const ExpenseListView()),
                                icon: Icon(Icons.account_balance_wallet_rounded, size: 20.sp),
                                label: const Text('Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  foregroundColor: Colors.red.shade600,
                                  side: BorderSide(color: Colors.red.shade200, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => c.exportCSV(),
                                icon: Icon(Icons.file_download_rounded, size: 20.sp),
                                label: const Text('Export Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                  elevation: 4,
                                  shadowColor: Colors.green.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBarChart(ReportController c) {
    final weeklyOmzet = c.getWeeklyOmzetData();
    final weeklyExpense = c.getWeeklyExpenseData();
    
    // Find max value for Y axis scaling
    double maxVal = 0;
    for (var val in weeklyOmzet) {
      if (val > maxVal) maxVal = val;
    }
    for (var val in weeklyExpense) {
      if (val > maxVal) maxVal = val;
    }
    
    // Fallback if no data
    if (maxVal == 0) maxVal = 100000;
    
    // Create bar groups
    List<BarChartGroupData> barGroups = [];
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: weeklyOmzet[i],
              color: AppTheme.primary,
              width: 10.w,
              borderRadius: BorderRadius.circular(4.r),
            ),
            BarChartRodData(
              toY: weeklyExpense[i],
              color: Colors.red.shade400,
              width: 10.w,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ],
        )
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = now.subtract(Duration(days: 6 - value.toInt()));
                final indoDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final format = indoDays[date.weekday - 1];
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(format, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal / 4,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1.5, dashArray: [5, 5]),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildReportCard(String title, String subtitle, int amount, IconData icon, Color color, {bool isHighlight = false, VoidCallback? onTap}) {
    final card = Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isHighlight ? color.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isHighlight ? Border.all(color: color.withValues(alpha: 0.3), width: 2) : Border.all(color: Colors.transparent),
        boxShadow: isHighlight 
            ? [] 
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppTheme.textPrimary)),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.formatRupiah(amount),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: color),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
            ]
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: card,
        ),
      );
    }
    return card;
  }
}
