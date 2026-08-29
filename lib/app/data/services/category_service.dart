import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import 'audit_log_service.dart';

class CategoryService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = Get.find<AuditLogService>();
  
  final categories = <CategoryModel>[].obs;

  Future<CategoryService> init() async {
    _firestore.collection('categories').snapshots().listen((snapshot) {
      categories.value = snapshot.docs.map((doc) => CategoryModel.fromJson(doc.data(), doc.id)).toList();
    }, onError: (e) => print('CategoryService Error: $e'));
    return this;
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).set(category.toJson());
    
    await _auditLogService.logAction(
      action: 'CREATE',
      entity: 'CATEGORY',
      entityId: category.id,
      details: 'Menambahkan kategori baru: ${category.name}',
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).update(category.toJson());
    
    await _auditLogService.logAction(
      action: 'UPDATE',
      entity: 'CATEGORY',
      entityId: category.id,
      details: 'Mengupdate data kategori: ${category.name}',
    );
  }

  Future<void> deleteCategory(String id, String categoryName) async {
    await _firestore.collection('categories').doc(id).delete();
    
    await _auditLogService.logAction(
      action: 'DELETE',
      entity: 'CATEGORY',
      entityId: id,
      details: 'Menghapus kategori: $categoryName',
    );
  }
}
