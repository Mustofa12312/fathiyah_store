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
      appBar: AppBar(
        title: const Text('Buku Piutang VIP'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = controller.customersWithDebt;
        final debts = controller.customerDebts;
        
        if (customers.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.check_circle_outline,
            title: 'Tidak Ada Piutang',
            subtitle: 'Hebat! Semua tagihan pelanggan saat ini telah lunas.',
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final c = customers[index];
            final totalDebt = debts[c.id] ?? 0;

            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  Get.to(() => DebtDetailView(customer: c));
                },
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.vipGoldLight,
                        radius: 24.r,
                        child: Icon(Icons.star_rounded, color: AppTheme.vipGold),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            SizedBox(height: 4.h),
                            Text(c.phone, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Sisa Piutang', style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            CurrencyFormatter.formatRupiah(totalDebt),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
