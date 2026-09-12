import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class UserManagementView extends GetView<SettingsController> {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Karyawan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddUserDialog(context),
          )
        ],
      ),
      body: GetBuilder<SettingsController>(
        builder: (c) {
          final users = c.allUsers;
          
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isMe = user.id == c.currentUser?.id;

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: user.isAdmin ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.accent.withValues(alpha: 0.1),
                        child: Icon(Icons.person, color: user.isAdmin ? AppTheme.primary : AppTheme.accent),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp), overflow: TextOverflow.ellipsis),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4.r)),
                                    child: Text('Anda', style: TextStyle(color: Colors.green.shade800, fontSize: 10.sp)),
                                  )
                                ]
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text('@${user.username} • ${user.role.toUpperCase()}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                      // Delete button (not for self or admin)
                      if (!isMe && !user.isAdmin)
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22.sp),
                          onPressed: () => _showDeleteConfirmation(context, user),
                        ),
                      Switch(
                        value: user.status == 'aktif',
                        onChanged: isMe || user.isAdmin ? null : (v) => c.toggleUserStatus(user.id),
                        activeThumbColor: AppTheme.primary,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel user) {
    Get.defaultDialog(
      title: 'Hapus Pengguna',
      middleText: 'Yakin ingin menghapus "${user.name}" (@${user.username})?\n\nPengguna yang sudah dihapus tidak bisa login lagi.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteUser(user.id);
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final pinController = TextEditingController();
    
    // We use Rx variables to rebuild the dialog reactively
    final selectedRole = 'cashier'.obs;

    Get.defaultDialog(
      title: 'Tambah Pengguna Baru',
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            SizedBox(height: 8.h),
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
            SizedBox(height: 8.h),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 8.h),
            Obx(() => DropdownButtonFormField<String>(
              initialValue: selectedRole.value,
              decoration: const InputDecoration(labelText: 'Role (Hak Akses)'),
              items: const [
                DropdownMenuItem(value: 'cashier', child: Text('Kasir')),
                DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                DropdownMenuItem(value: 'admin', child: Text('Admin / Owner')),
              ],
              onChanged: (val) {
                if (val != null) selectedRole.value = val;
              },
            )),
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: TextField(
                controller: pinController, 
                decoration: const InputDecoration(labelText: 'PIN Otorisasi / Lock Screen (Min. 4 Angka) *'), 
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.primary,
      onConfirm: () async {
        if (nameController.text.isEmpty || usernameController.text.isEmpty || passwordController.text.isEmpty || pinController.text.isEmpty) {
          Get.snackbar('Error', 'Semua kolom wajib diisi');
          return;
        }

        if (pinController.text.length < 4) {
          Get.snackbar('Error', 'PIN wajib minimal 4 angka');
          return;
        }

        if (passwordController.text.length < 6) {
          Get.snackbar('Error', 'Password wajib minimal 6 karakter');
          return;
        }

        final newUser = UserModel(
          id: const Uuid().v4(), // Will be overridden by FirebaseAuth uid
          name: nameController.text,
          username: usernameController.text,
          role: selectedRole.value,
          pin: pinController.text,
        );

        try {
          // Add user through auth service
          final authService = Get.find<AuthService>();
          await authService.addUser(newUser, passwordController.text);
          
          controller.update(); // refresh list
          Get.back();
          Get.snackbar('Sukses', 'Pengguna baru berhasil ditambahkan.\nUsername: ${usernameController.text}\nPassword: ${passwordController.text}');
        } catch (e) {
          String errorMsg = 'Gagal menambahkan pengguna.';
          if (e.toString().contains('email-already-in-use')) {
            errorMsg = 'Username "${usernameController.text}" sudah terdaftar. Gunakan username lain.';
          } else {
            errorMsg = 'Error: $e';
          }
          Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
  }
}
