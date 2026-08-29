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
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
      ),
      body: Obx(() {
        if (controller.logs.isEmpty) {
          return const Center(child: Text('Belum ada riwayat aktivitas.'));
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.logs.length,
          separatorBuilder: (context, index) => Divider(height: 1.h, color: AppTheme.divider),
          itemBuilder: (context, index) {
            final log = controller.logs[index];
            IconData iconData;
            Color iconColor;

            switch (log.action) {
              case 'CREATE':
                iconData = Icons.add_circle;
                iconColor = Colors.green;
                break;
              case 'UPDATE':
                iconData = Icons.edit;
                iconColor = Colors.orange;
                break;
              case 'DELETE':
                iconData = Icons.delete;
                iconColor = Colors.red;
                break;
              default:
                iconData = Icons.info;
                iconColor = Colors.blue;
            }

            return ListTile(
              leading: Icon(iconData, color: iconColor),
              title: Text(log.details, style: TextStyle(fontSize: 14.sp)),
              subtitle: Text(
                'Oleh ${log.userName} • ${DateFormat('dd MMM yyyy, HH:mm').format(log.createdAt)}',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
              ),
            );
          },
        );
      }),
    );
  }
}
