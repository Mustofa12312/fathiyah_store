#!/bin/bash
sed -i '/import.*product_service.dart/d' lib/app/data/services/sale_service.dart
sed -i '/import.*stock_movement_service.dart/d' lib/app/data/services/sale_service.dart
sed -i 's/\${sale.id}/sale.id/g' lib/app/modules/pos/views/receipt_view.dart
sed -i 's/\${shop.name}/shop.name/g' lib/app/modules/pos/views/receipt_view.dart
sed -i 's/ShareResult shareResult = await Share.share/Share.share/g' lib/app/modules/pos/views/receipt_view.dart
sed -i 's/Share.share/Share.share/g' lib/app/modules/pos/views/receipt_view.dart

sed -i 's/const SimpleBarcodeScanner(/const SimpleBarcodeScannerPage(/g' lib/app/modules/product/views/product_form_view.dart
sed -i '/lineColor/d' lib/app/modules/product/views/product_form_view.dart
sed -i '/cancelButtonText/d' lib/app/modules/product/views/product_form_view.dart
sed -i '/isShowFlashIcon/d' lib/app/modules/product/views/product_form_view.dart

# just ignore the deprecation on simple barcode for now to avoid breaking it
sed -i 's/const SimpleBarcodeScannerPage()/\/* ignore: deprecated_member_use *\/ const SimpleBarcodeScannerPage()/g' lib/app/modules/product/views/product_form_view.dart

# and for Share
sed -i 's/Share.share/\/* ignore: deprecated_member_use *\/ Share.share/g' lib/app/modules/pos/views/receipt_view.dart

# and for routes
sed -i 's/INITIAL =/initial =/g' lib/app/routes/app_pages.dart
sed -i 's/SPLASH =/splash =/g' lib/app/routes/app_routes.dart
sed -i 's/AUTH =/auth =/g' lib/app/routes/app_routes.dart
sed -i 's/DASHBOARD =/dashboard =/g' lib/app/routes/app_routes.dart
sed -i 's/CATEGORY =/category =/g' lib/app/routes/app_routes.dart
sed -i 's/Routes.SPLASH/Routes.splash/g' lib/app/routes/app_pages.dart
