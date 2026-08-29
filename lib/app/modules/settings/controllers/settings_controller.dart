// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/shift_service.dart';

class SettingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ShiftService shiftService = Get.find<ShiftService>();

  UserModel? get currentUser => _authService.currentUser.value;
  bool get isAdmin => _authService.isAdmin;

  List<UserModel> get allUsers => _authService.users;

  void logout() {
    _authService.logout();
    Get.offAllNamed(Routes.AUTH);
  }

  void toggleUserStatus(String userId) {
    if (!isAdmin) return;
    
    final user = allUsers.firstWhereOrNull((u) => u.id == userId);
    if (user != null) {
      if (user.role == 'admin') {
        Get.snackbar('Error', 'Tidak dapat menonaktifkan Admin Utama');
        return;
      }
      
      final newStatus = user.status == 'aktif' ? 'nonaktif' : 'aktif';
      _authService.updateUser(user.copyWith(status: newStatus));
      update(); // refresh UI
    }
  }

  void changePassword(String oldPass, String newPass) async {
    final user = currentUser;
    if (user == null) return;

    if (user.password != oldPass) {
      Get.snackbar('Error', 'Password lama salah', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      await _authService.updateUser(user.copyWith(password: newPass));
      Get.back();
      Get.snackbar('Sukses', 'Password berhasil diubah', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah password', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
