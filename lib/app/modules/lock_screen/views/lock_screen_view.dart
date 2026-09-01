import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/lock_screen_controller.dart';

class LockScreenView extends GetView<LockScreenController> {
  const LockScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.lock_person_rounded, size: 40.sp, color: Colors.white),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Kasir Terkunci',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Masuk sebagai ${controller.currentUserName} (${controller.currentUserRole.capitalizeFirst})',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48.h),
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Masukkan PIN',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Obx(() => TextField(
                        controller: controller.pinController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 6,
                        style: TextStyle(fontSize: 24.sp, letterSpacing: 8.w),
                        decoration: InputDecoration(
                          hintText: '••••',
                          counterText: '',
                          errorText: controller.isError.value ? 'PIN Salah' : null,
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(color: AppTheme.primary, width: 2),
                          ),
                        ),
                        onChanged: (val) {
                          controller.isError.value = false;
                          if (val.length >= 4) {
                            // Automatically check PIN when 4 or more digits are entered
                            // Or wait for the user to press submit. Let's add a button.
                          }
                        },
                      )),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: controller.checkPin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Buka Kunci',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Keluar Akun?',
                      middleText: 'Anda akan keluar dari sesi ini dan membutuhkan internet untuk login kembali.',
                      textConfirm: 'Keluar (Logout)',
                      textCancel: 'Batal',
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                      onConfirm: () {
                        Get.back();
                        controller.logout();
                      }
                    );
                  },
                  icon: Icon(Icons.logout_rounded, color: Colors.red.shade400),
                  label: Text(
                    'Keluar Akun Sepenuhnya',
                    style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
