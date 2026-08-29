import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/services/customer_service.dart';

class CustomerFormView extends StatefulWidget {
  final CustomerModel? customer;
  
  const CustomerFormView({super.key, this.customer});

  @override
  State<CustomerFormView> createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends State<CustomerFormView> {
  final _formKey = GlobalKey<FormState>();
  final _customerService = Get.find<CustomerService>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late bool _isVip;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _addressController = TextEditingController(text: widget.customer?.address ?? '');
    _isVip = widget.customer?.isVip ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.customer != null;
      
      final customer = CustomerModel(
        id: isEdit ? widget.customer!.id : const Uuid().v4(),
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        type: _isVip ? 'vip' : 'general',
        createdAt: isEdit ? widget.customer!.createdAt : DateTime.now(),
      );

      if (isEdit) {
        _customerService.updateCustomer(customer);
        Get.snackbar('Sukses', 'Data pelanggan berhasil diperbarui');
      } else {
        _customerService.addCustomer(customer);
        Get.snackbar('Sukses', 'Pelanggan berhasil ditambahkan');
      }

      Get.back();
    }
  }

  void _handleVipToggle(bool value) {
    // If we are editing, let's show a dialog before toggling VIP
    if (widget.customer != null) {
      final isUpgrading = value;
      Get.defaultDialog(
        title: isUpgrading ? 'Jadikan VIP?' : 'Cabut Status VIP?',
        middleText: isUpgrading 
            ? 'Pelanggan VIP dapat melakukan pembayaran sebagian (piutang).' 
            : 'Mencabut status VIP akan menghilangkan fasilitas piutang untuk transaksi berikutnya.',
        textConfirm: 'Ya, Lanjutkan',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        buttonColor: AppTheme.primary,
        onConfirm: () {
          setState(() {
            _isVip = value;
          });
          Get.back(); // close dialog
        },
      );
    } else {
      // If new customer, just toggle without dialog
      setState(() {
        _isVip = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Nama Pelanggan'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                decoration: const InputDecoration(hintText: 'Contoh: Ahmad'),
              ),
              SizedBox(height: 16.h),

              _buildLabel('Nomor HP'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                decoration: const InputDecoration(hintText: 'Contoh: 0812...'),
              ),
              SizedBox(height: 16.h),

              _buildLabel('Alamat (Opsional)'),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Masukkan alamat pelanggan'),
              ),
              SizedBox(height: 24.h),

              // VIP Toggle
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _isVip ? AppTheme.vipGoldLight : AppTheme.surface,
                  border: Border.all(color: _isVip ? AppTheme.vipGold : AppTheme.divider),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: _isVip ? AppTheme.vipGold : AppTheme.textSecondary,
                      size: 32.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Pelanggan VIP',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isVip ? AppTheme.vipGold : AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Boleh membayar sebagian (piutang)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isVip,
                      onChanged: _handleVipToggle,
                      activeThumbColor: AppTheme.vipGold,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),
              
              Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Hapus Pelanggan',
                            middleText: 'Yakin ingin menghapus pelanggan ini?',
                            textConfirm: 'Hapus',
                            textCancel: 'Batal',
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            onConfirm: () {
                              _customerService.deleteCustomer(widget.customer!.id);
                              Get.back();
                              Get.back();
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Pelanggan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
