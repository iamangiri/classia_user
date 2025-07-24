import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';
import '../profile/add_bank_screen.dart';
import '../profile/kyc_screen.dart';


class HomePendingKycDialogBox extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String actionType;

  const HomePendingKycDialogBox({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.actionType,
  }) : super(key: key);

  Future<void> _updateBankDetailsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(UserConstants.BANK_DETAILS_KEY, 1);
    await UserConstants.loadUserData(); // Refresh UserConstants
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 16.h,
              right: 16.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container with gradient background
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold?.withOpacity(0.2) ?? Colors.amber.withOpacity(0.2),
                          AppColors.primaryGold?.withOpacity(0.05) ?? Colors.amber.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGold?.withOpacity(0.3) ?? Colors.amber.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        icon,
                        color: AppColors.primaryGold,
                        size: 32.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Title with improved typography
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12.h),

                  // Message with better spacing
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),

                  // Modern action button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGold ?? Colors.amber,
                            AppColors.primaryGold?.withOpacity(0.8) ?? Colors.amber.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: (AppColors.primaryGold ?? Colors.amber).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate based on actionType
                          if (actionType == 'KYC') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const KYCVerificationScreen(),
                              ),
                            );
                          } else if (actionType == 'Bank Details') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddBankScreen(
                                  onSave: (Map<String, String> bankData) {
                                    // Update UserConstants.BANK_DETAILS to indicate completion
                                    _updateBankDetailsStatus();
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Complete Now',
                              style: TextStyle(
                                color: AppColors.buttonText,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18.sp,
                              color: AppColors.buttonText,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}