import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../controllers/debt_controller.dart';
import 'debt_detail_view.dart';

class DebtListView extends GetView<DebtController> {
  const DebtListView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DebtController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Buku Piutang VIP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () => controller.fetchDebts(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalDebt = controller.totalActiveDebt;
        final activeCount = controller.customersWithDebt.length;
        final paidCount = controller.customersWithPaidDebt.length;
        final customers = controller.filteredCustomers;
        final debts = controller.customerDebts;
        final currentFilter = controller.selectedFilter.value;

        return Column(
          children: [
            // Header Ringkasan Piutang
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28.sp),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Piutang Aktif',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.sp),
                        ),
                        SizedBox(height: 2.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyFormatter.formatRupiah(totalDebt),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$activeCount Pelanggan Berhutang • $paidCount Lunas',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau no. telepon...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: AppTheme.textSecondary),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => controller.searchQuery.value = '',
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Filter Tabs (Belum Lunas vs Sudah Lunas vs Semua)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildFilterChip('belum_lunas', 'Belum Lunas', count: activeCount, color: Colors.orange.shade800),
                  SizedBox(width: 8.w),
                  _buildFilterChip('lunas', 'Sudah Lunas', count: paidCount, color: Colors.green.shade700),
                  SizedBox(width: 8.w),
                  _buildFilterChip('semua', 'Semua', count: activeCount + paidCount, color: AppTheme.primary),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Daftar Pelanggan
            Expanded(
              child: customers.isEmpty
                  ? EmptyStateWidget(
                      icon: currentFilter == 'belum_lunas'
                          ? Icons.check_circle_outline_rounded
                          : Icons.receipt_long_rounded,
                      title: currentFilter == 'belum_lunas'
                          ? 'Tidak Ada Piutang Belum Lunas'
                          : (currentFilter == 'lunas' ? 'Belum Ada Riwayat Lunas' : 'Data Tidak Ditemukan'),
                      subtitle: currentFilter == 'belum_lunas'
                          ? 'Hebat! Semua tagihan piutang pelanggan saat ini telah lunas.'
                          : 'Belum ada transaksi pelanggan pada kategori ini.',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final c = customers[index];
                        final customerDebt = debts[c.id] ?? 0;
                        final isLunas = customerDebt <= 0;

                        return Card(
                          margin: EdgeInsets.only(bottom: 12.h),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                              color: isLunas ? Colors.green.shade100 : Colors.orange.shade100,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.r),
                            onTap: () {
                              Get.to(() => DebtDetailView(customer: c))?.then((_) {
                                controller.fetchDebts();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isLunas ? Colors.green.shade50 : AppTheme.vipGoldLight,
                                    radius: 24.r,
                                    child: Icon(
                                      isLunas ? Icons.check_circle_rounded : Icons.star_rounded,
                                      color: isLunas ? Colors.green.shade700 : AppTheme.vipGold,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                c.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: isLunas ? Colors.green.shade50 : Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                isLunas ? 'LUNAS' : 'BELUM LUNAS',
                                                style: TextStyle(
                                                  color: isLunas ? Colors.green.shade800 : Colors.red.shade800,
                                                  fontSize: 9.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          c.phone.isNotEmpty && c.phone != '-' ? c.phone : 'Pelanggan Toko',
                                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        isLunas ? 'Status' : 'Sisa Piutang',
                                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.sp),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        isLunas ? 'Lunas 100%' : CurrencyFormatter.formatRupiah(customerDebt),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color: isLunas ? Colors.green.shade700 : Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20.sp),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(String key, String label, {required int count, required Color color}) {
    final isSelected = controller.selectedFilter.value == key;
    return InkWell(
      onTap: () => controller.selectedFilter.value = key,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
