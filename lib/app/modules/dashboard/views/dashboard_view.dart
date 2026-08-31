import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/dashboard_controller.dart';
import '../../product/views/product_list_view.dart';
import '../../customer/views/customer_list_view.dart';
import '../../pos/views/pos_view.dart';
import '../../debt/views/debt_list_view.dart';
import '../../report/views/report_view.dart';
import '../../expense/views/expense_list_view.dart';
import '../../transaction/views/transaction_list_view.dart';

import '../../settings/views/settings_view.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/currency_formatter.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isAdmin = authService.isAdmin;
    final isSupervisor = authService.isSupervisor;
    final isCashier = authService.isCashier;

    return Scaffold(
      body: Obx(() {
        final isOffline = Get.find<ConnectivityService>().isOffline.value;
        return Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                color: Colors.red.shade400,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8.h, 
                  bottom: 8.h,
                ),
                child: Center(
                  child: Text(
                    'Mode Offline - Data akan disinkronkan saat online',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: [
                  _buildHomeTab(context, isAdmin, isSupervisor, isCashier),
                  if (!isCashier) const ProductListView() else const Center(child: Text('Akses Ditolak')),
                  const PosView(),
                  if (isAdmin) const ReportView() else const Center(child: Text('Akses Ditolak')),
                  if (isAdmin) const SettingsView() else const Center(child: Text('Akses Ditolak')),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    'Home',
                    controller.currentIndex.value,
                  ),
                  _buildNavItem(
                    1,
                    Icons.inventory_2_rounded,
                    'Produk',
                    controller.currentIndex.value,
                    disabled: isCashier,
                    disabledMsg: 'Kasir tidak dapat mengakses menu Produk',
                  ),
                  _buildNavItem(
                    2,
                    Icons.point_of_sale_rounded,
                    'Kasir',
                    controller.currentIndex.value,
                  ),
                  _buildNavItem(
                    3,
                    Icons.bar_chart_rounded,
                    'Laporan',
                    controller.currentIndex.value,
                    disabled: !isAdmin,
                    disabledMsg: 'Hanya Admin/Owner yang dapat melihat Laporan',
                  ),
                  _buildNavItem(
                    4,
                    Icons.settings_rounded,
                    'Pengaturan',
                    controller.currentIndex.value,
                    disabled: !isAdmin,
                    disabledMsg: 'Hanya Admin/Owner yang dapat mengakses Pengaturan',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int currentIndex, {
    bool disabled = false,
    String disabledMsg = 'Akses Ditolak',
  }) {
    final isSelected = index == currentIndex;
    final color = disabled
        ? Colors.grey.shade300
        : (isSelected ? AppTheme.primary : Colors.grey.shade500);

    return InkWell(
      onTap: disabled
          ? () {
              Get.snackbar(
                'Akses Ditolak',
                disabledMsg,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
                margin: EdgeInsets.all(16.w),
                borderRadius: 16.r,
              );
            }
          : () => Get.find<DashboardController>().changePage(index),
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, bool isAdmin, bool isSupervisor, bool isCashier) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Gradient
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24.h,
                left: 24.w,
                right: 24.w,
                bottom: isTablet ? 32.h : 24.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    Color(0xFF1E3A8A),
                  ], // Dark blue gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assalamualaikum Wr.Wb',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Fathiyah Store',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white10,
                      radius: 26.r,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Low Stock Alert (Overlapping header slightly)
                  Obx(() {
                    final productService = Get.find<ProductService>();
                    final lowStockItems = productService.products
                        .where((p) => p.stock <= p.minimumStock)
                        .toList();

                    if (lowStockItems.isEmpty) return const SizedBox.shrink();

                    return Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade200.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade800,
                              size: 24.w,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peringatan Stok',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${lowStockItems.length} produk hampir/sudah habis.',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => controller.changePage(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: const Text('Cek'),
                          ),
                        ],
                      ),
                    );
                  }),

                  Text(
                    'Ringkasan Hari Ini',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Summary Cards Grid
                  Obx(() {
                    final isTablet = MediaQuery.of(context).size.width > 600;
                    return GridView.count(
                      crossAxisCount: isTablet ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.w,
                      childAspectRatio: isTablet ? 1.3 : 1.1,
                      children: [
                        _buildSummaryCard(
                          'Penjualan',
                          CurrencyFormatter.formatRupiah(controller.todaySales),
                          Icons.trending_up_rounded,
                          AppTheme.primary,
                        ),
                        _buildSummaryCard(
                          'Uang Masuk',
                          CurrencyFormatter.formatRupiah(
                            controller.todayCashIn,
                          ),
                          Icons.account_balance_wallet_rounded,
                          AppTheme.accent,
                        ),
                        _buildSummaryCard(
                          'Pengeluaran',
                          CurrencyFormatter.formatRupiah(
                            controller.todayExpenses,
                          ),
                          Icons.trending_down_rounded,
                          Colors.red.shade500,
                        ),
                        _buildSummaryCard(
                          'Piutang',
                          CurrencyFormatter.formatRupiah(controller.todayDebt),
                          Icons.receipt_long_rounded,
                          AppTheme.vipGold,
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: 32.h),

                  // Quick Actions
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24.w,
                    runSpacing: 24.h,
                    children: [
                      // Kategori: Supervisor & Admin
                      if (!isCashier)
                        _buildQuickAction(
                          context,
                          'Kategori',
                          Icons.category_rounded,
                          Colors.orange.shade500,
                          () => Get.toNamed(Routes.CATEGORY),
                        )
                      else
                        _buildQuickAction(context, 'Kategori', Icons.category_rounded, Colors.grey, () => Get.snackbar('Akses Ditolak', 'Kasir tidak dapat mengakses Kategori')),
                      
                      // Pelanggan: All
                      _buildQuickAction(
                        context,
                        'Pelanggan',
                        Icons.people_alt_rounded,
                        AppTheme.secondary,
                        () => Get.to(() => const CustomerListView()),
                      ),

                      // Kasir: All
                      _buildQuickAction(
                        context,
                        'Kasir',
                        Icons.point_of_sale_rounded,
                        AppTheme.accent,
                        () => Get.to(() => const PosView()),
                      ),
                      
                      // Riwayat Transaksi: Supervisor & Admin
                      if (!isCashier)
                        _buildQuickAction(
                          context,
                          'Riwayat',
                          Icons.history_rounded,
                          Colors.blue.shade500,
                          () => Get.to(() => const TransactionListView()),
                        )
                      else
                        _buildQuickAction(context, 'Riwayat', Icons.history_rounded, Colors.grey, () => Get.snackbar('Akses Ditolak', 'Hanya SPV/Admin yang dapat melihat Riwayat')),

                      // Piutang: Supervisor & Admin
                      if (!isCashier)
                        _buildQuickAction(
                          context,
                          'Piutang',
                          Icons.account_balance_wallet_rounded,
                          AppTheme.vipGold,
                          () => Get.to(() => const DebtListView()),
                        )
                      else
                        _buildQuickAction(context, 'Piutang', Icons.account_balance_wallet_rounded, Colors.grey, () => Get.snackbar('Akses Ditolak', 'Hanya SPV/Admin yang dapat mengakses Piutang')),
                      
                      // Laporan: Admin
                      if (isAdmin)
                        _buildQuickAction(
                          context,
                          'Laporan',
                          Icons.insert_chart_rounded,
                          Colors.purple.shade500,
                          () => controller.changePage(3),
                        )
                      else
                        _buildQuickAction(context, 'Laporan', Icons.insert_chart_rounded, Colors.grey, () => Get.snackbar('Akses Ditolak', 'Hanya Admin yang dapat melihat Laporan')),

                      // Pengeluaran: Admin
                      if (isAdmin)
                        _buildQuickAction(
                          context,
                          'Pengeluaran',
                          Icons.money_off_rounded,
                          Colors.red.shade400,
                          () => Get.to(() => const ExpenseListView()),
                        )
                      else
                        _buildQuickAction(context, 'Pengeluaran', Icons.money_off_rounded, Colors.grey, () => Get.snackbar('Akses Ditolak', 'Hanya Admin yang dapat mengakses Pengeluaran')),
                    ],
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                color: Colors.grey.shade300,
                size: 16.sp,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
