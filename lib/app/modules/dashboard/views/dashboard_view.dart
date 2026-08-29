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

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: [
          _buildHomeTab(context),
          const ProductListView(),
          const PosView(),
          const ReportView(),
          const Center(child: Text('Pengaturan')),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Produk'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'Transaksi'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Pengaturan'),
          ],
        ),
      )),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
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
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
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
                  
                  // Summary Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.w,
                    childAspectRatio: 1.2,
                    children: [
                      _buildSummaryCard(
                        'Penjualan',
                        'Rp2.500.000',
                        Icons.trending_up_rounded,
                        AppTheme.primary,
                      ),
                      _buildSummaryCard(
                        'Uang Masuk',
                        'Rp2.200.000',
                        Icons.account_balance_wallet_rounded,
                        AppTheme.accent,
                      ),
                      _buildSummaryCard(
                        'Pengeluaran',
                        'Rp500.000',
                        Icons.trending_down_rounded,
                        Colors.red.shade500,
                      ),
                      _buildSummaryCard(
                        'Piutang',
                        'Rp300.000',
                        Icons.receipt_long_rounded,
                        AppTheme.vipGold,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Quick Actions
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                        () {
                          // Change tab index to Laporan (index 3)
                          controller.changeTab(3);
                        },
                      ),
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
              color: color.withOpacity(0.1),
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
                color: color.withOpacity(0.1),
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
