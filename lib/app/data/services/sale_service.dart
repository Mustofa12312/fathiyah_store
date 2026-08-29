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

class SaleService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = Get.find<ProductService>();
  final AuthService _authService = Get.find<AuthService>();
  final ShiftService _shiftService = Get.find<ShiftService>();
  final StockMovementService _stockMovementService = Get.find<StockMovementService>();

  final cartItems = <CartItem>[].obs;
  final sales = <SaleModel>[].obs;

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

  Future<SaleModel> processCheckout({
    required double paidAmount,
    required String paymentMethod,
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

    if (paymentMethod.toLowerCase() == 'cash' && paidAmount > 0) {
      await _shiftService.recordCashSale(paidAmount);
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
}
