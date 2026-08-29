// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/services/shop_service.dart';

class ShopSettingsController extends GetxController {
  final ShopService _shopService = Get.find<ShopService>();

  final formKey = GlobalKey<FormState>();
  
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController footerController;

  @override
  void onInit() {
    super.onInit();
    final shop = _shopService.shop.value;
    nameController = TextEditingController(text: shop?.name ?? '');
    addressController = TextEditingController(text: shop?.address ?? '');
    phoneController = TextEditingController(text: shop?.phone ?? '');
    footerController = TextEditingController(text: shop?.receiptFooter ?? '');
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    footerController.dispose();
    super.onClose();
  }

  void saveSettings() async {
    if (formKey.currentState!.validate()) {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final updatedShop = ShopModel(
        id: _shopService.shop.value?.id ?? 'main_shop_profile',
        name: nameController.text,
        address: addressController.text,
        phone: phoneController.text,
        receiptFooter: footerController.text,
      );
      
      await _shopService.updateShop(updatedShop);
      
      Get.back(); // close loading
      Get.back(); // go back
      Get.snackbar('Sukses', 'Profil toko berhasil diperbarui');
    }
  }
}
