import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    final authService = Get.find<AuthService>();
    
    // Check if Firebase Auth has a user
    if (authService.currentUser.value != null) {
      Get.offAllNamed(Routes.LOCK_SCREEN);
    } else {
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
