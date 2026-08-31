import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../data/services/shift_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Re-authenticate user before changing password
      final cred = EmailAuthProvider.credential(
        email: user.email!, 
        password: oldPass
      );
      await user.reauthenticateWithCredential(cred);
      
      // Update password
      await user.updatePassword(newPass);
      Get.back();
      Get.snackbar('Sukses', 'Password berhasil diubah', snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Password lama salah', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Gagal mengubah password: ${e.message}', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah password', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
