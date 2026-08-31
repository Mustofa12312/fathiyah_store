// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/stock_movement_model.dart';
import 'auth_service.dart';

class StockMovementService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  Future<void> recordMovement({
    required String productId,
    required String productName,
    required int quantity,
    required String type,
    String note = '',
  }) async {
    final movement = createMovementObject(
      productId: productId,
      productName: productName,
      quantity: quantity,
      type: type,
      note: note,
    );

    await _firestore.collection('stock_movements').doc(movement.id).set(movement.toJson());
  }

  StockMovementModel createMovementObject({
    required String productId,
    required String productName,
    required int quantity,
    required String type,
    String note = '',
  }) {
    final user = _authService.currentUser.value;
    
    return StockMovementModel(
      id: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantity: quantity,
      type: type,
      userId: user?.id ?? 'system',
      userName: user?.name ?? 'System',
      note: note,
      createdAt: DateTime.now(),
    );
  }


  
  Stream<List<StockMovementModel>> getMovementsForProduct(String productId) {
    return _firestore
        .collection('stock_movements')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => StockMovementModel.fromJson(doc.data(), doc.id)).toList());
  }
}
