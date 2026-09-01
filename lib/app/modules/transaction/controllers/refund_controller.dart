import 'package:get/get.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/services/sale_service.dart';

class RefundController extends GetxController {
  final SaleModel sale;
  final SaleService _saleService = Get.find<SaleService>();

  // Map of productId to the quantity the user wants to return
  final RxMap<String, int> returnQuantities = <String, int>{}.obs;

  RefundController({required this.sale}) {
    // Initialize return quantities to 0 for all items
    for (var item in sale.items) {
      returnQuantities[item.productId] = 0;
    }
  }

  void incrementReturn(String productId, int maxQuantity) {
    int current = returnQuantities[productId] ?? 0;
    if (current < maxQuantity) {
      returnQuantities[productId] = current + 1;
    }
  }

  void decrementReturn(String productId) {
    int current = returnQuantities[productId] ?? 0;
    if (current > 0) {
      returnQuantities[productId] = current - 1;
    }
  }

  int get totalRefundAmount {
    int total = 0;
    for (var item in sale.items) {
      int qty = returnQuantities[item.productId] ?? 0;
      total += (item.price * qty);
    }
    return total;
  }

  bool get hasItemsToReturn {
    return returnQuantities.values.any((qty) => qty > 0);
  }

  Future<void> processRefund() async {
    if (!hasItemsToReturn) return;

    List<Map<String, dynamic>> returnedItems = [];
    for (var item in sale.items) {
      int qty = returnQuantities[item.productId] ?? 0;
      if (qty > 0) {
        returnedItems.add({
          'productId': item.productId,
          'productName': item.productName,
          'quantity': qty,
          'price': item.price,
        });
      }
    }

    await _saleService.refundItems(sale.id, returnedItems);
    Get.back(); // close RefundView
  }
}
