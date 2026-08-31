import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'connectivity_service.dart';

class SyncService extends GetxService {
  late Box<String> offlineSalesBox;
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable counter for pending transactions
  final RxInt pendingSyncCount = 0.obs;

  Future<SyncService> init() async {
    offlineSalesBox = Hive.box('offline_sales');
    pendingSyncCount.value = offlineSalesBox.length;

    // Listen to network changes
    ever(_connectivityService.isOffline, (bool isOffline) {
      if (!isOffline) {
        _syncOfflineData();
      }
    });

    // Try sync immediately if online
    if (!_connectivityService.isOffline.value) {
      _syncOfflineData();
    }

    return this;
  }

  Future<void> saveOfflineSale(Map<String, dynamic> salePayload) async {
    final String key = const Uuid().v4();
    await offlineSalesBox.put(key, jsonEncode(salePayload));
    pendingSyncCount.value = offlineSalesBox.length;
    
    if (kDebugMode) {
      print('Offline sale saved. Total pending: ${pendingSyncCount.value}');
    }
  }

  Future<void> _syncOfflineData() async {
    if (offlineSalesBox.isEmpty) return;

    if (kDebugMode) print('Starting offline sync. Items to sync: ${offlineSalesBox.length}');

    final keys = offlineSalesBox.keys.toList();

    for (var key in keys) {
      final jsonStr = offlineSalesBox.get(key);
      if (jsonStr == null) continue;

      try {
        final Map<String, dynamic> payload = jsonDecode(jsonStr);
        final Map<String, dynamic> saleData = payload['sale'];
        final String? shiftId = payload['shiftId'];
        final int cashReceived = payload['cashReceived'] ?? 0;
        final String userId = payload['userId'] ?? 'unknown';
        final String userName = payload['userName'] ?? 'Unknown';

        await _firestore.runTransaction((transaction) async {
          // 1. Read Products
          List<dynamic> items = saleData['items'];
          Map<String, DocumentSnapshot> productDocs = {};
          
          for(var item in items) {
            String productId = item['productId'];
            DocumentReference prodRef = _firestore.collection('products').doc(productId);
            productDocs[productId] = await transaction.get(prodRef);
          }
          
          // 2. Read Shift
          DocumentSnapshot? shiftDoc;
          if (cashReceived > 0 && shiftId != null) {
            shiftDoc = await transaction.get(_firestore.collection('shifts').doc(shiftId));
          }
          
          // 3. Write Sale
          String saleId = saleData['id'];
          DocumentReference saleRef = _firestore.collection('sales').doc(saleId);
          transaction.set(saleRef, saleData);
          
          // 4. Update Products & Movements
          for (var item in items) {
            String productId = item['productId'];
            int qty = item['quantity'];
            String productName = item['productName'];
            
            final doc = productDocs[productId]!;
            if (doc.exists) {
              final currentStock = (doc.data() as Map<String,dynamic>)['stock'] as int;
              transaction.update(doc.reference, {'stock': currentStock - qty});
              
              final movementId = const Uuid().v4();
              final movement = {
                'id': movementId,
                'productId': productId,
                'productName': productName,
                'quantity': -qty,
                'type': 'SALE',
                'userId': userId,
                'userName': userName,
                'note': 'Penjualan TRX (Sync): $saleId',
                'createdAt': (saleData['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
              };
              // Convert datetime back to Timestamp for firestore
              movement['createdAt'] = Timestamp.fromDate(DateTime.parse(movement['createdAt'].toString()));
              
              transaction.set(_firestore.collection('stock_movements').doc(movementId), movement);
            }
          }
          
          // 5. Update Shift Cash
          if (shiftDoc != null && shiftDoc.exists) {
            final currentSalesCash = (shiftDoc.data() as Map<String,dynamic>)['totalSalesCash'] as num? ?? 0;
            transaction.update(shiftDoc.reference, {
              'totalSalesCash': currentSalesCash + cashReceived
            });
          }
        });

        // Sync successful, remove from queue
        await offlineSalesBox.delete(key);
        pendingSyncCount.value = offlineSalesBox.length;
        if (kDebugMode) print('Successfully synced sale $key');

      } catch (e) {
        if (kDebugMode) print('Failed to sync sale $key: $e');
        // Will retry later
      }
    }
  }
}
