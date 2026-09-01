import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LockScreenController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final pinController = TextEditingController();
  final isError = false.obs;

  String get currentUserName => _authService.currentUser.value?.name ?? 'Pengguna';
  String get currentUserRole => _authService.currentUser.value?.role ?? '';

  void checkPin() {
    String expectedPin = _authService.currentUser.value?.pin ?? '123456';
    if (expectedPin.isEmpty) expectedPin = '123456';

    if (pinController.text == expectedPin) {
      isError.value = false;
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      isError.value = true;
      pinController.clear();
      Get.snackbar(
        'Akses Ditolak',
        'PIN salah, silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    }
  }

  void logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.AUTH);
  }

  @override
  void onClose() {
    pinController.dispose();
    super.onClose();
  }
}
