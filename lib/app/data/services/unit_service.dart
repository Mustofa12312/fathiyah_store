import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit_model.dart';
import 'audit_log_service.dart';

class UnitService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = Get.find<AuditLogService>();
  
  final units = <UnitModel>[].obs;

  Future<UnitService> init() async {
    _firestore.collection('units').snapshots().listen((snapshot) {
      units.value = snapshot.docs.map((doc) => UnitModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => debugPrint('UnitService Error: $e'));
    return this;
  }

  Future<void> addUnit(UnitModel unit) async {
    await _firestore.collection('units').doc(unit.id).set(unit.toJson());
    
    await _auditLogService.logAction(
      action: 'CREATE',
      entity: 'UNIT',
      entityId: unit.id,
      details: 'Menambahkan satuan baru: ${unit.name}',
    );
  }

  Future<void> updateUnit(UnitModel unit) async {
    await _firestore.collection('units').doc(unit.id).update(unit.toJson());
    
    await _auditLogService.logAction(
      action: 'UPDATE',
      entity: 'UNIT',
      entityId: unit.id,
      details: 'Mengupdate data satuan: ${unit.name}',
    );
  }

  Future<void> deleteUnit(String id, String unitName) async {
    await _firestore.collection('units').doc(id).delete();
    
    await _auditLogService.logAction(
      action: 'DELETE',
      entity: 'UNIT',
      entityId: id,
      details: 'Menghapus satuan: $unitName',
    );
  }
}
