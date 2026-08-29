// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';

class CategoryFormView extends StatefulWidget {
  final CategoryModel? category;
  
  const CategoryFormView({super.key, this.category});

  @override
  State<CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<CategoryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _categoryService = Get.find<CategoryService>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.category != null;
      
      final category = CategoryModel(
        id: isEdit ? widget.category!.id : const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      if (isEdit) {
        _categoryService.updateCategory(category);
      } else {
        _categoryService.addCategory(category);
      }

      Get.back();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Sukses', 
          isEdit ? 'Kategori berhasil diperbarui' : 'Kategori berhasil ditambahkan',
          backgroundColor: Colors.green.shade100,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Kategori', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                decoration: const InputDecoration(hintText: 'Contoh: Minuman'),
              ),
              SizedBox(height: 16.h),

              Text('Deskripsi (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Masukkan deskripsi kategori'),
              ),
              
              SizedBox(height: 32.h),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Kategori'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
