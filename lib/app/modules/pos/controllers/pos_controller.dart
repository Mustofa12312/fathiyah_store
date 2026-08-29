import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import 'package:fathiyah_store/app/modules/pos/views/receipt_view.dart';

class PosController extends GetxController {
  final SaleService saleService = Get.find<SaleService>();
  final ProductService _productService = Get.find<ProductService>();
  final CustomerService _customerService = Get.find<CustomerService>();

  final searchQuery = ''.obs;
  
  // Checkout state
  final paidAmountController = TextEditingController();
  final paymentMethod = 'Cash'.obs;

  @override
  void onClose() {
    paidAmountController.dispose();
    super.onClose();
  }

  List<ProductModel> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return _productService.products;
    }
    return _productService.products.where((p) => 
      p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) || 
      (p.barcode != null && p.barcode!.contains(searchQuery.value))
    ).toList();
  }

  List<CustomerModel> get customers => _customerService.customers;

  void selectCustomer(CustomerModel? customer) {
    saleService.setCustomer(customer);
  }

  void processPayment() {
    final paidAmountStr = paidAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final paidAmount = double.tryParse(paidAmountStr) ?? 0.0;
    
    final total = saleService.cartTotal;
    final isVip = saleService.selectedCustomer?.isVip ?? false;

    if (!isVip && paidAmount < total) {
      Get.snackbar(
        'Error Pembayaran', 
        'Pelanggan Umum tidak boleh berhutang. Pembayaran harus Lunas!',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Process checkout
    final saleResult = saleService.processCheckout(
      paidAmount: paidAmount,
      paymentMethod: paymentMethod.value,
    );

    Get.back(); // close checkout bottom sheet/view
    Get.to(() => ReceiptView(sale: saleResult)); // show receipt
    
    // reset form
    paidAmountController.clear();
  }
}
