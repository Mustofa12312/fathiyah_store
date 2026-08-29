import 'package:get/get.dart';
import '../../../data/services/audit_log_service.dart';
import '../../../data/models/audit_log_model.dart';

class AuditLogController extends GetxController {
  final AuditLogService _auditLogService = Get.find<AuditLogService>();

  List<AuditLogModel> get logs => _auditLogService.logs;
}
