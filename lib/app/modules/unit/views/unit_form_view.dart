import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unit_model.dart';
import '../../../data/services/unit_service.dart';

class UnitFormView extends StatefulWidget {
  final UnitModel? unit;
  
  const UnitFormView({super.key, this.unit});

  @override
  State<UnitFormView> createState() => _UnitFormViewState();
}

class _UnitFormViewState extends State<UnitFormView> {
  final _formKey = GlobalKey<FormState>();
  final _unitService = Get.find<UnitService>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
    _descController = TextEditingController(text: widget.unit?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.unit != null;
      
      final unit = UnitModel(
        id: isEdit ? widget.unit!.id : const Uuid().v4(),
        name: _nameController.text,
        description: _descController.text.isEmpty ? null : _descController.text,
      );

      if (isEdit) {
        _unitService.updateUnit(unit);
      } else {
        _unitService.addUnit(unit);
      }

      Get.back();
      Get.snackbar('Sukses', isEdit ? 'Satuan berhasil diperbarui' : 'Satuan berhasil ditambahkan', snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.unit != null;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Satuan' : 'Tambah Satuan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Satuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Contoh: Pcs, Kg, Liter',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Deskripsi (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Deskripsi tambahan',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
