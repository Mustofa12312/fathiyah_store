#!/bin/bash
sed -i 's/users.value.firstWhereOrNull/users.firstWhereOrNull/g' lib/app/data/services/auth_service.dart
sed -i '/final ProductService _productService/d' lib/app/data/services/sale_service.dart
sed -i '/final StockMovementService _stockMovementService/d' lib/app/data/services/sale_service.dart
sed -i 's/print(/debugPrint(/g' lib/app/data/services/sale_service.dart
sed -i '/import.*currency_formatter/d' lib/app/modules/expense/views/expense_form_view.dart
sed -i 's/activeColor/activeThumbColor/g' lib/app/modules/pos/views/checkout_view.dart
sed -i '13d' lib/app/modules/pos/views/receipt_view.dart # duplicate import
sed -i '/import.*currency_formatter/d' lib/app/modules/product/views/product_form_view.dart
sed -i '/import.*intl\.dart/d' lib/app/modules/report/views/report_view.dart
sed -i '/import.*blue_thermal_printer/d' lib/app/modules/settings/views/printer_settings_view.dart
sed -i '/import.*currency_formatter/d' lib/app/modules/settings/views/settings_view.dart
sed -i 's/Share.share/ShareResult shareResult = await Share.share/g' lib/app/modules/pos/views/receipt_view.dart # we should use share_plus correctly
sed -i '/import.*pos_controller.dart/d' test/modules/pos/pos_view_test.dart
sed -i '/import.*mockito/d' test/modules/pos/pos_view_test.dart
sed -i '/import.*fake_cloud_firestore/d' test/services/sale_service_test.dart
sed -i '/import.*mockito/d' test/services/sale_service_test.dart
