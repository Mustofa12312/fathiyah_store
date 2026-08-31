import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/sale_service.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/customer_service.dart';
import '../../../data/services/shift_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/customer_model.dart';
import 'package:fathiyah_store/app/modules/pos/views/receipt_view.dart';

class PosController extends GetxController {
  final SaleService saleService = Get.find<SaleService>();
  final ProductService _productService = Get.find<ProductService>();
  final CustomerService _customerService = Get.find<CustomerService>();
  final ShiftService shiftService = Get.find<ShiftService>();

  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  
  // Checkout state
  final paidAmountController = TextEditingController();
  final paymentMethod = 'Cash'.obs;
  
  // Split payment state
  final isSplitPayment = false.obs;
  final splitCashController = TextEditingController();
  final splitTransferController = TextEditingController();
  final splitTransferMethod = 'Transfer BCA'.obs;

  @override
  void onClose() {
    searchController.dispose();
    paidAmountController.dispose();
    splitCashController.dispose();
    splitTransferController.dispose();
    super.onClose();
  }

  void onSearchSubmitted(String value) {
    if (value.trim().isEmpty) return;
    
    // Check if it exactly matches a product's barcode
    final matchedProduct = _productService.products.firstWhereOrNull(
      (p) => p.barcode == value.trim()
    );

    if (matchedProduct != null) {
      // Add to cart directly
      saleService.addToCart(matchedProduct);
      
      // Clear search query & input to prepare for next scan
      searchController.clear();
      searchQuery.value = '';
    }
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

  Future<void> processPayment() async {
    int paidAmount = 0;
    List<Map<String, dynamic>>? splitPayments;

    if (isSplitPayment.value) {
      final cashStr = splitCashController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final transferStr = splitTransferController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final cashAmt = int.tryParse(cashStr) ?? 0;
      final transferAmt = int.tryParse(transferStr) ?? 0;
      
      paidAmount = cashAmt + transferAmt;
      splitPayments = [];
      if (cashAmt > 0) {
        splitPayments.add({'method': 'Cash', 'amount': cashAmt});
      }
      if (transferAmt > 0) {
        splitPayments.add({'method': splitTransferMethod.value, 'amount': transferAmt});
      }
      paymentMethod.value = 'Split';
    } else {
      final paidAmountStr = paidAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      paidAmount = int.tryParse(paidAmountStr) ?? 0;
    }
    
    final total = saleService.cartTotal;
    final isVip = saleService.selectedCustomer.value?.isVip ?? false;

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
    final saleResult = await saleService.processCheckout(
      paidAmount: paidAmount,
      paymentMethod: paymentMethod.value,
      splitPayments: splitPayments,
    );

    Get.back(); // close checkout bottom sheet/view
    Get.to(() => ReceiptView(sale: saleResult)); // show receipt
    
    // reset form
    paidAmountController.clear();
    splitCashController.clear();
    splitTransferController.clear();
    isSplitPayment.value = false;
    paymentMethod.value = 'Cash';
  }
}
