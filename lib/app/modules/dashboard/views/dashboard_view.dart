import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar / Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Owner',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Fathiyah Store',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                        radius: 24.w,
                        child: Icon(Icons.person, color: AppTheme.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Today's Summary
                  Text(
                    'Ringkasan Hari Ini',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Low Stock Alert
                  Obx(() {
                    final productService = Get.find<ProductService>();
                    final lowStockItems = productService.products.where((p) => p.stock <= p.minimumStock).toList();
                    
                    if (lowStockItems.isEmpty) return const SizedBox.shrink();
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 28.w),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peringatan Stok Menipis',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                                ),
                                Text(
                                  'Terdapat ${lowStockItems.length} produk yang stoknya hampir atau sudah habis.',
                                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.changePage(1); // Go to products tab
                            },
                            child: const Text('Lihat'),
                          )
                        ],
                      ),
                    );
                  }),
                  
                  // Summary Cards Grid
                  Obx(() => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.w,
                    childAspectRatio: 1.2,
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
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    runSpacing: 16.h,
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  amount,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
