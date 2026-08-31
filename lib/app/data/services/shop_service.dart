import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';
import 'audit_log_service.dart';

class ShopService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = Get.find<AuditLogService>();

  final shop = Rxn<ShopModel>();
  final String _shopDocId = 'main_shop_profile';

  Future<ShopService> init() async {
    _firestore.collection('shops').doc(_shopDocId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        shop.value = ShopModel.fromJson(snapshot.data()!, snapshot.id);
      } else {
        // Create default if not exists
        final defaultShop = ShopModel(
          id: _shopDocId,
          name: 'Fathiyah Store',
        );
        _firestore.collection('shops').doc(_shopDocId).set(defaultShop.toJson());
      }
    });
    return this;
  }

  Future<void> updateShop(ShopModel updatedShop) async {
    await _firestore.collection('shops').doc(_shopDocId).set(updatedShop.toJson());
    await _auditLogService.logAction(
      action: 'UPDATE',
      entity: 'SHOP',
      entityId: _shopDocId,
      details: 'Mengubah profil toko',
    );
  }
}
