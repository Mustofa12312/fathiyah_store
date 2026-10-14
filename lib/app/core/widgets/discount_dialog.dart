import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../../data/services/sale_service.dart';

class DiscountDialog extends StatefulWidget {
  final SaleService saleService;

  const DiscountDialog({super.key, required this.saleService});

  static Future<void> show(BuildContext context, SaleService saleService) async {
    if (saleService.cartItems.isEmpty) {
      Get.snackbar(
        'Keranjang Kosong',
        'Tambahkan produk ke keranjang terlebih dahulu sebelum memberikan diskon.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    await Get.dialog(
      DiscountDialog(saleService: saleService),
      barrierDismissible: true,
    );
  }

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late String _selectedType; // 'nominal' | 'percentage'
  final _nominalController = TextEditingController();
  final _percentController = TextEditingController();

  final CurrencyTextInputFormatter _currencyFormatter = CurrencyTextInputFormatter.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _selectedType = widget.saleService.discountType.value;
    if (_selectedType == 'percentage') {
      final p = widget.saleService.discountPercent.value;
      if (p > 0) {
        _percentController.text = p.truncateToDouble() == p ? p.toInt().toString() : p.toString();
      }
    } else {
      final a = widget.saleService.discountAmount.value;
      if (a > 0) {
        _nominalController.text = _currencyFormatter.formatDouble(a.toDouble());
      }
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  int get _parsedNominal {
    final clean = _nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  double get _parsedPercent {
    return double.tryParse(_percentController.text.replaceAll(',', '.')) ?? 0.0;
  }

  int get _calculatedDiscount {
    final subtotal = widget.saleService.cartSubtotal;
    if (subtotal <= 0) return 0;

    if (_selectedType == 'percentage') {
      final p = _parsedPercent;
      if (p <= 0) return 0;
      final disc = (subtotal * p / 100).round();
      return disc > subtotal ? subtotal : disc;
    } else {
      final disc = _parsedNominal;
      return disc > subtotal ? subtotal : disc;
    }
  }

  void _applyPresetPercent(double percent) {
    setState(() {
      _selectedType = 'percentage';
      _percentController.text = percent.truncateToDouble() == percent ? percent.toInt().toString() : percent.toString();
    });
  }

  void _applyPresetNominal(int amount) {
    setState(() {
      _selectedType = 'nominal';
      _nominalController.text = _currencyFormatter.formatDouble(amount.toDouble());
    });
  }

  void _applyDiscount() {
    final subtotal = widget.saleService.cartSubtotal;
    if (_selectedType == 'percentage') {
      final p = _parsedPercent;
      if (p < 0 || p > 100) {
        Get.snackbar('Input Tidak Valid', 'Persentase diskon harus di antara 0% dan 100%');
        return;
      }
      widget.saleService.setPercentageDiscount(p);
    } else {
      final nom = _parsedNominal;
      if (nom < 0) {
        Get.snackbar('Input Tidak Valid', 'Nominal diskon tidak boleh negatif');
        return;
      }
      if (nom > subtotal) {
        Get.snackbar('Peringatan', 'Diskon tidak boleh melebihi subtotal belanja (${CurrencyFormatter.formatRupiah(subtotal)})');
        return;
      }
      widget.saleService.setNominalDiscount(nom);
    }

    Get.back();
    Get.snackbar(
      'Diskon Diterapkan',
      'Potongan diskon ${CurrencyFormatter.formatRupiah(widget.saleService.calculatedDiscount)} berhasil diterapkan.',
      backgroundColor: Colors.purple.shade100,
      colorText: Colors.purple.shade900,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _removeDiscount() {
    widget.saleService.removeDiscount();
    Get.back();
    Get.snackbar(
      'Diskon Dihapus',
      'Diskon telah dihapus dari transaksi.',
      backgroundColor: Colors.grey.shade200,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.saleService.cartSubtotal;
    final discount = _calculatedDiscount;
    final totalAfterDiscount = (subtotal - discount) < 0 ? 0 : (subtotal - discount);
    final hasActiveDiscount = widget.saleService.calculatedDiscount > 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.discount_rounded, color: Colors.purple.shade700, size: 24.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diskon Transaksi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Pilih tipe dan tentukan nominal diskon',
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Tab Tipe Diskon
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = 'nominal'),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _selectedType == 'nominal' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _selectedType == 'nominal'
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Nominal (Rp)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: _selectedType == 'nominal' ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedType = 'percentage'),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _selectedType == 'percentage' ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: _selectedType == 'percentage'
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Persentase (%)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: _selectedType == 'percentage' ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Input Field
            if (_selectedType == 'nominal') ...[
              TextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                inputFormatters: [_currencyFormatter],
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nominal Potongan',
                  hintText: 'Rp 0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 12.h),
              // Preset Nominal Chips
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [5000, 10000, 20000, 50000, 100000].map((amt) {
                  return ActionChip(
                    label: Text(CurrencyFormatter.formatRupiah(amt)),
                    labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppTheme.primary),
                    backgroundColor: Colors.purple.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    side: BorderSide(color: Colors.purple.shade100),
                    onPressed: () => _applyPresetNominal(amt),
                  );
                }).toList(),
              ),
            ] else ...[
              TextField(
                controller: _percentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Persentase Diskon (%)',
                  hintText: '0',
                  suffixText: '%',
                  suffixStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.percent_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 12.h),
              // Preset Percent Chips
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [5.0, 10.0, 15.0, 20.0, 50.0].map((pct) {
                  return ActionChip(
                    label: Text('${pct.toInt()}%'),
                    labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.primary),
                    backgroundColor: Colors.purple.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    side: BorderSide(color: Colors.purple.shade100),
                    onPressed: () => _applyPresetPercent(pct),
                  );
                }).toList(),
              ),
            ],

            SizedBox(height: 24.h),

            // Live Calculation Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal Belanja', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.sp)),
                      Text(CurrencyFormatter.formatRupiah(subtotal), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Potongan Diskon', style: TextStyle(color: Colors.purple.shade700, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                      Text(
                        '- ${CurrencyFormatter.formatRupiah(discount)}',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Akhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppTheme.textPrimary)),
                      Text(
                        CurrencyFormatter.formatRupiah(totalAfterDiscount),
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 17.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Actions
            Row(
              children: [
                if (hasActiveDiscount) ...[
                  IconButton(
                    onPressed: _removeDiscount,
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600),
                    tooltip: 'Hapus Diskon',
                  ),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyDiscount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: const Text('Terapkan Diskon', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
