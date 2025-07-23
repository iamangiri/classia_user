import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';
import '../../utills/constent/home_screen_data.dart';

class HomeFeaturesWidget extends StatelessWidget {
  final Function(String title, BuildContext context) onFeatureTap;

  const HomeFeaturesWidget({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: HomeScreenData.features.map((feature) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: InkWell(
              onTap: () => onFeatureTap(feature['title']!, context),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (feature['color'] as Color).withOpacity(0.3),
                          spreadRadius: 2,

                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: FaIcon(
                      feature['icon'] as IconData,
                      size: 28,
                      color: feature['color'] as Color,
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Text(
                    feature['title']!,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
