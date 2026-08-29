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
    final user = _authService.currentUser.value;
    if (user == null) return;

    final movement = StockMovementModel(
      id: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantity: quantity,
      type: type,
      userId: user.id,
      userName: user.name,
      note: note,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('stock_movements').doc(movement.id).set(movement.toJson());
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
