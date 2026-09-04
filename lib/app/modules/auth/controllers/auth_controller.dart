import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Username dan Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    isLoading.value = true;
    
    final user = await _authService.login(
      emailController.text.trim(), 
      passwordController.text,
    );
    
    isLoading.value = false;
    
    if (user != null) {
      Get.offAllNamed(Routes.DASHBOARD);
    }
    // Error snackbar sudah ditampilkan oleh AuthService
  }
}
