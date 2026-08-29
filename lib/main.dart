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
import 'app/data/services/customer_service.dart';
import 'app/data/services/sale_service.dart';
import 'app/data/services/expense_service.dart';
import 'app/data/services/shift_service.dart';
import 'app/data/services/audit_log_service.dart';
import 'app/data/services/stock_movement_service.dart';
import 'app/data/services/shop_service.dart';
import 'app/data/services/printer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Services (Async init for firestore stream listeners)
  Get.put(AuthService(), permanent: true).init();
  Get.put(ProductService(), permanent: true).init();
  Get.put(CustomerService(), permanent: true).init();
  Get.put(SaleService(), permanent: true).init();
  Get.put(ExpenseService(), permanent: true).init();
  Get.put(ShiftService(), permanent: true).init();
  Get.put(AuditLogService(), permanent: true).init();
  Get.put(StockMovementService(), permanent: true);
  Get.put(ShopService(), permanent: true).init();
  Get.put(PrinterService(), permanent: true).init();

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
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 Pro sizes as reference
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
  }
}
