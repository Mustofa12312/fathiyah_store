// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

import 'package:intl/intl.dart';

import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/stock_movement_service.dart';

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
    final formatNumber = (num? value) {
      if (value == null) return '';
      return NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(value).trim();
    };

    _purchasePriceController = TextEditingController(text: formatNumber(widget.product?.purchasePrice));
    _sellingPriceController = TextEditingController(text: formatNumber(widget.product?.sellingPrice));
    _stockController = TextEditingController(text: formatNumber(widget.product?.stock));
    _minimumStockController = TextEditingController(text: formatNumber(widget.product?.minimumStock));
    
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
        Get.snackbar('Error', 'Pilih kategori terlebih dahulu!', backgroundColor: Colors.red.withValues(alpha: 0.1), colorText: Colors.red);
        return;
      }

      final isEdit = widget.product != null;
      
      final product = ProductModel(
        id: isEdit ? widget.product!.id : const Uuid().v4(),
        name: _nameController.text,
        categoryId: _selectedCategoryId!,
        barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
        unit: _selectedUnit,
        purchasePrice: int.tryParse(_purchasePriceController.text.replaceAll('.', '')) ?? 0,
        sellingPrice: int.tryParse(_sellingPriceController.text.replaceAll('.', '')) ?? 0,
        stock: int.tryParse(_stockController.text.replaceAll('.', '')) ?? 0,
        minimumStock: int.tryParse(_minimumStockController.text) ?? 0,
        createdAt: isEdit ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        _productService.updateProduct(product);
      } else {
        _productService.addProduct(product);
      }

      Get.back();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Sukses', 
          isEdit ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan',
          snackPosition: SnackPosition.TOP,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 24.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.sp),
                        onPressed: () => Get.back(),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isEdit ? 'Edit Produk' : 'Tambah Produk',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isEdit)
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.history_rounded, color: AppTheme.primary),
                        tooltip: 'Riwayat Stok',
                        onPressed: () => _showStockHistory(context),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Produk
                      _buildLabel('Nama Produk'),
                      TextFormField(
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        decoration: _inputDecoration(hintText: 'Contoh: Kopi Kapal Api'),
                      ),
                      SizedBox(height: 20.h),

                      // Barcode
                      _buildLabel('Barcode (Opsional)'),
                      TextFormField(
                        controller: _barcodeController,
                        decoration: _inputDecoration(
                          hintText: 'Scan barcode atau ketik manual',
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary),
                            onPressed: () async {
                              var res = await Get.to(() => const SimpleBarcodeScannerPage());
                              if (res is String && res != '-1') {
                                _barcodeController.text = res;
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Kategori & Satuan (Row)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                                  decoration: _inputDecoration(),
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
                                  isExpanded: true,
                                  value: _selectedUnit,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                                  decoration: _inputDecoration(),
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
                      SizedBox(height: 20.h),

                      // Harga Beli & Harga Jual
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Harga Beli (Modal)'),
                                TextFormField(
                                  controller: _purchasePriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'id_ID', decimalDigits: 0, symbol: 'Rp ')],
                                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                                  decoration: _inputDecoration(),
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
                                  inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'id_ID', decimalDigits: 0, symbol: 'Rp ')],
                                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                                  decoration: _inputDecoration(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Stok Saat Ini & Batas Minimum
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Stok Saat Ini'),
                                TextFormField(
                                  controller: _stockController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'id_ID', decimalDigits: 0, symbol: '')],
                                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                                  decoration: _inputDecoration(hintText: '0'),
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
                                  inputFormatters: [CurrencyTextInputFormatter.currency(locale: 'id_ID', decimalDigits: 0, symbol: '')],
                                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                                  decoration: _inputDecoration(hintText: '0'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40.h),
                      
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
                                    titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                                    middleText: 'Yakin ingin menghapus produk ini?',
                                    textConfirm: 'Hapus',
                                    textCancel: 'Batal',
                                    confirmTextColor: Colors.white,
                                    buttonColor: Colors.red.shade600,
                                    cancelTextColor: AppTheme.textPrimary,
                                    onConfirm: () {
                                      _productService.deleteProduct(widget.product!.id);
                                      Get.back(); // close dialog
                                      Get.back(); // go back to list
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  side: BorderSide(color: Colors.red.shade200, width: 2),
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                ),
                                child: Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              ),
                            ),
                            SizedBox(width: 16.w),
                          ],
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _saveProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                elevation: 4,
                                shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                              ),
                              child: Text(
                                isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
      prefixText: prefixText,
      prefixStyle: TextStyle(color: AppTheme.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }

  void _showStockHistory(BuildContext context) {
    if (widget.product == null) return;
    
    final stockService = Get.find<StockMovementService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Riwayat Stok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.textPrimary)),
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: StreamBuilder(
                  stream: stockService.getMovementsForProduct(widget.product!.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded, size: 64.w, color: Colors.grey.shade300),
                            SizedBox(height: 16.h),
                            Text('Belum ada riwayat pergerakan stok.', style: TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ),
                      );
                    }

                    final movements = snapshot.data!;
                    return ListView.builder(
                      itemCount: movements.length,
                      itemBuilder: (context, index) {
                        final m = movements[index];
                        final isAdd = m.quantity > 0;
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: isAdd ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(
                                  isAdd ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                  color: isAdd ? Colors.green : Colors.red,
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.type,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textPrimary),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline_rounded, size: 12.sp, color: AppTheme.textSecondary),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            '${m.userName} • ${DateFormat('dd MMM, HH:mm').format(m.createdAt)}',
                                            style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (m.note.isNotEmpty) ...[
                                      SizedBox(height: 4.h),
                                      Text(m.note, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                                    ]
                                  ],
                                ),
                              ),
                              Text(
                                '${isAdd ? '+' : ''}${m.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  color: isAdd ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
