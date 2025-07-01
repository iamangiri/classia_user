import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../themes/app_colors.dart';
import '../profile/learn_screen.dart';

class HomeCertificateSection extends StatelessWidget {
  const HomeCertificateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210.h,
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage('assets/images/certificate_bg.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lock Icon
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.lock,
                    color: AppColors.primaryGold,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),

                // Text + Button
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Your Certificate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Complete to unlock and get ₹1000',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 16.w,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LearnScreen()),
                          );
                        },

                        child: Text(
                          'Unlock Now',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
