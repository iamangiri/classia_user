import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utills/constent/user_constant.dart';
import '../../utills/themes/light_app_theme.dart';
import 'customer_support_screen.dart';


class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({Key? key}) : super(key: key);

  @override
  _ProfileDetailsScreenState createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomerSupportScreen(showBackButton:true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.screenBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Avatar Section
                    _buildProfileAvatarSection(),
                    SizedBox(height: 24.h),

                    // Info Banner
                    _buildInfoBanner(),
                    SizedBox(height: 24.h),

                    // Personal Information Section
                    _buildSectionCard(
                      title: 'Personal Information',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _buildDetailItem(
                          label: "Full Name",
                          value: UserConstants.NAME,
                          icon: Icons.badge_outlined,
                        ),
                        _buildDetailItem(
                          label: "Email Address",
                          value: UserConstants.EMAIL,
                          icon: Icons.email_outlined,
                          isVerified: UserConstants.IS_EMAIL_VERIFIED ?? false,
                        ),
                        _buildDetailItem(
                          label: "Phone Number",
                          value: UserConstants.PHONE,
                          icon: Icons.phone_outlined,
                          isVerified: UserConstants.IS_MOBILE_VERIFIED ?? false,
                          isLast: true,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),




                    // KYC Status Section
                    _buildSectionCard(
                      title: 'KYC Verification',
                      icon: Icons.verified_user_outlined,
                      children: [
                        _buildKYCStatusCard(
                          label: "Aadhaar Card",
                          description: "Government ID verification",
                          isVerified: UserConstants.IS_AADHAAR_VERIFIED ?? false,
                          icon: Icons.credit_card_rounded,
                        ),
                        SizedBox(height: 12.h),
                        _buildKYCStatusCard(
                          label: "PAN Card",
                          description: UserConstants.maskedPAN.isNotEmpty
                              ? UserConstants.maskedPAN
                              : "Tax identification",
                          isVerified: UserConstants.IS_PAN_VERIFIED ?? false,
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ],
                    ),

                    SizedBox(height: 28.h),

                    // Contact Support Button
                    _buildContactSupportButton(),

                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryDarkBlue,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18.sp),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryDarkBlue,
                AppTheme.primaryDarkBlue.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30.w,
                top: -30.h,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                left: -20.w,
                bottom: -40.h,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGold.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatarSection() {
    return Center(
      child: Column(
        children: [
          // Avatar without camera icon
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryGold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardBackground,
              ),
              child: Center(
                child: Text(
                  _getInitials(),
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDarkBlue,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            UserConstants.NAME.isNotEmpty ? UserConstants.NAME : 'User',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            UserConstants.EMAIL.isNotEmpty ? UserConstants.EMAIL : 'No email',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppTheme.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Active Account',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    if (UserConstants.NAME.isEmpty) return 'U';
    final names = UserConstants.NAME.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDarkBlue.withOpacity(0.05),
            AppTheme.primaryGold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryGold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primaryGold,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need to update your profile?',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Please contact our support team for any profile changes.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppTheme.lightBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDarkBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryDarkBlue,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    bool isVerified = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGold,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      value.isNotEmpty ? value : 'Not provided',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: value.isNotEmpty
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.successGreen,
                        AppTheme.successGreen.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: AppTheme.border.withOpacity(0.5),
            height: 1,
          ),
      ],
    );
  }

  Widget _buildKYCStatusCard({
    required String label,
    required String description,
    required bool isVerified,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: isVerified
            ? LinearGradient(
          colors: [
            AppTheme.successGreen.withOpacity(0.05),
            AppTheme.successGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isVerified ? null : AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isVerified
              ? AppTheme.successGreen.withOpacity(0.3)
              : AppTheme.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppTheme.successGreen.withOpacity(0.15)
                  : AppTheme.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              icon,
              color: isVerified ? AppTheme.successGreen : AppTheme.textSecondary,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: isVerified
                  ? LinearGradient(
                colors: [
                  AppTheme.successGreen,
                  AppTheme.successGreen.withOpacity(0.8),
                ],
              )
                  : LinearGradient(
                colors: [
                  AppTheme.warningOrange,
                  AppTheme.warningOrange.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: (isVerified ? AppTheme.successGreen : AppTheme.warningOrange)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  isVerified ? 'Verified' : 'Pending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportButton() {
    return GestureDetector(
      onTap: _navigateToSupport,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryDarkBlue,
              AppTheme.primaryDarkBlue.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDarkBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: AppTheme.primaryGold,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Get help with profile updates & more',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.primaryGold,
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}