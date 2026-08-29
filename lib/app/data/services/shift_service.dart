import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/shift_model.dart';
import 'auth_service.dart';

class ShiftService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  final Rx<ShiftModel?> currentShift = Rx<ShiftModel?>(null);
  final shifts = <ShiftModel>[].obs;

  Future<ShiftService> init() async {
    _authService.currentUser.listen((user) {
      if (user != null && !user.isAdmin) {
        _checkActiveShift(user.id);
      } else {
        currentShift.value = null;
      }
    });
    
    // Listen to all shifts for admin/reports
    _firestore.collection('shifts').orderBy('startTime', descending: true).snapshots().listen((snapshot) {
      shifts.value = snapshot.docs.map((doc) => ShiftModel.fromJson(doc.data(), doc.id)).toList();
    });

    return this;
  }

  Future<void> _checkActiveShift(String cashierId) async {
    final query = await _firestore.collection('shifts')
        .where('cashierId', isEqualTo: cashierId)
        .where('status', isEqualTo: 'open')
        .limit(1)
        .get();
        
    if (query.docs.isNotEmpty) {
      currentShift.value = ShiftModel.fromJson(query.docs.first.data(), query.docs.first.id);
    } else {
      currentShift.value = null;
    }
  }

  Future<void> openShift(double startBalance) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    final shift = ShiftModel(
      id: const Uuid().v4(),
      cashierId: user.id,
      cashierName: user.name,
      startTime: DateTime.now(),
      startBalance: startBalance,
      status: 'open',
    );

    await _firestore.collection('shifts').doc(shift.id).set(shift.toJson());
    currentShift.value = shift;
  }

  Future<void> closeShift(double endBalance) async {
    final shift = currentShift.value;
    if (shift == null) return;

    final updatedShift = shift.copyWith(
      endTime: DateTime.now(),
      endBalance: endBalance,
      status: 'closed',
    );

    await _firestore.collection('shifts').doc(shift.id).update(updatedShift.toJson());
    currentShift.value = null;
  }

  // To be called by SaleService
  Future<void> recordCashSale(double amount) async {
    final shift = currentShift.value;
    if (shift != null && shift.status == 'open') {
      final updatedShift = shift.copyWith(
        totalSalesCash: shift.totalSalesCash + amount,
      );
      await _firestore.collection('shifts').doc(shift.id).update({'totalSalesCash': updatedShift.totalSalesCash});
      currentShift.value = updatedShift;
    }
  }

  // To be called by ExpenseService
  Future<void> recordCashExpense(double amount) async {
    final shift = currentShift.value;
    if (shift != null && shift.status == 'open') {
      final updatedShift = shift.copyWith(
        totalExpensesCash: shift.totalExpensesCash + amount,
      );
      await _firestore.collection('shifts').doc(shift.id).update({'totalExpensesCash': updatedShift.totalExpensesCash});
      currentShift.value = updatedShift;
    }
  }
}
