import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fathiyah_store/app/data/services/printer_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fathiyah_store/app/core/theme/app_theme.dart';

class PrinterSettingsView extends StatelessWidget {
  const PrinterSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterService printerService = Get.find<PrinterService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Pengaturan Printer', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => printerService.scanDevices(),
          ),
        ],
      ),
      body: Obx(() {
        final devices = printerService.devices;
        final selectedDevice = printerService.selectedDevice.value;
        final isConnected = printerService.isConnected.value;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Koneksi',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              isConnected ? 'Terhubung ke ${selectedDevice?.name ?? 'Printer'}' : 'Tidak Terhubung',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isConnected ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isConnected)
                        TextButton(
                          onPressed: () => printerService.disconnect(),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Putus'),
                        ),
                    ],
                  ),
                  if (isConnected) ...[
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _testPrint(printerService),
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('Test Print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: devices.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada perangkat Bluetooth ditemukan.\nPastikan Bluetooth aktif dan printer sudah di-pairing.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isThisDeviceConnected = isConnected && selectedDevice?.address == device.address;

                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.only(bottom: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                              color: isThisDeviceConnected ? AppTheme.primary : Colors.grey.shade200,
                              width: isThisDeviceConnected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            leading: Icon(
                              Icons.bluetooth_rounded,
                              color: isThisDeviceConnected ? AppTheme.primary : Colors.grey.shade400,
                            ),
                            title: Text(
                              device.name ?? 'Unknown Device',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                            subtitle: Text(device.address ?? ''),
                            trailing: isThisDeviceConnected
                                ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () => printerService.connect(device),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                      foregroundColor: AppTheme.primary,
                                      elevation: 0,
                                    ),
                                    child: const Text('Hubungkan'),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _testPrint(PrinterService printerService) {
    if (!printerService.isConnected.value) return;
    try {
      printerService.bluetooth.printCustom("TEST PRINT", 3, 1);
      printerService.bluetooth.printNewLine();
      printerService.bluetooth.printCustom("Printer terhubung dan siap digunakan.", 1, 1);
      printerService.bluetooth.printNewLine();
      printerService.bluetooth.printNewLine();
      printerService.bluetooth.paperCut();
      Get.snackbar('Sukses', 'Test print berhasil dikirim');
    } catch (e) {
      Get.snackbar('Error', 'Gagal test print: $e');
    }
  }
}
