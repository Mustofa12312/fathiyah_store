import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/sale_model.dart';
import '../../../routes/app_pages.dart';

class ReceiptView extends StatelessWidget {
  final SaleModel sale;

  const ReceiptView({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kertas Struk
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('FATHIYAH STORE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp)),
                    SizedBox(height: 16.h),
                    const Divider(color: Colors.black12, thickness: 2, style: BorderStyle.solid), // style isn't quite supported in Divider natively but visually it's fine
                    SizedBox(height: 16.h),
                    
                    _buildRow('TRX ID', sale.id.substring(0, 8).toUpperCase()),
                    _buildRow('Waktu', DateFormat('dd MMM yyyy HH:mm').format(sale.createdAt)),
                    _buildRow('Kasir', sale.cashierName),
                    if (sale.customerId != null)
                      _buildRow('Pelanggan', '${sale.customerType == 'vip' ? '⭐ ' : ''}Customer'), // Ideally get name, simplified here
                    
                    SizedBox(height: 16.h),
                    const Divider(color: Colors.black12, thickness: 2),
                    SizedBox(height: 16.h),
                    
                    // Items
                    ...sale.items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName}\n${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)}',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatRupiah(item.subtotal),
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 16.h),
                    const Divider(color: Colors.black12, thickness: 2),
                    SizedBox(height: 16.h),

                    // Total & Payment
                    _buildTotalRow('Total Belanja', sale.totalAmount),
                    _buildTotalRow('Dibayar', sale.paidAmount),
                    
                    if (sale.remainingAmount > 0)
                      _buildTotalRow('Sisa / Piutang', sale.remainingAmount, isHighlight: true),
                      
                    SizedBox(height: 24.h),
                    
                    // Status Box
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: sale.paymentStatus == 'lunas' ? Colors.green.shade50 : AppTheme.vipGoldLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        sale.paymentStatus == 'lunas' ? '🟢 LUNAS' : '🟡 BELUM LUNAS / SEBAGIAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: sale.paymentStatus == 'lunas' ? Colors.green.shade800 : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32.h),
                    Text('Terima Kasih', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12.sp)),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              
              // Back to Dashboard Button
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareToWhatsApp(sale),
                        icon: const Icon(Icons.share),
                        label: const Text('Share WA'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed(Routes.DASHBOARD);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: const Text('Kembali ke Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black54, fontSize: 12.sp)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal)),
          Text(
            CurrencyFormatter.formatRupiah(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.red.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _shareToWhatsApp(SaleModel sale) async {
    final storeName = "FATHIYAH STORE";
    
    // Build receipt text
    StringBuffer sb = StringBuffer();
    sb.writeln("*$storeName*");
    sb.writeln("──────────────────");
    sb.writeln("TRX-${sale.id.substring(0, 8).toUpperCase()}");
    sb.writeln("Waktu: ${DateFormat('dd MMM yyyy HH:mm').format(sale.createdAt)}");
    
    if (sale.customerId != null) {
      sb.writeln("Pelanggan: ${sale.customerType.toUpperCase()}");
    }
    sb.writeln("──────────────────");
    
    for (var item in sale.items) {
      sb.writeln("${item.productName}");
      sb.writeln("${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)} = ${CurrencyFormatter.formatRupiah(item.totalPrice)}");
    }
    
    sb.writeln("──────────────────");
    sb.writeln("Total: *${CurrencyFormatter.formatRupiah(sale.totalAmount)}*");
    sb.writeln("Dibayar: ${CurrencyFormatter.formatRupiah(sale.paidAmount)}");
    
    if (sale.remainingAmount > 0) {
      sb.writeln("Sisa/Piutang: ${CurrencyFormatter.formatRupiah(sale.remainingAmount)}");
      sb.writeln("Status: 🟡 BELUM LUNAS");
    } else {
      sb.writeln("Kembali: ${CurrencyFormatter.formatRupiah(sale.paidAmount - sale.totalAmount)}");
      sb.writeln("Status: 🟢 LUNAS");
    }
    
    sb.writeln("──────────────────");
    sb.writeln("Terima Kasih!");

    final text = Uri.encodeComponent(sb.toString());
    final url = Uri.parse("whatsapp://send?text=$text");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to generic URL if Whatsapp app is not installed
      final webUrl = Uri.parse("https://wa.me/?text=$text");
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
      }
    }
  }
}
