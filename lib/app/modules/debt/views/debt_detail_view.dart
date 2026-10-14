import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import '../controllers/debt_controller.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/sale_model.dart';
import '../../../core/widgets/empty_state_widget.dart';

class DebtDetailView extends StatefulWidget {
  final CustomerModel customer;

  const DebtDetailView({super.key, required this.customer});

  @override
  State<DebtDetailView> createState() => _DebtDetailViewState();
}

class _DebtDetailViewState extends State<DebtDetailView> {
  final DebtController controller = Get.find<DebtController>();
  String _selectedFilter = 'semua'; // 'semua', 'belum_lunas', 'lunas'
  late Future<List<SaleModel>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    setState(() {
      _salesFuture = controller.getAllSalesFor(widget.customer.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Rincian Piutang: ${widget.customer.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan Data',
            onPressed: () {
              _loadSales();
              controller.fetchDebts();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SaleModel>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allSales = snapshot.data ?? [];
          final unpaidSales = allSales.where((s) => s.remainingAmount > 0 && s.transactionStatus != 'voided').toList();
          final paidSales = allSales.where((s) => s.remainingAmount <= 0 && s.transactionStatus != 'voided').toList();

          final int totalDebt = unpaidSales.fold(0, (sum, s) => sum + s.remainingAmount);
          final int totalSpent = allSales.where((s) => s.transactionStatus != 'voided').fold(0, (sum, s) => sum + s.totalAmount);

          List<SaleModel> displayedSales;
          if (_selectedFilter == 'belum_lunas') {
            displayedSales = unpaidSales;
          } else if (_selectedFilter == 'lunas') {
            displayedSales = paidSales;
          } else {
            displayedSales = allSales.where((s) => s.transactionStatus != 'voided').toList();
          }

          return Column(
            children: [
              // Customer Summary Card
              Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: totalDebt > 0 ? Colors.orange.shade200 : Colors.green.shade200,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: totalDebt > 0 ? AppTheme.vipGoldLight : Colors.green.shade50,
                          radius: 24.r,
                          child: Icon(
                            totalDebt > 0 ? Icons.person_rounded : Icons.verified_user_rounded,
                            color: totalDebt > 0 ? AppTheme.vipGold : Colors.green.shade700,
                            size: 26.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.customer.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                widget.customer.phone.isNotEmpty && widget.customer.phone != '-'
                                    ? widget.customer.phone
                                    : 'Pelanggan Toko',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: totalDebt > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: totalDebt > 0 ? Colors.orange.shade300 : Colors.green.shade300),
                          ),
                          child: Text(
                            totalDebt > 0 ? 'ADA PIUTANG' : 'SEMUA LUNAS',
                            style: TextStyle(
                              color: totalDebt > 0 ? Colors.orange.shade900 : Colors.green.shade800,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    const Divider(height: 1, thickness: 0.6),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sisa Piutang Aktif', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.sp)),
                            SizedBox(height: 2.h),
                            Text(
                              CurrencyFormatter.formatRupiah(totalDebt),
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: totalDebt > 0 ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total Akumulasi Belanja', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.sp)),
                            SizedBox(height: 2.h),
                            Text(
                              CurrencyFormatter.formatRupiah(totalSpent),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    _buildFilterTab('semua', 'Semua (${allSales.length})'),
                    SizedBox(width: 8.w),
                    _buildFilterTab('belum_lunas', 'Belum Lunas (${unpaidSales.length})', color: Colors.orange.shade800),
                    SizedBox(width: 8.w),
                    _buildFilterTab('lunas', 'Lunas (${paidSales.length})', color: Colors.green.shade700),
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              // List Transaksi
              Expanded(
                child: displayedSales.isEmpty
                    ? EmptyStateWidget(
                        icon: _selectedFilter == 'belum_lunas'
                            ? Icons.check_circle_outline_rounded
                            : Icons.receipt_long_rounded,
                        title: _selectedFilter == 'belum_lunas'
                            ? 'Semua Transaksi Telah Lunas'
                            : 'Tidak Ada Transaksi',
                        subtitle: _selectedFilter == 'belum_lunas'
                            ? 'Pelanggan ini tidak memiliki tagihan piutang aktif saat ini.'
                            : 'Belum ada riwayat transaksi pada filter ini.',
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                        itemCount: displayedSales.length,
                        itemBuilder: (context, index) {
                          final sale = displayedSales[index];
                          return _buildDebtCard(context, sale);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTab(String key, String label, {Color? color}) {
    final isSelected = _selectedFilter == key;
    final activeColor = color ?? AppTheme.primary;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
      },
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, SaleModel sale) {
    final isLunas = sale.isPaid;
    final isPartial = sale.isPartial;
    final percentPaid = sale.totalAmount > 0
        ? (sale.paidAmount / sale.totalAmount).clamp(0.0, 1.0)
        : 1.0;

    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isLunas ? Colors.green.shade100 : (isPartial ? Colors.orange.shade200 : Colors.red.shade200),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14.sp, color: AppTheme.textSecondary),
                    SizedBox(width: 6.w),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(sale.createdAt),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isLunas
                        ? Colors.green.shade50
                        : (isPartial ? Colors.orange.shade50 : Colors.red.shade50),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: isLunas
                          ? Colors.green.shade300
                          : (isPartial ? Colors.orange.shade300 : Colors.red.shade300),
                    ),
                  ),
                  child: Text(
                    isLunas
                        ? '🟢 LUNAS'
                        : (isPartial ? '🟡 BELUM LUNAS (SEBAGIAN)' : '🔴 BELUM DIBAYAR'),
                    style: TextStyle(
                      color: isLunas
                          ? Colors.green.shade800
                          : (isPartial ? Colors.orange.shade900 : Colors.red.shade800),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: TRX-${sale.id.substring(0, 6).toUpperCase()}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp, fontFamily: 'monospace'),
                ),
                Text(
                  'Kasir: ${sale.cashierName}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(height: 1, thickness: 0.5),
            SizedBox(height: 10.h),

            // Rincian Pembayaran
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Belanja:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                Text(
                  CurrencyFormatter.formatRupiah(sale.totalAmount),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sudah Dibayar:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp)),
                Text(
                  CurrencyFormatter.formatRupiah(sale.paidAmount),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: Colors.green.shade700),
                ),
              ],
            ),
            SizedBox(height: 6.h),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: percentPaid,
                minHeight: 6.h,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLunas ? Colors.green : (isPartial ? Colors.orange : Colors.red),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLunas ? 'Status Tagihan:' : 'Sisa Piutang:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                Text(
                  isLunas ? 'LUNAS (Rp 0)' : CurrencyFormatter.formatRupiah(sale.remainingAmount),
                  style: TextStyle(
                    color: isLunas ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),

            if (!isLunas) ...[
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaymentDialog(context, sale),
                  icon: Icon(Icons.payments_rounded, size: 18.sp),
                  label: const Text('Bayar Cicilan / Pelunasan', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, SaleModel sale) {
    final TextEditingController amountController = TextEditingController();

    Get.defaultDialog(
      title: 'Bayar Cicilan / Pelunasan',
      titleStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sisa Tagihan:'),
                  Text(
                    CurrencyFormatter.formatRupiah(sale.remainingAmount),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Quick Button Bayar Penuh
            OutlinedButton.icon(
              onPressed: () {
                amountController.text = 'Rp ${NumberFormat('#,###', 'id_ID').format(sale.remainingAmount)}';
              },
              icon: Icon(Icons.check_circle_outline_rounded, size: 16.sp, color: Colors.green.shade700),
              label: Text(
                'Bayar Lunas Semua (${CurrencyFormatter.formatRupiah(sale.remainingAmount)})',
                style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.green.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                CurrencyTextInputFormatter.currency(
                  locale: 'id_ID',
                  decimalDigits: 0,
                  symbol: 'Rp ',
                )
              ],
              decoration: InputDecoration(
                labelText: 'Nominal Bayar',
                hintText: 'Masukkan jumlah uang',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Proses Pembayaran',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.primary,
      onConfirm: () {
        final amountStr = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
        final amount = int.tryParse(amountStr) ?? 0;

        if (amount <= 0) {
          Get.snackbar('Error', 'Masukkan nominal yang valid', backgroundColor: Colors.red.shade100);
          return;
        }

        if (amount > sale.remainingAmount) {
          Get.snackbar('Error', 'Nominal melebihi sisa tagihan', backgroundColor: Colors.red.shade100);
          return;
        }

        controller.payDebt(sale.id, amount).then((_) {
          Get.back(); // close dialog
          Get.snackbar(
            'Sukses',
            'Pembayaran sebesar ${CurrencyFormatter.formatRupiah(amount)} berhasil dicatat!',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
            duration: const Duration(seconds: 3),
          );
          _loadSales(); // refresh list
        }).catchError((err) {
          Get.snackbar('Gagal', 'Error: $err', backgroundColor: Colors.red.shade100);
        });
      },
    );
  }
}
