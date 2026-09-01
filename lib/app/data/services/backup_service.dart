import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'audit_log_service.dart';

class BackupService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = Get.find<AuditLogService>();

  final List<String> collectionsToBackup = [
    'users',
    'categories',
    'products',
    'customers',
    'sales',
    'expenses',
    'shifts',
    'stock_movements',
    'audit_logs'
  ];

  Future<void> exportAndShareBackup() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      Map<String, List<Map<String, dynamic>>> backupData = {};

      for (String collection in collectionsToBackup) {
        final querySnapshot = await _firestore.collection(collection).get();
        final docs = querySnapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id; // ensure ID is saved
          return _convertTimestampsToStrings(data);
        }).toList();
        
        backupData[collection] = docs;
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/backup_leiil_store_$dateStr.json');
      await file.writeAsString(jsonEncode(backupData));
      
      Get.back(); // close loading
      
      // Share file
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Backup Database Le\' iil store - $dateStr\n(Format JSON)',
      );
      
      await _auditLogService.logAction(
        action: 'BACKUP',
        entity: 'SYSTEM',
        entityId: 'backup_$dateStr',
        details: 'Melakukan full backup database ke JSON',
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Gagal melakukan backup: $e');
    }
  }

  Map<String, dynamic> _convertTimestampsToStrings(Map<String, dynamic> data) {
    Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = value.toDate().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        result[key] = _convertTimestampsToStrings(value);
      } else if (value is List) {
        result[key] = value.map((e) => (e is Map<String, dynamic>) ? _convertTimestampsToStrings(e) : e).toList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Future<void> importData() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.path != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        File file = File(result.path!);
        final jsonString = await file.readAsString();
        
        Map<String, dynamic> backupData;
        try {
          backupData = jsonDecode(jsonString);
        } catch (e) {
          Get.back();
          Get.snackbar('Error', 'File bukan JSON yang valid.');
          return;
        }

        Get.back(); // close loading

        // Show Preview Dialog
        _showPreviewDialog(backupData);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Gagal membaca file: $e');
    }
  }

  void _showPreviewDialog(Map<String, dynamic> backupData) {
    int totalDocs = 0;
    List<Widget> details = [];

    for (String collection in collectionsToBackup) {
      if (backupData.containsKey(collection)) {
        final list = backupData[collection] as List;
        totalDocs += list.length;
        details.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(collection, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${list.length} data'),
              ],
            ),
          )
        );
      }
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pratinjau Restore', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Anda akan merestore data berikut. Data dengan ID yang sama akan ditimpa (overwrite).'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: details,
                ),
              ),
              const SizedBox(height: 16),
              Text('Total $totalDocs dokumen akan diproses.', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _executeRestore(backupData);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Lanjutkan Restore'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _executeRestore(Map<String, dynamic> backupData) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var batch = _firestore.batch();
      int count = 0;

      for (String collection in collectionsToBackup) {
        if (backupData.containsKey(collection)) {
          final list = backupData[collection] as List;
          for (var item in list) {
            final docData = item as Map<String, dynamic>;
            final docId = docData['id'];
            if (docId != null) {
              final docRef = _firestore.collection(collection).doc(docId);
              batch.set(docRef, docData, SetOptions(merge: true));
              count++;

              // Firestore batch limit is 500
              if (count == 400) {
                await batch.commit();
                batch = _firestore.batch();
                count = 0;
              }
            }
          }
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      Get.back(); // close loading
      Get.snackbar('Berhasil', 'Database berhasil di-restore! Silakan muat ulang aplikasi.');
      
      await _auditLogService.logAction(
        action: 'RESTORE',
        entity: 'SYSTEM',
        entityId: 'restore_${DateTime.now().millisecondsSinceEpoch}',
        details: 'Melakukan restore data dari JSON',
      );

    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Gagal melakukan restore: $e');
    }
  }
}
