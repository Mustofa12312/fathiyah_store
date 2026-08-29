// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../controllers/expense_controller.dart';

class ExpenseFormView extends GetView<ExpenseController> {
  const ExpenseFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Pengeluaran')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keterangan Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(
                hintText: 'Misal: Beli Lakban, Uang Makan Kasir, dll',
              ),
            ),
            SizedBox(height: 24.h),
            
            Text('Nominal (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsFormatter()],
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
              ),
            ),
            
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: const Text('Simpan Pengeluaran', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
