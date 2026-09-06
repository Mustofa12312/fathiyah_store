import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/unit_model.dart';
import '../../../data/services/unit_service.dart';

class UnitController extends GetxController {
  final UnitService _unitService = Get.find<UnitService>();
  
  RxList<UnitModel> get units => _unitService.units;

  void deleteUnit(String id, String unitName) {
    Get.defaultDialog(
      title: 'Hapus Satuan',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: 'Yakin ingin menghapus satuan $unitName?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      onConfirm: () {
        _unitService.deleteUnit(id, unitName);
        Get.back();
        Get.snackbar('Sukses', 'Satuan berhasil dihapus', snackPosition: SnackPosition.TOP);
      },
    );
  }
}
