import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/settings_controller.dart';
import '../../user_management/views/user_management_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: SingleChildScrollView(
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
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                      child: Icon(Icons.person, size: 32.sp, color: AppTheme.primary),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                          SizedBox(height: 4.h),
                          Text('@${user.username}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: user.isAdmin ? AppTheme.primary : AppTheme.accent,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
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
            Text('Manajemen Toko', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textSecondary)),
            SizedBox(height: 12.h),

            // Only Admin can see User Management
            Obx(() {
              if (controller.isAdmin) {
                return _buildMenuTile(
                  icon: Icons.people_alt_rounded,
                  title: 'Manajemen Karyawan',
                  subtitle: 'Tambah kasir, atur akses pengguna',
                  onTap: () => Get.to(() => const UserManagementView()),
                );
              }
              return const SizedBox.shrink();
            }),
            
            _buildMenuTile(
              icon: Icons.storefront_rounded,
              title: 'Profil Toko',
              subtitle: 'Atur nama toko, alamat, dan logo',
              onTap: () {
                Get.snackbar('Info', 'Fitur Profil Toko akan tersedia di pembaruan selanjutnya.');
              },
            ),

            SizedBox(height: 24.h),
            Text('Akun & Keamanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textSecondary)),
            SizedBox(height: 12.h),
            
            _buildMenuTile(
              icon: Icons.lock_outline_rounded,
              title: 'Ubah Password',
              onTap: () {
                Get.snackbar('Info', 'Fitur Ubah Password segera hadir.');
              },
            ),
            _buildMenuTile(
              icon: Icons.logout_rounded,
              title: 'Keluar (Logout)',
              iconColor: Colors.red.shade700,
              textColor: Colors.red.shade700,
              onTap: () {
                Get.defaultDialog(
                  title: 'Keluar',
                  middleText: 'Yakin ingin keluar dari akun ini?',
                  textConfirm: 'Ya, Keluar',
                  textCancel: 'Batal',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  onConfirm: controller.logout,
                );
              },
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
    Color? textColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppTheme.divider),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor ?? AppTheme.primary),
        title: Text(title, style: TextStyle(color: textColor ?? AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12.sp)) : null,
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}
