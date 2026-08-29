import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/audit_log_model.dart';

class AuthService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  final users = <UserModel>[].obs;

  Future<AuthService> init() async {
    // Load users from Firestore
    _firestore.collection('users').snapshots().listen((snapshot) {
      users.value = snapshot.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => print('AuthService Error: $e'));
    return this;
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final user = UserModel.fromJson(doc.data(), doc.id);
        if (user.status == 'aktif') {
          currentUser.value = user;
          return user;
        }
      }
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  void logout() {
    currentUser.value = null;
  }

  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
    await _logAction('CREATE', 'USER', user.id, 'Menambahkan user: ${user.name}');
  }
  
  Future<void> updateUser(UserModel updatedUser) async {
    await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());
    await _logAction('UPDATE', 'USER', updatedUser.id, 'Mengubah data user: ${updatedUser.name}');
  }
  
  Future<void> _logAction(String action, String entity, String entityId, String details) async {
    final curUser = currentUser.value;
    if (curUser == null) return;
    
    final log = AuditLogModel(
      id: const Uuid().v4(),
      userId: curUser.id,
      userName: curUser.name,
      action: action,
      entity: entity,
      entityId: entityId,
      details: details,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('audit_logs').doc(log.id).set(log.toJson());
  }
}
