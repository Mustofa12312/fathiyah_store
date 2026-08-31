// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/audit_log_model.dart';

class AuthService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  bool get isSupervisor => currentUser.value?.isSupervisor ?? false;
  bool get isCashier => currentUser.value?.isCashier ?? false;

  final users = <UserModel>[].obs;

  String _emailFromUsername(String username) => '${username.trim().toLowerCase()}@fathiyah.store';

  Future<AuthService> init() async {
    // Auto-create admin if database is empty
    try {
      final query = await _firestore.collection('users').limit(1).get();
      if (query.docs.isEmpty) {
        String adminEmail = _emailFromUsername('admin');
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: 'password123', // Initial secure password for admin
        );
        
        final defaultAdmin = UserModel(
          id: userCred.user!.uid,
          username: 'admin',
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
      
      // Update currentUser if their document changed
      if (currentUser.value != null) {
        final updatedUser = users.value.firstWhereOrNull((u) => u.id == currentUser.value!.id);
        if (updatedUser != null) {
          currentUser.value = updatedUser;
        }
      }
    }, onError: (e) => debugPrint('AuthService Error: $e'));

    // Listen to Auth State Changes
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // Fetch user from Firestore
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          final userModel = UserModel.fromJson(doc.data()!, doc.id);
          if (userModel.status == 'aktif') {
            currentUser.value = userModel;
          } else {
            // User is inactive, sign them out
            await logout();
          }
        }
      } else {
        currentUser.value = null;
      }
    });

    return this;
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      String email = _emailFromUsername(username);
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCred.user != null) {
        final doc = await _firestore.collection('users').doc(userCred.user!.uid).get();
        if (doc.exists) {
          final userModel = UserModel.fromJson(doc.data()!, doc.id);
          if (userModel.status == 'aktif') {
            currentUser.value = userModel;
            return userModel;
          } else {
            await logout();
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint("Login error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
  }

  Future<void> addUser(UserModel user, String password) async {
    try {
      // Create user using a secondary Firebase app to prevent logging out the current admin
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
      }
      
      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      String email = _emailFromUsername(user.username);
      UserCredential userCred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // We got the UID from Firebase Auth, use it for the UserModel
      final newUser = user.copyWith(id: userCred.user!.uid);
      
      await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
      await _logAction('CREATE', 'USER', newUser.id, 'Menambahkan user: ${newUser.name}');
      
      await secondaryAuth.signOut();
    } catch (e) {
      debugPrint("Error adding user: $e");
      rethrow;
    }
  }
  
  Future<void> updateUser(UserModel updatedUser, {String? newPassword}) async {
    await _firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());
    
    // Note: To change a user's password via Firebase Auth securely, 
    // it's typically done via a password reset email or a Cloud Function, 
    // unless the user is changing their own password.
    // For now, we update the Firestore document.

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
