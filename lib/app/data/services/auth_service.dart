import 'package:flutter/material.dart';
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

  /// Format email standar: username@leiil.store
  String _emailFromUsername(String username) {
    return '${username.trim().toLowerCase()}@leiil.store';
  }

  Future<AuthService> init() async {
    // Pastikan ada akun admin default
    await _ensureDefaultAdmin();

    // Auto-login jika sudah ada sesi Firebase Auth aktif
    final currentFirebaseUser = _auth.currentUser;
    if (currentFirebaseUser != null) {
      try {
        final doc = await _firestore.collection('users').doc(currentFirebaseUser.uid).get();
        if (doc.exists) {
          final userModel = UserModel.fromJson(doc.data()!, doc.id);
          if (userModel.status == 'aktif') {
            currentUser.value = userModel;
          }
        }
      } catch (e) {
        debugPrint("Error restoring session: $e");
      }
    }

    // Load users dari Firestore secara realtime
    _firestore.collection('users').snapshots().listen((snapshot) {
      users.value = snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();

      // Update currentUser jika dokumen mereka berubah
      if (currentUser.value != null) {
        final updatedUser =
            users.firstWhereOrNull((u) => u.id == currentUser.value!.id);
        if (updatedUser != null) {
          currentUser.value = updatedUser;
        }
      }
    }, onError: (e) => debugPrint('AuthService Error: $e'));

    // Listen perubahan auth state
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        try {
          final doc = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .get();
          if (doc.exists) {
            final userModel = UserModel.fromJson(doc.data()!, doc.id);
            if (userModel.status == 'aktif') {
              currentUser.value = userModel;
            } else {
              await logout();
            }
          }
        } catch (e) {
          debugPrint("Error in auth state listener: $e");
        }
      } else {
        currentUser.value = null;
      }
    });

    return this;
  }

  /// Pastikan akun admin default ada di Firebase Auth & Firestore.
  /// Dijalankan saat init().
  Future<void> _ensureDefaultAdmin() async {
    try {
      // Coba login sebagai admin untuk cek apakah akunnya sudah ada
      final email = _emailFromUsername('admin');
      try {
        final userCred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: 'password123',
        );
        // Admin sudah ada dan bisa login → pastikan ada dokumen Firestore-nya
        if (userCred.user != null) {
          final doc = await _firestore
              .collection('users')
              .doc(userCred.user!.uid)
              .get();
          if (!doc.exists) {
            // Buat dokumen Firestore untuk admin
            final defaultAdmin = UserModel(
              id: userCred.user!.uid,
              username: 'admin',
              name: 'Super Admin',
              role: 'admin',
              status: 'aktif',
              pin: '123456',
            );
            await _firestore
                .collection('users')
                .doc(defaultAdmin.id)
                .set(defaultAdmin.toJson());
          }
          // Sign out agar user harus login manual
          await _auth.signOut();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Admin belum ada → buat baru
          debugPrint("Admin belum ada, membuat akun admin default...");
          final userCred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: 'password123',
          );
          final defaultAdmin = UserModel(
            id: userCred.user!.uid,
            username: 'admin',
            name: 'Super Admin',
            role: 'admin',
            status: 'aktif',
            pin: '123456',
          );
          await _firestore
              .collection('users')
              .doc(defaultAdmin.id)
              .set(defaultAdmin.toJson());
          // Sign out agar user harus login manual
          await _auth.signOut();
          debugPrint("Admin default berhasil dibuat: admin / password123");
        } else {
          // Error lain (misal wrong-password) → admin ada tapi password berbeda, skip
          debugPrint("Admin check: ${e.code} - skip create");
        }
      }
    } catch (e) {
      debugPrint("Error ensuring default admin: $e");
    }
  }

  /// Login: sign-in ke Firebase Auth lalu sinkronkan data Firestore
  Future<UserModel?> login(String username, String password) async {
    try {
      final email = _emailFromUsername(username);

      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCred.user == null) return null;

      final uid = userCred.user!.uid;

      // Cek dokumen user di Firestore
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final userModel = UserModel.fromJson(doc.data()!, doc.id);
        if (userModel.status == 'aktif') {
          currentUser.value = userModel;
          return userModel;
        } else {
          await logout();
          Get.snackbar(
            'Login Gagal',
            'Akun Anda telah dinonaktifkan.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.1),
            colorText: Colors.red,
          );
          return null;
        }
      } else {
        // Dokumen tidak ditemukan — kemungkinan migrasi, buat dokumen baru
        if (username.toLowerCase() == 'admin') {
          final newAdmin = UserModel(
            id: uid,
            username: 'admin',
            name: 'Super Admin',
            role: 'admin',
            status: 'aktif',
            pin: '123456',
          );
          await _firestore
              .collection('users')
              .doc(uid)
              .set(newAdmin.toJson());
          currentUser.value = newAdmin;
          return newAdmin;
        }
        await logout();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Login error: ${e.code}");
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Username tidak ditemukan.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Password salah.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        default:
          message = 'Terjadi kesalahan: ${e.message}';
      }
      Get.snackbar(
        'Login Gagal',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return null;
    } catch (e) {
      debugPrint("Login error: $e");
      Get.snackbar(
        'Login Gagal',
        'Terjadi kesalahan. Periksa koneksi internet Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
  }

  Future<void> addUser(UserModel user, String password) async {
    try {
      // Buat user di Firebase Auth menggunakan secondary app
      // agar tidak logout admin yang sedang aktif
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
      }

      FirebaseAuth secondaryAuth =
          FirebaseAuth.instanceFor(app: secondaryApp);

      String email = _emailFromUsername(user.username);
      UserCredential userCred =
          await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Gunakan UID dari Firebase Auth untuk UserModel
      final newUser = user.copyWith(id: userCred.user!.uid);

      await _firestore
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toJson());
      await _logAction(
          'CREATE', 'USER', newUser.id, 'Menambahkan user: ${newUser.name}');

      await secondaryAuth.signOut();
    } catch (e) {
      debugPrint("Error adding user: $e");
      rethrow;
    }
  }

  Future<void> updateUser(UserModel updatedUser, {String? newPassword}) async {
    await _firestore
        .collection('users')
        .doc(updatedUser.id)
        .update(updatedUser.toJson());

    await _logAction('UPDATE', 'USER', updatedUser.id,
        'Mengubah data user: ${updatedUser.name}');
  }

  Future<void> _logAction(
      String action, String entity, String entityId, String details) async {
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
    // Cek apakah ada supervisor/admin aktif dengan PIN ini
    final match = users.firstWhereOrNull((u) =>
        (u.role == 'supervisor' || u.role == 'admin') &&
        u.status == 'aktif' &&
        u.pin == pin);

    if (match != null) {
      await _logAction(
          'AUTH', 'PIN', match.id, 'Otorisasi PIN oleh ${match.name}');
      return true;
    }
    return false;
  }
}
