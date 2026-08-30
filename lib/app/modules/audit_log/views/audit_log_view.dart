// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/audit_log_controller.dart';

class AuditLogView extends StatelessWidget {
  const AuditLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuditLogController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.sp),
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Riwayat Aktivitas',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: Obx(() {
                if (controller.logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 64.w, color: Colors.grey.shade300),
                        SizedBox(height: 16.h),
                        Text('Belum ada riwayat aktivitas.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16.sp)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(24.w),
                  itemCount: controller.logs.length,
                  itemBuilder: (context, index) {
                    final log = controller.logs[index];
                    IconData iconData;
                    Color iconColor;

                    switch (log.action) {
                      case 'CREATE':
                        iconData = Icons.add_circle_outline_rounded;
                        iconColor = Colors.green;
                        break;
                      case 'UPDATE':
                        iconData = Icons.edit_rounded;
                        iconColor = Colors.orange;
                        break;
                      case 'DELETE':
                        iconData = Icons.delete_outline_rounded;
                        iconColor = Colors.red;
                        break;
                      default:
                        iconData = Icons.info_outline_rounded;
                        iconColor = Colors.blue;
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(iconData, color: iconColor, size: 24.sp),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.details,
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline_rounded, size: 14.sp, color: AppTheme.textSecondary),
                                      SizedBox(width: 4.w),
                                      Text(
                                        log.userName,
                                        style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        ' • ',
                                        style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        DateFormat('dd MMM yyyy, HH:mm').format(log.createdAt),
                                        style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
