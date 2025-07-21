import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  _SecuritySettingsScreenState createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _is2FAEnabled = false;
  bool _isDarkModeEnabled = false;

  final List<Map<String, dynamic>> securityOptions = [
    {
      'title': '2FA',
      'subtitle': 'Enable two-factor authentication for extra security',
      'icon': Icons.verified_user,
      'isToggle': true,
      'toggleValue': false, // Updated via _is2FAEnabled
    },
    {
      'title': 'Change Password',
      'subtitle': 'Update your account password',
      'icon': Icons.lock_outline,
      'isToggle': false,
    },
    {
      'title': 'Change Phone Number',
      'subtitle': 'Update your registered phone number',
      'icon': Icons.phone,
      'isToggle': false,
    },
    {
      'title': 'Notification Settings',
      'subtitle': 'Manage push and email notifications',
      'icon': Icons.notifications,
      'isToggle': false,
    },
    {
      'title': 'Dark Mode',
      'subtitle': 'Switch between light and dark themes',
      'icon': Icons.dark_mode,
      'isToggle': true,
      'toggleValue': false, // Updated via _isDarkModeEnabled
    },
    {
      'title': 'Clear Cache',
      'subtitle': 'Free up storage by clearing cached data',
      'icon': Icons.delete_outline,
      'isToggle': false,
    },
    {
      'title': 'Delete My Account',
      'subtitle': 'Request account deletion via our website',
      'icon': Icons.delete_forever,
      'isToggle': false,
    },

    {
      'title': 'Biometric Login',
      'subtitle': 'Enable fingerprint or face ID login',
      'icon': Icons.fingerprint,
      'isToggle': true,
      'toggleValue': false,
    },
  ];

  void _toggleOption(String title, bool value) {
    setState(() {
      if (title == '2FA') {
        _is2FAEnabled = value;
        securityOptions[0]['toggleValue'] = value;
      } else if (title == 'Dark Mode') {
        _isDarkModeEnabled = value;
        securityOptions[4]['toggleValue'] = value;
      } else if (title == 'Biometric Login') {
        securityOptions[7]['toggleValue'] = value;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title ${value ? 'enabled' : 'disabled'}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          'Clear Cache',
          style: TextStyle(color: AppColors.primaryText, fontSize: 18.sp),
        ),
        content: Text(
          'Clearing the cache will free up approximately 125 MB of storage. This will not affect your account data.',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.primaryGold, fontSize: 14.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.error, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Security Settings'),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: securityOptions.length + 1, // +1 for comparison section
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == securityOptions.length) {
            return _buildComparisonSection();
          }
          final option = securityOptions[index];
          return InkWell(
            onTap: option['isToggle']
                ? null
                : () {
              switch (option['title']) {
                case 'Notification Settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
                  );
                  break;
                case 'Clear Cache':
                  _showClearCacheDialog(context);
                  break;
                case '2FA':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TwoFactorAuthScreen()),
                  );
                  break;
                case 'Change Password':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                  );
                  break;
                case 'Change Phone Number':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePhoneNumberScreen()),
                  );
                  break;
                  case 'Delete My Account':
                launchUrl(Uri.parse('https://classiacapital.com/contact'), mode: LaunchMode.externalApplication);
                break;
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: Icon(
                  option['icon'],
                  color: AppColors.primaryGold,
                  size: 24.sp,
                ),
                title: Text(
                  option['title'],
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  option['subtitle'],
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14.sp,
                  ),
                ),
                trailing: option['isToggle']
                    ? Switch(
                  value: option['title'] == '2FA'
                      ? _is2FAEnabled
                      : option['title'] == 'Dark Mode'
                      ? _isDarkModeEnabled
                      : option['toggleValue'],
                  activeColor: AppColors.primaryGold,
                  onChanged: (value) => _toggleOption(option['title'], value),
                )
                    : Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.secondaryText,
                  size: 16.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Features Comparison',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          _buildComparisonItem(
            '2FA',
            'High security with OTP or authenticator app',
            '5 min setup, moderate effort',
            Icons.verified_user,
          ),
          _buildComparisonItem(
            'Strong Password',
            'Prevents unauthorized access',
            '2 min setup, low effort',
            Icons.lock_outline,
          ),
          _buildComparisonItem(
            'Biometric Login',
            'Fast and secure with fingerprint/face ID',
            '1 min setup, low effort',
            Icons.fingerprint,
          ),
          _buildComparisonItem(
            'Delete My Account',
            'Allows users to request account deletion via the website',
            'Instant request, low effort',
            Icons.delete_forever,
          ),

        ],
      ),
    );
  }

  Widget _buildComparisonItem(String title, String benefit, String effort, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Benefit: $benefit',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                ),
                Text(
                  'Effort: $effort',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Updated Destination Screens (Light Mode)

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Notification Settings'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Notifications',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            _buildToggleOption('Push Notifications', true),
            _buildToggleOption('Email Notifications', false),
            _buildToggleOption('SMS Notifications', true),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title, bool value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
      ),
      trailing: Switch(
        value: value,
        activeColor: AppColors.primaryGold,
        onChanged: (newValue) {
          // Handle toggle
        },
      ),
    );
  }
}

class DarkModeScreen extends StatelessWidget {
  const DarkModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Dark Mode'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Settings',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              ),
              trailing: Switch(
                value: false,
                activeColor: AppColors.primaryGold,
                onChanged: (newValue) {
                  // Handle theme change
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TwoFactorAuthScreen extends StatelessWidget {
  const TwoFactorAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Two-Factor Authentication'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Up 2FA',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Enable 2FA via SMS or authenticator app for enhanced security.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Handle 2FA setup
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: Text(
                'Enable 2FA',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Change Password'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Password',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              obscureText: true,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter current password',
                labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                filled: true,
                fillColor: AppColors.cardBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primaryGold),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              obscureText: true,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new password',
                labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                filled: true,
                fillColor: AppColors.cardBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primaryGold),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Handle password change logic here

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: Text(
                'Update Password',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePhoneNumberScreen extends StatelessWidget {
  const ChangePhoneNumberScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Change Phone Number'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Phone Number',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              keyboardType: TextInputType.phone,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              decoration: InputDecoration(
                labelText: 'New Phone Number',
                hintText: 'Enter 10-digit phone number',
                labelStyle: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
                hintStyle: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                filled: true,
                fillColor: AppColors.cardBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primaryGold),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Handle phone number change
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: Text(
                'Update Phone Number',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionManagementScreen extends StatelessWidget {
  const SessionManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(title: 'Session Management'),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Sessions',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              title: Text(
                'iPhone 14 - Active',
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              ),
              subtitle: Text(
                'Last login: 2025-04-24',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
              ),
              trailing: TextButton(
                onPressed: () {
                  // Terminate session
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Windows PC',
                style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
              ),
              subtitle: Text(
                'Last login: 2025-04-20',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
              ),
              trailing: TextButton(
                onPressed: () {
                  // Terminate session
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}