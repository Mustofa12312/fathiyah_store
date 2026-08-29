// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:get/get.dart';
import '../../../data/services/audit_log_service.dart';
import '../../../data/models/audit_log_model.dart';

class AuditLogController extends GetxController {
  final AuditLogService _auditLogService = Get.find<AuditLogService>();

  List<AuditLogModel> get logs => _auditLogService.logs;
}
