// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../controllers/settings_controller.dart';
import '../../user_management/views/user_management_view.dart';
import '../../audit_log/views/audit_log_view.dart';
import '../../shop/views/shop_settings_view.dart';
import '../../../data/services/backup_service.dart';
import 'change_password_view.dart';
import 'printer_settings_view.dart';
import '../../shift/views/shift_list_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Pengaturan',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Obx(() {
                      final user = controller.currentUser;
                      if (user == null) return const SizedBox.shrink();

                      return Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: CircleAvatar(
                                radius: 36.r,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person_rounded, size: 40.sp, color: AppTheme.primary),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white)),
                                  SizedBox(height: 4.h),
                                  Text('@${user.username}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14.sp)),
                                  SizedBox(height: 12.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: user.isAdmin ? AppTheme.vipGold.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: user.isAdmin ? AppTheme.vipGold.withValues(alpha: 0.5) : Colors.white30),
                                    ),
                                    child: Text(
                                      user.role.toUpperCase(),
                                      style: TextStyle(
                                        color: user.isAdmin ? AppTheme.vipGold : Colors.white,
                                        fontSize: 10.sp, 
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 32.h),
                    Text('Pengaturan Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary)),
                    SizedBox(height: 16.h),
                    _buildMenuTile(
                      icon: Icons.print_rounded,
                      title: 'Pengaturan Printer',
                      subtitle: 'Hubungkan printer struk kasir Bluetooth',
                      onTap: () => Get.to(() => const PrinterSettingsView()),
                    ),

                    SizedBox(height: 24.h),
                    Text('Manajemen Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary)),
                    SizedBox(height: 16.h),

                    // Only Admin can see User Management
                    Obx(() {
                      if (controller.isAdmin) {
                        return Column(
                          children: [
                            _buildMenuTile(
                              icon: Icons.people_alt_rounded,
                              title: 'Manajemen Karyawan',
                              subtitle: 'Tambah kasir, atur akses pengguna',
                              onTap: () => Get.to(() => const UserManagementView()),
                            ),
                            _buildMenuTile(
                              icon: Icons.history_rounded,
                              title: 'Audit Log',
                              subtitle: 'Pantau riwayat aktivitas kasir & admin',
                              onTap: () => Get.to(() => const AuditLogView()),
                            ),
                            _buildMenuTile(
                              icon: Icons.receipt_long_rounded,
                              title: 'Laporan Shift',
                              subtitle: 'Lihat selisih uang dan riwayat shift',
                              onTap: () => Get.to(() => const ShiftListView()),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    
                    _buildMenuTile(
                      icon: Icons.storefront_rounded,
                      title: 'Profil Toko',
                      subtitle: 'Atur nama toko, alamat, dan logo',
                      onTap: () => Get.to(() => const ShopSettingsView()),
                    ),

                    SizedBox(height: 24.h),
                    Text('Pengaturan Akun & Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary)),
                    SizedBox(height: 16.h),
                    _buildMenuTile(
                      icon: Icons.cloud_download_rounded,
                      title: 'Backup Data (Ekspor)',
                      subtitle: 'Simpan semua data ke CSV',
                      onTap: () async {
                        final backupService = Get.find<BackupService>();
                        await backupService.exportAndShareBackup();
                      },
                    ),
                    _buildMenuTile(
                      icon: Icons.cloud_upload_rounded,
                      title: 'Restore Data (Impor)',
                      subtitle: 'Kembalikan data Produk atau Pelanggan dari CSV',
                      onTap: () async {
                        final backupService = Get.find<BackupService>();
                        await backupService.importData();
                      },
                    ),
                    
                    SizedBox(height: 24.h),
                    Text('Akun & Keamanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.textPrimary)),
                    SizedBox(height: 16.h),
                    
                    Obx(() {
                      final shift = controller.shiftService.currentShift.value;
                      if (!controller.isAdmin && shift != null) {
                        return _buildMenuTile(
                          icon: Icons.lock_clock_rounded,
                          title: 'Tutup Shift',
                          subtitle: 'Akhiri sesi kasir dan hitung uang',
                          iconColor: Colors.orange.shade600,
                          onTap: () => _showCloseShiftDialog(context, controller),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    _buildMenuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ubah Password',
                      subtitle: 'Perbarui kata sandi akun Anda',
                      onTap: () => Get.to(() => const ChangePasswordView()),
                    ),
                    _buildMenuTile(
                      icon: Icons.logout_rounded,
                      title: 'Keluar (Logout)',
                      subtitle: 'Akhiri sesi dan keluar dari aplikasi',
                      iconColor: Colors.red.shade600,
                      onTap: () {
                        Get.defaultDialog(
                          title: 'Keluar',
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                          middleText: 'Yakin ingin keluar dari akun ini?',
                          textConfirm: 'Ya, Keluar',
                          textCancel: 'Batal',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red.shade600,
                          cancelTextColor: AppTheme.textPrimary,
                          onConfirm: controller.logout,
                        );
                      },
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final color = iconColor ?? AppTheme.primary;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                      if (subtitle != null) ...[
                        SizedBox(height: 4.h),
                        Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                      ]
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCloseShiftDialog(BuildContext context, SettingsController controller) {
    final endBalanceController = TextEditingController();
    final shift = controller.shiftService.currentShift.value!;

    Get.dialog(
      AlertDialog(
        title: const Text('Tutup Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modal Awal: Rp ${shift.startBalance}'),
            Text('Pemasukan: Rp ${shift.totalSalesCash}'),
            Text('Pengeluaran: Rp ${shift.totalExpensesCash}'),
            const Divider(),
            Text('Seharusnya: Rp ${shift.expectedBalance}', style: const TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12.h),
            const Text('Masukkan jumlah uang aktual di laci:'),
            SizedBox(height: 8.h),
            TextField(
              controller: endBalanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyTextInputFormatter.currency(
                  locale: 'id_ID',
                  decimalDigits: 0,
                  symbol: 'Rp ',
                )
              ],
              decoration: const InputDecoration(
                labelText: 'Uang Aktual',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountStr = endBalanceController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final amount = int.tryParse(amountStr) ?? 0;
              
              Get.back(); // close dialog
              
              final difference = amount - shift.expectedBalance;
              final diffText = difference == 0 
                  ? 'Pas (Tidak ada selisih)' 
                  : (difference > 0 ? 'Lebih Rp ${difference.abs()}' : 'Kurang Rp ${difference.abs()}');
                  
              Get.defaultDialog(
                title: 'Konfirmasi Tutup',
                middleText: 'Selisih uang: $diffText\n\nYakin ingin menutup shift?',
                textConfirm: 'Tutup Shift',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  Get.back(); // close confirmation
                  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                  
                  await controller.shiftService.closeShift(amount);
                  
                  Get.back(); // close loading
                  Get.snackbar('Shift Ditutup', 'Terima kasih atas kerja keras Anda hari ini!');
                }
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Hitung & Tutup'),
          ),
        ],
      ),
    );
  }
}
