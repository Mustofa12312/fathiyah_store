// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/product_service.dart';
import 'app/data/services/category_service.dart';
import 'app/data/services/customer_service.dart';
import 'app/data/services/sale_service.dart';
import 'app/data/services/expense_service.dart';
import 'app/data/services/shift_service.dart';
import 'app/data/services/audit_log_service.dart';
import 'app/data/services/stock_movement_service.dart';
import 'app/data/services/shop_service.dart';
import 'app/data/services/printer_service.dart';
import 'app/data/services/backup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Services - urutan berdasarkan dependency graph
  // Layer 1: tidak bergantung pada service lain
  Get.put(AuthService(), permanent: true).init();
  Get.put(StockMovementService(), permanent: true);
  Get.put(AuditLogService(), permanent: true).init();
  Get.put(ShiftService(), permanent: true).init();
  // Layer 2: bergantung pada Layer 1
  Get.put(ShopService(), permanent: true).init();
  Get.put(CategoryService(), permanent: true).init();
  Get.put(ProductService(), permanent: true).init();
  Get.put(CustomerService(), permanent: true).init();
  // Layer 3: bergantung pada Layer 1 & 2
  Get.put(SaleService(), permanent: true).init();
  Get.put(ExpenseService(), permanent: true).init();
  Get.put(PrinterService(), permanent: true).init();
  // Layer 4: bergantung pada semua layer di atas
  Get.put(BackupService(), permanent: true);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        // Gunakan ukuran desain yang lebih besar untuk tablet agar elemen tidak terlalu besar
        final designSize = isTablet ? const Size(800, 1280) : const Size(390, 844);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              title: 'Fathiyah Store',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              initialRoute: AppPages.INITIAL,
              getPages: AppPages.routes,
            );
          },
        );
      },
    );
  }
}
