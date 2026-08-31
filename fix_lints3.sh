#!/bin/bash
sed -i 's/initial =/INITIAL =/g' lib/app/routes/app_pages.dart
sed -i 's/splash =/SPLASH =/g' lib/app/routes/app_routes.dart
sed -i 's/auth =/AUTH =/g' lib/app/routes/app_routes.dart
sed -i 's/dashboard =/DASHBOARD =/g' lib/app/routes/app_routes.dart
sed -i 's/category =/CATEGORY =/g' lib/app/routes/app_routes.dart
sed -i 's/Routes.splash/Routes.SPLASH/g' lib/app/routes/app_pages.dart

# Add ignore back to these two files
sed -i '1i // ignore_for_file: constant_identifier_names' lib/app/routes/app_routes.dart
sed -i '1i // ignore_for_file: constant_identifier_names' lib/app/routes/app_pages.dart
