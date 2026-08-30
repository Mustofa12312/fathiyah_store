import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerListLoading extends StatelessWidget {
  final int itemCount;
  
  const ShimmerListLoading({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.h,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 100.w,
                          height: 12.h,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
