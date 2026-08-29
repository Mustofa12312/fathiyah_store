import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final users = <UserModel>[
    UserModel(
      id: 'usr_admin1',
      name: 'Owner (Mustofa)',
      username: 'admin',
      password: '123',
      role: 'admin',
    ),
    UserModel(
      id: 'usr_cashier1',
      name: 'Kasir (Fulan)',
      username: 'kasir',
      password: '123',
      role: 'cashier',
    ),
  ].obs;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  Future<AuthService> init() async {
    return this;
  }

  UserModel? login(String username, String password) {
    final user = users.firstWhereOrNull((u) => u.username == username && u.password == password);
    if (user != null && user.status == 'aktif') {
      currentUser.value = user;
    }
    return currentUser.value;
  }

  void logout() {
    currentUser.value = null;
  }

  void addUser(UserModel user) {
    users.add(user);
  }
  
  void updateUser(UserModel updatedUser) {
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
    }
  }
}
