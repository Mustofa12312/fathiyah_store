// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import '../models/sale_model.dart';
import 'shop_service.dart';
import 'package:fathiyah_store/app/core/utils/currency_formatter.dart';

class PrinterService extends GetxService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final ShopService _shopService = Get.find<ShopService>();

  final RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  final Rx<BluetoothDevice?> selectedDevice = Rx<BluetoothDevice?>(null);
  final RxBool isConnected = false.obs;

  Future<PrinterService> init() async {
    await scanDevices();
    
    bluetooth.onStateChanged().listen((state) {
      if (state == BlueThermalPrinter.CONNECTED) {
        isConnected.value = true;
      } else if (state == BlueThermalPrinter.DISCONNECTED) {
        isConnected.value = false;
        selectedDevice.value = null;
      }
    });

    return this;
  }

  Future<void> scanDevices() async {
    try {
      devices.value = await bluetooth.getBondedDevices();
    } catch (e) {
      debugPrint("Error scanning devices: $e");
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      selectedDevice.value = device;
      isConnected.value = true;
    } catch (e) {
      Get.snackbar('Koneksi Gagal', 'Tidak dapat terhubung ke printer');
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      isConnected.value = false;
      selectedDevice.value = null;
    } catch (e) {
      debugPrint("Error disconnecting: $e");
    }
  }

  Future<void> printReceipt(SaleModel sale) async {
    if (!isConnected.value) {
      Get.snackbar('Printer', 'Printer belum terhubung');
      return;
    }

    final storeName = _shopService.shop.value?.name ?? "FATHIYAH STORE";
    final footer = _shopService.shop.value?.receiptFooter ?? "Terima Kasih!";

    try {
      bluetooth.printCustom(storeName, 3, 1);
      bluetooth.printNewLine();
      
      bluetooth.printCustom('TRX-${sale.id.substring(0, 8).toUpperCase()}', 1, 1);
      bluetooth.printCustom('Waktu: ${DateFormat('dd MMM yyyy HH:mm').format(sale.createdAt)}', 1, 1);
      bluetooth.printCustom('Kasir: ${sale.cashierName}', 1, 1);
      bluetooth.printNewLine();
      
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      for (var item in sale.items) {
        bluetooth.printCustom(item.productName, 1, 0);
        bluetooth.printLeftRight(
            '${item.quantity} x ${CurrencyFormatter.formatRupiah(item.price)}',
            CurrencyFormatter.formatRupiah(item.subtotal),
            1,
            format: "%-15s %15s %n");
      }
      
      bluetooth.printCustom("--------------------------------", 1, 1);
      bluetooth.printLeftRight('Total', CurrencyFormatter.formatRupiah(sale.totalAmount), 1, format: "%-15s %15s %n");
      bluetooth.printLeftRight('Dibayar', CurrencyFormatter.formatRupiah(sale.paidAmount), 1, format: "%-15s %15s %n");
      
      if (sale.remainingAmount > 0) {
        bluetooth.printLeftRight('Sisa', CurrencyFormatter.formatRupiah(sale.remainingAmount), 1, format: "%-15s %15s %n");
        bluetooth.printCustom('Status: BELUM LUNAS', 1, 1);
      } else {
        bluetooth.printLeftRight('Kembali', CurrencyFormatter.formatRupiah(sale.paidAmount - sale.totalAmount), 1, format: "%-15s %15s %n");
        bluetooth.printCustom('Status: LUNAS', 1, 1);
      }
      
      bluetooth.printNewLine();
      bluetooth.printCustom(footer, 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mencetak struk: $e');
    }
  }
}
