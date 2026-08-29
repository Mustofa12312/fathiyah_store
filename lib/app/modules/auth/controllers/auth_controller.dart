import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController(text: 'admin'); // Set default dummy
  final passwordController = TextEditingController(text: '123'); // Set default dummy
  final isLoading = false.obs;
  
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username dan Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    isLoading.value = true;
    
    // Simulate delay
    await Future.delayed(const Duration(seconds: 1));
    
    final user = await _authService.login(emailController.text, passwordController.text);
    
    isLoading.value = false;
    
    if (user != null) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.snackbar(
        'Login Gagal',
        'Username atau Password salah, atau akun nonaktif.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
