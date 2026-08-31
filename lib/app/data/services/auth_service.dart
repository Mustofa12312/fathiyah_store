// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/audit_log_model.dart';

class AuthService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  bool get isSupervisor => currentUser.value?.isSupervisor ?? false;
  bool get isCashier => currentUser.value?.isCashier ?? false;

  final users = <UserModel>[].obs;

  Future<AuthService> init() async {
    // Auto-create admin if database is empty
    try {
      final query = await _firestore.collection('users').limit(1).get();
      if (query.docs.isEmpty) {
        final defaultAdmin = UserModel(
          id: const Uuid().v4(),
          username: 'admin',
          password: '123',
          name: 'Super Admin',
          role: 'admin',
          status: 'aktif',
          pin: '123456', // default admin pin
        );
        await _firestore.collection('users').doc(defaultAdmin.id).set(defaultAdmin.toJson());
      }
    } catch (e) {
      debugPrint("Error checking/creating default admin: $e");
    }

    // Load users from Firestore
    _firestore.collection('users').snapshots().listen((snapshot) {
      users.value = snapshot.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => debugPrint('AuthService Error: $e'));
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
      debugPrint("Login error: $e");
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

  Future<bool> verifySupervisorPin(String pin) async {
    // Check if any active supervisor or admin has this PIN
    final match = users.firstWhereOrNull((u) => 
      (u.role == 'supervisor' || u.role == 'admin') && 
      u.status == 'aktif' && 
      u.pin == pin
    );
    
    if (match != null) {
      await _logAction('AUTH', 'PIN', match.id, 'Otorisasi PIN oleh ${match.name}');
      return true;
    }
    return false;
  }
}
