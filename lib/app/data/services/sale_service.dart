import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/sale_model.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import 'product_service.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
  
  double get subtotal => product.sellingPrice * quantity;
}

class SaleService extends GetxService {
  final ProductService _productService = Get.find<ProductService>();

  final cartItems = <CartItem>[].obs;
  final sales = <SaleModel>[].obs;

  CustomerModel? selectedCustomer;

  double get cartTotal {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  void addToCart(ProductModel product) {
    // Check if enough stock
    if (product.stock <= 0) {
      Get.snackbar('Error', 'Stok ${product.name} habis!', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final existingIndex = cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      if (cartItems[existingIndex].quantity < product.stock) {
        cartItems[existingIndex].quantity++;
        cartItems.refresh(); // force UI update
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
    selectedCustomer = customer;
  }

  void clearCart() {
    cartItems.clear();
    selectedCustomer = null;
  }

  SaleModel processCheckout({
    required double paidAmount,
    required String paymentMethod,
  }) {
    final total = cartTotal;
    final remaining = total - paidAmount;
    
    String status = 'belum_dibayar';
    if (remaining <= 0) {
      status = 'lunas';
    } else if (paidAmount > 0) {
      status = 'sebagian';
    }

    // Buat objek transaksi
    final sale = SaleModel(
      id: const Uuid().v4(),
      customerId: selectedCustomer?.id,
      customerType: selectedCustomer?.type ?? 'general',
      cashierId: 'cashier_1', // dummy
      cashierName: 'Kasir Fulan', // dummy
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

    // Simpan transaksi
    sales.add(sale);

    // Kurangi Stok Barang di ProductService
    for (var item in cartItems) {
      final product = item.product;
      _productService.updateProduct(
        product.copyWith(stock: product.stock - item.quantity)
      );
    }

    // Bersihkan keranjang
    clearCart();

    return sale;
  }
}
