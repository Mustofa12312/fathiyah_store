import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../../data/services/auth_service.dart';

class SupervisorAuthDialog extends StatefulWidget {
  final String actionDescription;
  final VoidCallback onSuccess;

  const SupervisorAuthDialog({
    super.key,
    required this.actionDescription,
    required this.onSuccess,
  });

  static Future<void> show({
    required String actionDescription,
    required VoidCallback onSuccess,
  }) async {
    final authService = Get.find<AuthService>();
    // If already supervisor or admin, proceed directly without PIN
    if (authService.isSupervisor) {
      onSuccess();
      return;
    }

    await Get.dialog(
      SupervisorAuthDialog(
        actionDescription: actionDescription,
        onSuccess: onSuccess,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<SupervisorAuthDialog> createState() => _SupervisorAuthDialogState();
}

class _SupervisorAuthDialogState extends State<SupervisorAuthDialog> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyPin() async {
    final pin = _pinController.text;
    if (pin.length != 6) {
      setState(() => _errorMessage = 'PIN harus 6 angka');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Get.find<AuthService>();
    final isValid = await authService.verifySupervisorPin(pin);

    if (mounted) {
      setState(() => _isLoading = false);
      if (isValid) {
        Get.back(); // close dialog
        widget.onSuccess();
      } else {
        setState(() => _errorMessage = 'PIN salah atau tidak memiliki akses');
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_person_rounded, color: Colors.red.shade400, size: 32.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Otorisasi Supervisor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.actionDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.sp, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '******',
                errorText: _errorMessage,
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onChanged: (val) {
                if (val.length == 6) {
                  _verifyPin();
                }
              },
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _isLoading 
                        ? SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Verifikasi'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
