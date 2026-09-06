import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/unit_controller.dart';
import 'unit_form_view.dart';

class UnitListView extends GetView<UnitController> {
  const UnitListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Master Data Satuan'),
      ),
      body: Obx(() {
        if (controller.units.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.straighten_rounded, size: 64.w, color: Colors.grey.shade300),
                SizedBox(height: 16.h),
                Text('Belum ada data satuan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16.sp)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.units.length,
          itemBuilder: (context, index) {
            final unit = controller.units[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.straighten_rounded, color: AppTheme.primary),
                ),
                title: Text(unit.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                subtitle: unit.description != null && unit.description!.isNotEmpty 
                  ? Text(unit.description!) 
                  : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                      onPressed: () => Get.to(() => UnitFormView(unit: unit)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.red),
                      onPressed: () => controller.deleteUnit(unit.id, unit.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const UnitFormView()),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
