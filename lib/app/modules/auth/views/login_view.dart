// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Top Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  Color(0xFF1E293B), // Dark slate
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    
                    // Hero Logo Section
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 45.sp,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Welcome Typography
                    Text(
                      'Fathiyah Store',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 28.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Aplikasi Kasir & Manajemen Toko',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                    
                    SizedBox(height: 40.h),
                    
                    // Login Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Silakan masuk ke akun Anda',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          
                          // Email Field
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: TextField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Username',
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.secondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          
                          // Password Field
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Obx(() => TextField(
                              controller: controller.passwordController,
                              obscureText: controller.isPasswordHidden.value,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.secondary),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                  borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordHidden.value 
                                      ? Icons.visibility_off_outlined 
                                      : Icons.visibility_outlined, 
                                    color: AppTheme.textSecondary
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                            )),
                          ),
                          
                          SizedBox(height: 12.h),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Bantuan', 
                                  'Silakan hubungi Super Admin untuk mereset password Anda.',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.white,
                                  colorText: AppTheme.textPrimary,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.secondary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 32.h),
                          
                          // Login Button
                          Container(
                            width: double.infinity,
                            height: 56.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.secondary, Color(0xFF2563EB)],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value ? null : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      height: 24.h,
                                      width: 24.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                            )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
