import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';

import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';

class ProductFormView extends StatefulWidget {
  final ProductModel? product; // If null, it's Add Mode. If provided, it's Edit Mode.
  
  const ProductFormView({super.key, this.product});

  @override
  State<ProductFormView> createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final _productService = Get.find<ProductService>();
  
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minimumStockController;
  
  String? _selectedCategoryId;
  String _selectedUnit = 'Pcs';
  
  final List<String> _units = ['Pcs', 'Sachet', 'Dus', 'Pack', 'Sak', 'Liter', 'Pouch', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _purchasePriceController = TextEditingController(text: widget.product?.purchasePrice.toInt().toString() ?? '');
    _sellingPriceController = TextEditingController(text: widget.product?.sellingPrice.toInt().toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _minimumStockController = TextEditingController(text: widget.product?.minimumStock.toString() ?? '');
    
    _selectedCategoryId = widget.product?.categoryId;
    if (widget.product != null && _units.contains(widget.product!.unit)) {
      _selectedUnit = widget.product!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        Get.snackbar('Error', 'Pilih kategori terlebih dahulu!', backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
        return;
      }

      final isEdit = widget.product != null;
      
      final product = ProductModel(
        id: isEdit ? widget.product!.id : const Uuid().v4(),
        name: _nameController.text,
        categoryId: _selectedCategoryId!,
        barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
        unit: _selectedUnit,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        minimumStock: int.tryParse(_minimumStockController.text) ?? 0,
        createdAt: isEdit ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        _productService.updateProduct(product);
        Get.snackbar('Sukses', 'Produk berhasil diperbarui');
      } else {
        _productService.addProduct(product);
        Get.snackbar('Sukses', 'Produk berhasil ditambahkan');
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk Placeholder
              Center(
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(Icons.add_a_photo_outlined, color: AppTheme.textSecondary, size: 32.sp),
                ),
              ),
              SizedBox(height: 32.h),

              // Nama Produk
              _buildLabel('Nama Produk'),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                decoration: const InputDecoration(hintText: 'Contoh: Kopi Kapal Api'),
              ),
              SizedBox(height: 16.h),

              // Barcode
              _buildLabel('Barcode (Opsional)'),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  hintText: 'Scan barcode atau ketik manual',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      // Implement barcode scanner later
                      Get.snackbar('Info', 'Fitur scanner akan hadir di versi rilis');
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Kategori & Satuan (Row)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kategori'),
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          hint: const Text('Pilih'),
                          validator: (v) => v == null ? 'Pilih kategori' : null,
                          items: _productService.categories.map((c) {
                            return DropdownMenuItem(value: c.id, child: Text(c.name));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Satuan'),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          items: _units.map((u) {
                            return DropdownMenuItem(value: u, child: Text(u));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Harga Beli & Harga Jual
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Harga Beli (Modal)'),
                        TextFormField(
                          controller: _purchasePriceController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                          decoration: const InputDecoration(prefixText: 'Rp '),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Harga Jual'),
                        TextFormField(
                          controller: _sellingPriceController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                          decoration: const InputDecoration(prefixText: 'Rp '),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Stok Saat Ini & Batas Minimum
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Stok Saat Ini'),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Batas Minimum Stok'),
                        TextFormField(
                          controller: _minimumStockController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),
              
              // Action Buttons
              Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Show confirmation dialog before delete
                          Get.defaultDialog(
                            title: 'Hapus Produk',
                            middleText: 'Yakin ingin menghapus produk ini?',
                            textConfirm: 'Hapus',
                            textCancel: 'Batal',
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.red,
                            onConfirm: () {
                              _productService.deleteProduct(widget.product!.id);
                              Get.back(); // close dialog
                              Get.back(); // go back to list
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
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
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
