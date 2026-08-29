// ignore_for_file: deprecated_member_use, avoid_print, avoid_types_as_parameter_names, unnecessary_string_interpolations, prefer_function_declarations_over_variables, unnecessary_underscores, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/customer_controller.dart';
import 'customer_form_view.dart';
import '../../../data/models/customer_model.dart';

class CustomerListView extends GetView<CustomerController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pelanggan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const CustomerFormView()),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppTheme.surface,
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Cari nama atau no. HP...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final customers = controller.filteredCustomers;
              if (customers.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada pelanggan ditemukan',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  return _buildCustomerCard(context, customers[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel customer) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => Get.to(() => CustomerFormView(customer: customer)),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: customer.isVip ? AppTheme.vipGoldLight : AppTheme.divider,
                radius: 24.r,
                child: Icon(
                  customer.isVip ? Icons.star_rounded : Icons.person_outline_rounded,
                  color: customer.isVip ? AppTheme.vipGold : AppTheme.textSecondary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customer.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (customer.isVip) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.vipGold,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'VIP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      customer.phone,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
