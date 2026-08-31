import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/shop_settings_controller.dart';

class ShopSettingsView extends StatelessWidget {
  const ShopSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopSettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Toko'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Toko', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Nama Toko *'),
                validator: (v) => v == null || v.isEmpty ? 'Nama toko tidak boleh kosong' : null,
              ),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              ),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: controller.addressController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Alamat Toko', alignLabelWithHint: true),
              ),
              
              SizedBox(height: 32.h),
              Text('Pengaturan Struk', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              
              TextFormField(
                controller: controller.footerController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Pesan Penutup di Struk', hintText: 'Contoh: Terima kasih atas kunjungan Anda!', alignLabelWithHint: true),
              ),
              
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Simpan Profil Toko'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
