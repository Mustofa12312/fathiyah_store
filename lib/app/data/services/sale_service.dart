import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/stock_movement_model.dart';
import 'product_service.dart';
import 'auth_service.dart';
import 'shift_service.dart';
import 'stock_movement_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';
import '../../core/utils/money_engine.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
  
  int get subtotal => product.sellingPrice * quantity;
}

class HoldOrderModel {
  final String id;
  final String note;
  final DateTime time;
  final CustomerModel? customer;
  final List<CartItem> items;

  HoldOrderModel({
    required this.id,
    required this.note,
    required this.time,
    this.customer,
    required this.items,
  });
}

class SaleService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = Get.find<ProductService>();
  final AuthService _authService = Get.find<AuthService>();
  final ShiftService _shiftService = Get.find<ShiftService>();
  final StockMovementService _stockMovementService = Get.find<StockMovementService>();

  final cartItems = <CartItem>[].obs;
  final sales = <SaleModel>[].obs;
  final holdOrders = <HoldOrderModel>[].obs;

  final Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);

  Future<SaleService> init() async {
    _firestore.collection('sales').orderBy('createdAt', descending: true).limit(100).snapshots().listen((snapshot) {
      sales.value = snapshot.docs.map((doc) => SaleModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => debugPrint('SaleService Error: $e'));
    return this;
  }

  int get cartTotal {
    return cartItems.fold(0, (total, item) => total + item.subtotal);
  }

  void addToCart(ProductModel product) {
    if (product.stock <= 0) {
      Get.snackbar('Error', 'Stok ${product.name} habis!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final existingIndex = cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (cartItems[existingIndex].quantity < product.stock) {
        cartItems[existingIndex].quantity++;
        cartItems.refresh();
      } else {
        Get.snackbar('Peringatan', 'Maksimal stok tercapai', snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      cartItems.add(CartItem(product: product));
    }
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        cartItems.removeAt(index);
      } else if (newQuantity <= cartItems[index].product.stock) {
        cartItems[index].quantity = newQuantity;
        cartItems.refresh();
      } else {
        Get.snackbar('Peringatan', 'Stok tidak mencukupi', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void setCustomer(CustomerModel? customer) {
    selectedCustomer.value = customer;
  }

  void clearCart() {
    cartItems.clear();
    selectedCustomer.value = null;
  }

  void holdOrder(String note) {
    if (cartItems.isEmpty) return;
    
    holdOrders.add(HoldOrderModel(
      id: const Uuid().v4(),
      note: note,
      time: DateTime.now(),
      customer: selectedCustomer.value,
      items: List<CartItem>.from(cartItems),
    ));
    
    clearCart();
    Get.snackbar('Berhasil', 'Keranjang berhasil ditunda', snackPosition: SnackPosition.TOP);
  }

  void restoreOrder(String holdId) {
    final hold = holdOrders.firstWhereOrNull((h) => h.id == holdId);
    if (hold != null) {
      if (cartItems.isNotEmpty) {
        Get.snackbar('Perhatian', 'Keranjang saat ini ditimpa dengan pesanan tertunda', snackPosition: SnackPosition.TOP);
      }
      cartItems.clear();
      cartItems.addAll(hold.items);
      selectedCustomer.value = hold.customer;
      holdOrders.removeWhere((h) => h.id == holdId);
    }
  }

  Future<SaleModel> processCheckout({
    required int paidAmount,
    required String paymentMethod,
    List<Map<String, dynamic>>? splitPayments,
  }) async {
    final total = cartTotal;
    final remaining = total - paidAmount;
    
    String status = 'belum_dibayar';
    if (remaining <= 0) {
      status = 'lunas';
    } else if (paidAmount > 0) {
      status = 'sebagian';
    }

    final saleId = const Uuid().v4();
    final sale = SaleModel(
      id: saleId,
      customerId: selectedCustomer.value?.id,
      customerType: selectedCustomer.value?.type ?? 'general',
      cashierId: _authService.currentUser.value?.id ?? 'unknown',
      cashierName: _authService.currentUser.value?.name ?? 'Unknown',
      subtotal: total,
      totalAmount: total,
      paidAmount: paidAmount,
      remainingAmount: remaining > 0 ? remaining : 0,
      paymentStatus: status,
      paymentMethod: paymentMethod,
      splitPayments: splitPayments,
      transactionStatus: 'active',
      createdAt: DateTime.now(),
      items: cartItems.map((item) => SaleItemModel(
        productId: item.product.id,
        productName: item.product.name,
        quantity: item.quantity,
        price: item.product.sellingPrice,
        subtotal: item.subtotal,
      )).toList(),
    );

    // Calculate actual cash received
    int cashReceived = 0;
    if (splitPayments != null) {
      for (var sp in splitPayments) {
        if (sp['method'].toString().toLowerCase() == 'tunai' || sp['method'].toString().toLowerCase() == 'cash') {
          cashReceived += MoneyEngine.parse(sp['amount']);
        }
      }
    } else if (paymentMethod.toLowerCase() == 'cash' || paymentMethod.toLowerCase() == 'tunai') {
      cashReceived = paidAmount;
    }

    final shiftId = _shiftService.currentShift.value?.id;
    final user = _authService.currentUser.value;

    try {
      final connectivityService = Get.find<ConnectivityService>();
      final isOffline = connectivityService.isOffline.value;

      if (isOffline) {
        // --- OFFLINE FALLBACK STRATEGY ---
        final syncService = Get.find<SyncService>();
        
        final payload = {
          'sale': sale.toJson(),
          'shiftId': shiftId,
          'cashReceived': cashReceived,
          'userId': user?.id,
          'userName': user?.name,
        };
        
        await syncService.saveOfflineSale(payload);
        clearCart();
        return sale;
      }

      // --- ONLINE STRATEGY ---
      await _firestore.runTransaction((transaction) async {
        // READ PHASE
        
        // 1. Read Products
        Map<String, DocumentSnapshot> productDocs = {};
        for(var item in cartItems) {
          DocumentReference prodRef = _firestore.collection('products').doc(item.product.id);
          productDocs[item.product.id] = await transaction.get(prodRef);
        }
        
        // 2. Read Shift if there's cash
        DocumentSnapshot? shiftDoc;
        if (cashReceived > 0 && shiftId != null) {
          shiftDoc = await transaction.get(_firestore.collection('shifts').doc(shiftId));
        }
        
        // VALIDATION PHASE
        for(var item in cartItems) {
          final doc = productDocs[item.product.id];
          if (!doc!.exists) throw Exception('Produk ${item.product.name} tidak ditemukan');
          final currentStock = (doc.data() as Map<String,dynamic>)['stock'] as int;
          if (currentStock < item.quantity) {
            throw Exception('Stok ${item.product.name} tidak mencukupi (Tersisa: $currentStock)');
          }
        }
        
        // WRITE PHASE
        
        // 1. Create Sale
        DocumentReference saleRef = _firestore.collection('sales').doc(saleId);
        transaction.set(saleRef, sale.toJson());
        
        // 2. Update Products & Create Stock Movements
        for (var item in cartItems) {
          final doc = productDocs[item.product.id]!;
          final currentStock = (doc.data() as Map<String,dynamic>)['stock'] as int;
          transaction.update(doc.reference, {'stock': currentStock - item.quantity});
          
          final movementId = const Uuid().v4();
          final movement = StockMovementModel(
            id: movementId,
            productId: item.product.id,
            productName: item.product.name,
            quantity: -item.quantity,
            type: 'SALE',
            userId: user?.id ?? 'unknown',
            userName: user?.name ?? 'Unknown',
            note: 'Penjualan TRX: $saleId',
            createdAt: DateTime.now(),
          );
          transaction.set(_firestore.collection('stock_movements').doc(movementId), movement.toJson());
        }
        
        // 3. Update Shift
        if (shiftDoc != null && shiftDoc.exists) {
          final currentSalesCash = (shiftDoc.data() as Map<String,dynamic>)['totalSalesCash'] as num? ?? 0;
          transaction.update(shiftDoc.reference, {
            'totalSalesCash': currentSalesCash + cashReceived
          });
        }
      });
      
      // Update local shift state if needed
      if (cashReceived > 0 && _shiftService.currentShift.value != null) {
         _shiftService.currentShift.value = _shiftService.currentShift.value!.copyWith(
           totalSalesCash: _shiftService.currentShift.value!.totalSalesCash + cashReceived
         );
      }
      
      clearCart();
      return sale;
    } catch (e) {
      debugPrint("Transaction failed: $e");
      rethrow;
    }
  }
  
  Future<Map<String, int>> getDebtsByCustomer() async {
    final Map<String, int> debts = {};
    try {
      final snapshot = await _firestore.collection('sales')
          .where('paymentStatus', whereIn: ['PARTIAL', 'UNPAID'])
          .get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String? customerId = data['customerId'];
        final int remainingAmount = data['remainingAmount'] ?? 0;
        
        if (remainingAmount > 0 && customerId != null) {
          debts[customerId] = (debts[customerId] ?? 0) + remainingAmount;
        }
      }
    } catch (e) {
      print('Error getting debts: $e');
    }
    return debts;
  }

  Future<List<SaleModel>> getUnpaidSalesForCustomer(String customerId) async {
    try {
      final snapshot = await _firestore.collection('sales')
          .where('customerId', isEqualTo: customerId)
          .where('paymentStatus', whereIn: ['PARTIAL', 'UNPAID'])
          .get();
          
      return snapshot.docs
          .map((doc) => SaleModel.fromJson(doc.data(), doc.id))
          .where((s) => s.remainingAmount > 0)
          .toList();
    } catch (e) {
      print('Error getting unpaid sales: $e');
      return [];
    }
  }

  Future<void> payDebt(String saleId, int amount, String paymentMethod) async {
    final sale = sales.firstWhereOrNull((s) => s.id == saleId);
    if (sale == null || sale.remainingAmount <= 0) return;

    final shiftId = _shiftService.currentShift.value?.id;
    final isCash = paymentMethod.toLowerCase() == 'cash';

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference saleRef = _firestore.collection('sales').doc(saleId);
        DocumentSnapshot saleDoc = await transaction.get(saleRef);
        
        if (!saleDoc.exists) throw Exception('Transaksi tidak ditemukan');
        
        DocumentSnapshot? shiftDoc;
        if (isCash && amount > 0 && shiftId != null) {
          shiftDoc = await transaction.get(_firestore.collection('shifts').doc(shiftId));
        }

        final currentPaidAmount = (saleDoc.data() as Map<String,dynamic>)['paidAmount'] as num? ?? 0;
        final totalAmount = (saleDoc.data() as Map<String,dynamic>)['totalAmount'] as num? ?? 0;
        
        final newPaidAmount = currentPaidAmount + amount;
        final newRemaining = totalAmount - newPaidAmount;
        
        String newStatus = (saleDoc.data() as Map<String,dynamic>)['paymentStatus'] as String;
        if (newRemaining <= 0) {
          newStatus = 'lunas';
        } else {
          newStatus = 'sebagian';
        }

        transaction.update(saleRef, {
          'paidAmount': newPaidAmount,
          'remainingAmount': newRemaining > 0 ? newRemaining : 0,
          'paymentStatus': newStatus,
        });

        if (shiftDoc != null && shiftDoc.exists) {
          final currentSalesCash = (shiftDoc.data() as Map<String,dynamic>)['totalSalesCash'] as num? ?? 0;
          transaction.update(shiftDoc.reference, {
            'totalSalesCash': currentSalesCash + amount
          });
        }
      });
      
      if (isCash && amount > 0 && _shiftService.currentShift.value != null) {
         _shiftService.currentShift.value = _shiftService.currentShift.value!.copyWith(
           totalSalesCash: _shiftService.currentShift.value!.totalSalesCash + amount
         );
      }
    } catch (e) {
      debugPrint("Pay debt transaction failed: $e");
      rethrow;
    }
  }

  Future<void> voidTransaction(String saleId) async {
    final sale = sales.firstWhereOrNull((s) => s.id == saleId);
    if (sale == null || sale.transactionStatus == 'voided') return;

    // Calculate cash to deduct
    int cashToDeduct = 0;
    if (sale.splitPayments != null) {
      for (var sp in sale.splitPayments!) {
        if (sp['method'].toString().toLowerCase() == 'tunai' || sp['method'].toString().toLowerCase() == 'cash') {
          cashToDeduct += MoneyEngine.parse(sp['amount']);
        }
      }
    } else if (sale.paymentMethod.toLowerCase() == 'cash' || sale.paymentMethod.toLowerCase() == 'tunai') {
      cashToDeduct = sale.paidAmount;
    }

    final shiftId = _shiftService.currentShift.value?.id;
    final user = _authService.currentUser.value;

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference saleRef = _firestore.collection('sales').doc(saleId);
        DocumentSnapshot saleDoc = await transaction.get(saleRef);
        
        if (!saleDoc.exists) throw Exception('Transaksi tidak ditemukan');
        if ((saleDoc.data() as Map<String,dynamic>)['transactionStatus'] == 'voided') {
          throw Exception('Transaksi sudah dibatalkan');
        }

        // 1. Read Products
        Map<String, DocumentSnapshot> productDocs = {};
        for(var item in sale.items) {
          DocumentReference prodRef = _firestore.collection('products').doc(item.productId);
          productDocs[item.productId] = await transaction.get(prodRef);
        }
        
        // 2. Read Shift if there's cash
        DocumentSnapshot? shiftDoc;
        if (cashToDeduct > 0 && shiftId != null) {
          shiftDoc = await transaction.get(_firestore.collection('shifts').doc(shiftId));
        }

        // WRITE PHASE
        
        // 1. Void Sale
        transaction.update(saleRef, {
          'transactionStatus': 'voided',
        });
        
        // 2. Restore Products & Create Stock Movements
        for (var item in sale.items) {
          final doc = productDocs[item.productId];
          if (doc != null && doc.exists) {
             final currentStock = (doc.data() as Map<String,dynamic>)['stock'] as int;
             transaction.update(doc.reference, {'stock': currentStock + item.quantity});
          }
          
          final movementId = const Uuid().v4();
          final movement = StockMovementModel(
            id: movementId,
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            type: 'RETURN',
            userId: user?.id ?? 'unknown',
            userName: user?.name ?? 'Unknown',
            note: 'Void TRX: $saleId',
            createdAt: DateTime.now(),
          );
          transaction.set(_firestore.collection('stock_movements').doc(movementId), movement.toJson());
        }
        
        // 3. Update Shift
        if (shiftDoc != null && shiftDoc.exists) {
          final currentSalesCash = (shiftDoc.data() as Map<String,dynamic>)['totalSalesCash'] as num? ?? 0;
          transaction.update(shiftDoc.reference, {
            'totalSalesCash': currentSalesCash - cashToDeduct
          });
        }
      });
      
      if (cashToDeduct > 0 && _shiftService.currentShift.value != null) {
         _shiftService.currentShift.value = _shiftService.currentShift.value!.copyWith(
           totalSalesCash: _shiftService.currentShift.value!.totalSalesCash - cashToDeduct
         );
      }
      
      Get.snackbar('Berhasil', 'Transaksi $saleId berhasil dibatalkan', snackPosition: SnackPosition.TOP);
    } catch (e) {
      debugPrint("Void transaction failed: $e");
      Get.snackbar('Error', 'Gagal membatalkan transaksi: $e', snackPosition: SnackPosition.TOP);
    }
  }
}
