// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';

class ChangePasswordView extends GetView<SettingsController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final isObscure = true.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Untuk keamanan akun Anda, silakan masukkan password lama Anda sebelum mengganti dengan yang baru.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),

            _buildLabel('Password Lama'),
            Obx(() => TextField(
              controller: oldPassController,
              obscureText: isObscure.value,
              decoration: _buildInputDecoration(isObscure, 'Masukkan password lama'),
            )),
            SizedBox(height: 24.h),

            _buildLabel('Password Baru'),
            Obx(() => TextField(
              controller: newPassController,
              obscureText: isObscure.value,
              decoration: _buildInputDecoration(isObscure, 'Masukkan password baru'),
            )),
            SizedBox(height: 24.h),

            _buildLabel('Konfirmasi Password Baru'),
            Obx(() => TextField(
              controller: confirmPassController,
              obscureText: isObscure.value,
              decoration: _buildInputDecoration(isObscure, 'Ulangi password baru'),
            )),
            SizedBox(height: 48.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  if (newPassController.text != confirmPassController.text) {
                    Get.snackbar('Error', 'Konfirmasi password baru tidak cocok', snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
                    Get.snackbar('Error', 'Semua kolom harus diisi', snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  controller.changePassword(oldPassController.text, newPassController.text);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Simpan Password Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
    );
  }

  InputDecoration _buildInputDecoration(RxBool isObscure, String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textSecondary,
        ),
        onPressed: () => isObscure.value = !isObscure.value,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }
}
