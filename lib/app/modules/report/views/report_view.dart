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
      appBar: AppBar(
        title: const Text('Laporan & Analitik'),
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
                // Filter Waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Periode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: c.selectedFilter.value,
                          items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Semua']
                              .map((f) => DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontSize: 14.sp))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) c.setFilter(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Cash in Hand Highlight
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
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Uang Tunai Masuk (${c.selectedFilter.value})', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
                      SizedBox(height: 8.h),
                      Text(
                        CurrencyFormatter.formatRupiah(c.filteredCashInHand),
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
                              Text(CurrencyFormatter.formatRupiah(c.filteredOmzet), style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total Piutang Baru', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                              Text(CurrencyFormatter.formatRupiah(c.filteredOmzet - c.filteredCashInHand), style: TextStyle(color: AppTheme.vipGold, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 24.h),
                
                // Chart Section
                Text('Tren 7 Hari Terakhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                SizedBox(height: 12.h),
                Container(
                  height: 250.h,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: _buildBarChart(c),
                ),

                SizedBox(height: 24.h),
                Text('Analisis Laba/Rugi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                SizedBox(height: 12.h),

                _buildReportCard('Laba Kotor (Omzet - Modal)', c.filteredGrossProfit, Icons.trending_up, Colors.green),
                _buildReportCard('Pengeluaran', c.filteredExpense, Icons.trending_down, Colors.red, onTap: () => Get.to(() => const ExpenseListView())),
                
                SizedBox(height: 12.h),
                Divider(color: AppTheme.divider, thickness: 2),
                SizedBox(height: 12.h),
                
                _buildReportCard('Laba Bersih', c.filteredNetProfit, Icons.account_balance, AppTheme.primary, isHighlight: true),
                
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(() => const ExpenseListView()),
                        icon: const Icon(Icons.outbound),
                        label: const Text('Kelola Pengeluaran'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade700),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => c.exportCSV(),
                        icon: const Icon(Icons.download),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
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
              width: 8.w,
              borderRadius: BorderRadius.circular(4.r),
            ),
            BarChartRodData(
              toY: weeklyExpense[i],
              color: Colors.red.shade400,
              width: 8.w,
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
                final format = DateFormat('E').format(date); // e.g. Mon, Tue
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(format, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.sp)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide left titles to save space
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal / 4,
          getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
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
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
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
