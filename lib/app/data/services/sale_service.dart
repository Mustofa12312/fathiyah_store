// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import 'product_service.dart';
import 'auth_service.dart';
import 'shift_service.dart';
import 'stock_movement_service.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
  
  double get subtotal => product.sellingPrice * quantity;
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
    _firestore.collection('sales').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      sales.value = snapshot.docs.map((doc) => SaleModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => debugPrint('SaleService Error: $e'));
    return this;
  }

  double get cartTotal {
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
    required double paidAmount,
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

    // Save to Firestore
    await _firestore.collection('sales').doc(saleId).set(sale.toJson());

    // Update Product Stock in Firestore
    for (var item in cartItems) {
      final product = item.product;
      await _productService.updateProduct(
        product.copyWith(stock: product.stock - item.quantity)
      );
      
      await _stockMovementService.recordMovement(
        productId: product.id,
        productName: product.name,
        quantity: -item.quantity,
        type: 'SALE',
        note: 'Penjualan TRX: $saleId',
      );
    }

    // Calculate actual cash received
    double cashReceived = 0;
    if (splitPayments != null) {
      for (var sp in splitPayments) {
        if (sp['method'].toString().toLowerCase() == 'tunai' || sp['method'].toString().toLowerCase() == 'cash') {
          cashReceived += (sp['amount'] as num).toDouble();
        }
      }
    } else if (paymentMethod.toLowerCase() == 'cash' || paymentMethod.toLowerCase() == 'tunai') {
      cashReceived = paidAmount;
    }

    if (cashReceived > 0) {
      await _shiftService.recordCashSale(cashReceived);
    }

    clearCart();
    return sale;
  }
  
  Map<String, double> getDebtsByCustomer() {
    final Map<String, double> debts = {};
    for (var sale in sales) {
      if (sale.remainingAmount > 0 && sale.customerId != null) {
        debts[sale.customerId!] = (debts[sale.customerId!] ?? 0) + sale.remainingAmount;
      }
    }
    return debts;
  }

  List<SaleModel> getUnpaidSalesForCustomer(String customerId) {
    return sales.where((s) => s.customerId == customerId && s.remainingAmount > 0).toList();
  }

  Future<void> payDebt(String saleId, double amount, String paymentMethod) async {
    final sale = sales.firstWhereOrNull((s) => s.id == saleId);
    if (sale == null || sale.remainingAmount <= 0) return;

    final newPaidAmount = sale.paidAmount + amount;
    final newRemaining = sale.totalAmount - newPaidAmount;
    
    String newStatus = sale.paymentStatus;
    if (newRemaining <= 0) {
      newStatus = 'lunas';
    } else {
      newStatus = 'sebagian';
    }

    await _firestore.collection('sales').doc(saleId).update({
      'paidAmount': newPaidAmount,
      'remainingAmount': newRemaining > 0 ? newRemaining : 0,
      'paymentStatus': newStatus,
    });
    
    if (paymentMethod.toLowerCase() == 'cash' && amount > 0) {
      await _shiftService.recordCashSale(amount);
    }
  }

  Future<void> voidTransaction(String saleId) async {
    final sale = sales.firstWhereOrNull((s) => s.id == saleId);
    if (sale == null || sale.transactionStatus == 'voided') return;

    // Restore stock
    for (var item in sale.items) {
      final product = _productService.products.firstWhereOrNull((p) => p.id == item.productId);
      if (product != null) {
        await _productService.updateProduct(
          product.copyWith(stock: product.stock + item.quantity)
        );
      }
      await _stockMovementService.recordMovement(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        type: 'RETURN',
        note: 'Void TRX: $saleId',
      );
    }

    // Deduct from shift cash if paid by cash
    double cashToDeduct = 0;
    if (sale.splitPayments != null) {
      for (var sp in sale.splitPayments!) {
        if (sp['method'].toString().toLowerCase() == 'tunai' || sp['method'].toString().toLowerCase() == 'cash') {
          cashToDeduct += (sp['amount'] as num).toDouble();
        }
      }
    } else if (sale.paymentMethod.toLowerCase() == 'cash' || sale.paymentMethod.toLowerCase() == 'tunai') {
      cashToDeduct = sale.paidAmount;
    }

    if (cashToDeduct > 0) {
      await _shiftService.recordCashSale(-cashToDeduct);
    }

    // Update sale status
    await _firestore.collection('sales').doc(saleId).update({
      'transactionStatus': 'voided',
    });
    
    Get.snackbar('Berhasil', 'Transaksi $saleId berhasil dibatalkan', snackPosition: SnackPosition.TOP);
  }
}
