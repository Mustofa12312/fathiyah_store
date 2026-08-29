// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
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

import '../../settings/views/settings_view.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/product_service.dart';
import '../../../core/utils/currency_formatter.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = Get.find<AuthService>().isAdmin;

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [
          _buildHomeTab(context, isAdmin),
          const ProductListView(),
          const PosView(),
          if (isAdmin) const ReportView() else const SizedBox.shrink(),
          const SettingsView(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          if (!isAdmin && index == 3) {
            Get.snackbar('Akses Ditolak', 'Hanya admin yang dapat melihat laporan');
            return;
          }
          controller.changePage(index);
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
          const BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
          if (!isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.bar_chart, color: Colors.grey), label: 'Laporan'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      )),
    );
  }

  Widget _buildHomeTab(BuildContext context, bool isAdmin) {
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
                bottom: 40.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF1E3A8A)], // Dark blue gradient
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
                        'Halo, Owner',
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
                      child: Icon(Icons.person, color: Colors.white, size: 28.sp),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content Area
            Transform.translate(
              offset: Offset(0, -24.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Low Stock Alert (Overlapping header slightly)
                    Obx(() {
                      final productService = Get.find<ProductService>();
                      final lowStockItems = productService.products.where((p) => p.stock <= p.minimumStock).toList();
                      
                      if (lowStockItems.isEmpty) return const SizedBox.shrink();
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 24.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade200.withValues(alpha: 0.5),
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
                              child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 24.w),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peringatan Stok',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 14.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${lowStockItems.length} produk hampir/sudah habis.',
                                    style: TextStyle(color: Colors.orange.shade800, fontSize: 12.sp),
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
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              child: const Text('Cek'),
                            )
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
                    Obx(() => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.w,
                      childAspectRatio: 1.1,
                      children: [
                        _buildSummaryCard(
                          'Penjualan',
                          CurrencyFormatter.formatRupiah(controller.todaySales),
                          Icons.trending_up_rounded,
                          AppTheme.primary,
                        ),
                        _buildSummaryCard(
                          'Uang Masuk',
                          CurrencyFormatter.formatRupiah(controller.todayCashIn),
                          Icons.account_balance_wallet_rounded,
                          AppTheme.accent,
                        ),
                        _buildSummaryCard(
                          'Pengeluaran',
                          CurrencyFormatter.formatRupiah(controller.todayExpenses),
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
                    )),
                    
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
                        _buildQuickAction(
                          context,
                          'Kategori',
                          Icons.category_rounded,
                          Colors.orange.shade500,
                          () => Get.toNamed(Routes.CATEGORY),
                        ),
                        _buildQuickAction(
                          context,
                          'Pelanggan',
                          Icons.people_alt_rounded,
                          AppTheme.secondary,
                          () => Get.to(() => const CustomerListView()),
                        ),
                        _buildQuickAction(
                          context,
                          'Kasir',
                          Icons.point_of_sale_rounded,
                          AppTheme.accent,
                          () => Get.to(() => const PosView()),
                        ),
                        if (isAdmin) ...[
                          _buildQuickAction(
                            context,
                            'Piutang',
                            Icons.account_balance_wallet_rounded,
                            AppTheme.vipGold,
                            () => Get.to(() => const DebtListView()),
                          ),
                          _buildQuickAction(
                            context,
                            'Laporan',
                            Icons.insert_chart_rounded,
                            Colors.purple.shade500,
                            () => controller.changePage(3),
                          ),
                        ] else ...[
                          _buildQuickAction(
                            context,
                            'Piutang',
                            Icons.account_balance_wallet_rounded,
                            Colors.grey,
                            () => Get.snackbar('Akses Ditolak', 'Hubungi admin untuk akses Piutang'),
                          ),
                          _buildQuickAction(
                            context,
                            'Laporan',
                            Icons.insert_chart_rounded,
                            Colors.grey,
                            () => Get.snackbar('Akses Ditolak', 'Hubungi admin untuk akses Laporan'),
                          ),
                        ]
                      ],
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

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
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
              Icon(Icons.arrow_outward_rounded, color: Colors.grey.shade300, size: 16.sp),
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
