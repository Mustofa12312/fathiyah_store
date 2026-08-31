import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/expense_controller.dart';
import 'expense_form_view.dart';

class ExpenseListView extends GetView<ExpenseController> {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ExpenseController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Hari Ini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const ExpenseFormView()),
          ),
        ],
      ),
      body: GetBuilder<ExpenseController>(
        builder: (controller) {
          final expenses = controller.todayExpenses;
          
          if (expenses.isEmpty) {
            return Center(
              child: Text('Belum ada pengeluaran hari ini.', style: TextStyle(color: AppTheme.textSecondary)),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.outbound, color: Colors.red.shade700),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.description, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            SizedBox(height: 4.h),
                            Text(DateFormat('HH:mm').format(expense.createdAt), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                      Text(
                        '- ${CurrencyFormatter.formatRupiah(expense.amount)}',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ExpenseFormView()),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
