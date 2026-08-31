// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'product_service.dart';
import 'customer_service.dart';
import 'sale_service.dart';
import 'audit_log_service.dart';

class BackupService extends GetxService {
  final ProductService _productService = Get.find<ProductService>();
  final CustomerService _customerService = Get.find<CustomerService>();
  final SaleService _saleService = Get.find<SaleService>();
  final AuditLogService _auditLogService = Get.find<AuditLogService>();

  Future<void> exportAndShareBackup() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final directory = await getTemporaryDirectory();
      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      
      final productFile = await _exportProducts(directory.path, dateStr);
      final customerFile = await _exportCustomers(directory.path, dateStr);
      final saleFile = await _exportSales(directory.path, dateStr);
      
      Get.back(); // close loading
      
      // Share files
      await Share.shareXFiles(
        [
          XFile(productFile.path),
          XFile(customerFile.path),
          XFile(saleFile.path),
        ],
        text: 'Backup Database Fathiyah Store - $dateStr',
      );
      
      await _auditLogService.logAction(
        action: 'BACKUP',
        entity: 'SYSTEM',
        entityId: 'backup_$dateStr',
        details: 'Melakukan backup database ke CSV',
      );
      
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Gagal melakukan backup: $e');
    }
  }

  Future<File> _exportProducts(String dirPath, String dateStr) async {
    List<List<dynamic>> rows = [
      ['ID', 'Nama', 'Kategori', 'Barcode', 'Satuan', 'Harga Beli', 'Harga Jual', 'Stok', 'Stok Minimum']
    ];
    
    for (var p in _productService.products) {
      rows.add([
        p.id, p.name, p.categoryId, p.barcode, p.unit, p.purchasePrice, p.sellingPrice, p.stock, p.minimumStock
      ]);
    }
    
    final file = File('$dirPath/backup_products_$dateStr.csv');
    return await file.writeAsString(Csv().encode(rows));
  }

  Future<File> _exportCustomers(String dirPath, String dateStr) async {
    List<List<dynamic>> rows = [
      ['ID', 'Nama', 'Telepon', 'Alamat', 'Tipe', 'Dibuat Pada']
    ];
    
    for (var c in _customerService.customers) {
      rows.add([
        c.id, c.name, c.phone, c.address, c.type, c.createdAt.toIso8601String()
      ]);
    }
    
    final file = File('$dirPath/backup_customers_$dateStr.csv');
    return await file.writeAsString(Csv().encode(rows));
  }

  Future<File> _exportSales(String dirPath, String dateStr) async {
    List<List<dynamic>> rows = [
      ['ID', 'Waktu', 'Kasir', 'Pelanggan ID', 'Total', 'Dibayar', 'Sisa', 'Status']
    ];
    
    for (var s in _saleService.sales) {
      rows.add([
        s.id, s.createdAt.toIso8601String(), s.cashierName, s.customerId ?? '', s.totalAmount, s.paidAmount, s.remainingAmount, s.paymentStatus
      ]);
    }
    
    final file = File('$dirPath/backup_sales_$dateStr.csv');
    return await file.writeAsString(Csv().encode(rows));
  }

  Future<void> importData() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.path != null) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        File file = File(result.path!);
        final csvString = await file.readAsString();
        List<List<dynamic>> rowsAsListOfValues = Csv().decode(csvString);

        if (rowsAsListOfValues.isEmpty) {
          Get.back();
          Get.snackbar('Error', 'File CSV kosong.');
          return;
        }

        final header = rowsAsListOfValues.first.map((e) => e.toString().trim()).toList();
        final isProduct = header.contains('Harga Beli');
        final isCustomer = header.contains('Telepon') && header.contains('Tipe');

        if (isProduct) {
          await _importProducts(rowsAsListOfValues);
        } else if (isCustomer) {
          await _importCustomers(rowsAsListOfValues);
        } else {
          Get.back();
          Get.snackbar('Error', 'Format CSV tidak dikenali. Pastikan Anda memilih file hasil backup dari aplikasi ini.');
          return;
        }

        Get.back(); // close loading
        Get.snackbar('Berhasil', 'Data berhasil diimpor!');
        
        await _auditLogService.logAction(
          action: 'RESTORE',
          entity: 'SYSTEM',
          entityId: 'restore_${DateTime.now().millisecondsSinceEpoch}',
          details: 'Melakukan restore data dari CSV',
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'Gagal mengimpor data: $e');
    }
  }

  Future<void> _importProducts(List<List<dynamic>> rows) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 9) continue;
      
      final id = row[0].toString();
      final name = row[1].toString();
      final categoryId = row[2].toString();
      final barcode = row[3].toString();
      final unit = row[4].toString();
      final purchasePrice = int.tryParse(row[5].toString()) ?? 0;
      final sellingPrice = int.tryParse(row[6].toString()) ?? 0;
      final stock = int.tryParse(row[7].toString()) ?? 0;
      final minimumStock = int.tryParse(row[8].toString()) ?? 0;

      final docRef = FirebaseFirestore.instance.collection('products').doc(id.isNotEmpty ? id : null);
      batch.set(docRef, {
        'name': name,
        'categoryId': categoryId,
        'barcode': barcode.isEmpty ? null : barcode,
        'unit': unit,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'stock': stock,
        'minimumStock': minimumStock,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _importCustomers(List<List<dynamic>> rows) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;
      
      final id = row[0].toString();
      final name = row[1].toString();
      final phone = row[2].toString();
      final address = row[3].toString();
      final type = row[4].toString();
      final createdAtStr = row[5].toString();
      
      final docRef = FirebaseFirestore.instance.collection('customers').doc(id.isNotEmpty ? id : null);
      batch.set(docRef, {
        'name': name,
        'phone': phone,
        'address': address.isEmpty ? null : address,
        'type': type.isEmpty ? 'general' : type,
        'createdAt': createdAtStr.isNotEmpty ? createdAtStr : DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
