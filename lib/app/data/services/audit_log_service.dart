import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/audit_log_model.dart';
import 'auth_service.dart';

class AuditLogService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final logs = <AuditLogModel>[].obs;

  Future<AuditLogService> init() async {
    _firestore.collection('audit_logs').orderBy('createdAt', descending: true).limit(100).snapshots().listen((snapshot) {
      logs.value = snapshot.docs.map((doc) => AuditLogModel.fromJson(doc.data(), doc.id)).toList();
    });
    return this;
  }

  Future<void> logAction({
    required String action,
    required String entity,
    required String entityId,
    required String details,
  }) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    final log = AuditLogModel(
      id: const Uuid().v4(),
      userId: user.id,
      userName: user.name,
      action: action,
      entity: entity,
      entityId: entityId,
      details: details,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('audit_logs').doc(log.id).set(log.toJson());
  }
}
