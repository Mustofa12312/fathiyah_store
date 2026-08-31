// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/sale_model.dart';
import '../../../data/services/shop_service.dart';
import '../../../data/services/printer_service.dart';
import '../../../routes/app_pages.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/services/customer_service.dart';

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
            onPressed: () => _shareReceipt(sale),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _showPrinterDialog(context, sale),
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
                    Obx(() {
                      final shopName = Get.find<ShopService>().shop.value?.name ?? 'FATHIYAH STORE';
                      return Text(shopName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp));
                    }),
                    SizedBox(height: 16.h),
                    const Divider(color: Colors.black12, thickness: 2),
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
                    if (sale.paidAmount > sale.totalAmount)
                      _buildTotalRow('Kembalian', sale.paidAmount - sale.totalAmount, isHighlight: true),
                      
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
                    Obx(() {
                      final footer = Get.find<ShopService>().shop.value?.receiptFooter ?? 'Terima Kasih';
                      return Text(footer, textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12.sp));
                    }),
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
    final shopService = Get.find<ShopService>();
    final storeName = shopService.shop.value?.name ?? "FATHIYAH STORE";
    final footer = shopService.shop.value?.receiptFooter ?? "Terima Kasih!";
    
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
      sb.writeln("${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)} = ${CurrencyFormatter.formatRupiah(item.subtotal)}");
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
    sb.writeln(footer);

    final text = Uri.encodeComponent(sb.toString());
    String phoneParam = '';
    if (sale.customerId != null) {
      final c = Get.find<CustomerService>().customers.firstWhereOrNull((c) => c.id == sale.customerId);
      if (c != null && c.phone.isNotEmpty) {
        String phone = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (phone.startsWith('0')) phone = '62${phone.substring(1)}';
        phoneParam = 'phone=$phone&';
      }
    }
    final url = Uri.parse("whatsapp://send?${phoneParam}text=$text");
    
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

  void _shareReceipt(SaleModel sale) {
    final shopService = Get.find<ShopService>();
    final storeName = shopService.shop.value?.name ?? "FATHIYAH STORE";
    final footer = shopService.shop.value?.receiptFooter ?? "Terima Kasih!";
    
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
      sb.writeln("${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)} = ${CurrencyFormatter.formatRupiah(item.subtotal)}");
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
    sb.writeln(footer);

    Share.share(sb.toString(), subject: 'Struk Belanja $storeName');
  }

  void _showPrinterDialog(BuildContext context, SaleModel sale) {
    final printerService = Get.find<PrinterService>();
    
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pilih Printer Bluetooth', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.refresh), onPressed: printerService.scanDevices),
              ],
            ),
            Divider(color: AppTheme.divider),
            Obx(() {
              if (printerService.devices.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('Tidak ada perangkat bluetooth ditemukan')),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: printerService.devices.length,
                itemBuilder: (context, index) {
                  final device = printerService.devices[index];
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text(device.name ?? 'Unknown Device'),
                    subtitle: Text(device.address ?? ''),
                    trailing: Obx(() => printerService.selectedDevice.value?.address == device.address
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const SizedBox.shrink()),
                    onTap: () async {
                      await printerService.connect(device);
                      if (printerService.isConnected.value) {
                        Get.back();
                        printerService.printReceipt(sale);
                      }
                    },
                  );
                },
              );
            }),
            SizedBox(height: 16.h),
            Obx(() {
              if (printerService.isConnected.value) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      printerService.printReceipt(sale);
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak Struk Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
