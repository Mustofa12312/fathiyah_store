// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.storefront_rounded,
                  size: 60.sp,
                  color: AppTheme.primary,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Fathiyah',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'STORE',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.accent,
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 48.h),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ],
        ),
      ),
    );
  }
}
