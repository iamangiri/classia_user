import 'package:classia_amc/screen/homefetures/withdraw_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colors.dart';
import '../profile/about_us_screen.dart';
import '../profile/bank_info_screen.dart';
import '../profile/customer_support_screen.dart';
import '../homefetures/investment_history_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/kyc_screen.dart';
import '../profile/learn_screen.dart';
import '../profile/manage_folio_screen.dart';
import '../profile/privicy_policy.dart';
import '../profile/security_setting _screen.dart';


class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground, // Light background (e.g., white)
      appBar: AppBar(
        backgroundColor: AppColors.primaryGold, // Gold for branding
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText, // Dark text for contrast
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(context),
            SizedBox(height: 20),
            // Account Section
            _buildSectionTitle("Account"),
            _buildAccountOptionsList(context),
            SizedBox(height: 20),
            // Preferences Section
            _buildSectionTitle("Preferences"),
            _buildPreferencesList(context),
            SizedBox(height: 20),
            // Logout Section
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // Profile section with Avatar and Edit button
  Widget _buildProfileSection(BuildContext context) {
    String userName = "Aman Giri"; // Replace with actual username
    String userEmail = "aman@trader.com"; // Replace with actual email

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.border, // Light border color
          child: Text(
            userName[0], // Show first letter of user's name
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText, // Dark text for contrast
            ),
          ),
        ),
        SizedBox(width: 16),
        // User Name and Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText, // Dark text
              ),
            ),
            SizedBox(height: 4),
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText, // Lighter secondary text
              ),
            ),
          ],
        ),
        Spacer(),
        // Edit Icon
        IconButton(
          icon: Icon(Icons.edit, color: AppColors.accent), // Accent color for edit
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.headingText, // Darker heading text
        ),
      ),
    );
  }

  // List of account-related options
  Widget _buildAccountOptionsList(BuildContext context) {
    List<Map<String, String>> accountOptions = [
      {"title": "KYC", "icon": "verified_user"},
      {"title": "Manage Folio", "icon": "folio"},
      {"title": "Security Settings", "icon": "security"},
      {"title": "Bank Info", "icon": "account_balance"},
      {"title": "Learn", "icon": "school"},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: accountOptions.length,
      itemBuilder: (context, index) {
        return _buildOptionItem(context, accountOptions[index]);
      },
    );
  }

  // List of preference-related options
  Widget _buildPreferencesList(BuildContext context) {
    List<Map<String, String>> preferenceOptions = [
      {"title": "About Us", "icon": "info"},
      {"title": "Help Center", "icon": "help"},
      {"title": "Privacy Policy", "icon": "privacy"},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: preferenceOptions.length,
      itemBuilder: (context, index) {
        return _buildOptionItem(context, preferenceOptions[index]);
      },
    );
  }

  // Individual option item with an icon and title
  Widget _buildOptionItem(BuildContext context, Map<String, String> option) {
    IconData iconData;
    switch (option['icon']) {
      case 'history':
        iconData = Icons.history;
        break;
      case 'folio':
        iconData = Icons.folder_open;
        break;
      case 'security':
        iconData = Icons.security;
        break;
      case 'verified_user':
        iconData = Icons.verified_user;
        break;
      case 'account_balance':
        iconData = Icons.account_balance;
        break;
      case 'school':
        iconData = Icons.school;
        break;
      case 'notifications':
        iconData = Icons.notifications;
        break;
      case 'info':
        iconData = Icons.info;
        break;
      case 'help':
        iconData = Icons.help;
        break;
      case 'privacy':
        iconData = Icons.privacy_tip;
        break;
      default:
        iconData = Icons.help;
    }

    return InkWell(
      onTap: () {
        _navigateToOption(context, option['title']!);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor, // Light card background
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(iconData, color: AppColors.primaryText), // Dark icons
          title: Text(
            option['title']!,
            style: TextStyle(fontSize: 16, color: AppColors.primaryText),
          ),
        ),
      ),
    );
  }

  // Navigation logic based on option title
  void _navigateToOption(BuildContext context, String optionTitle) {
    Widget destination;
    switch (optionTitle) {
      case 'Manage Folio':
        destination = ManageFolioScreen();
        break;
      case 'Investment History':
        destination = InvestmentHistoryScreen();
        break;
      case 'Withdrawals':
        destination = WithdrawScreen();
        break;
      case 'Security Settings':
        destination = SecuritySettingsScreen();
        break;
      case 'KYC':
        destination = KYCVerificationScreen();
        break;
      case 'Bank Info':
        destination = BankInfoScreen();
        break;
      case 'Learn':
        destination = LearnScreen();
        break;
      case 'About Us':
        destination = AboutUsScreen();
        break;
      case 'Help Center':
        destination = CustomerSupportScreen();
        break;
      case 'Privacy Policy':
        destination = PrivacyPolicyScreen();
        break;
      default:
        destination = Scaffold(
          appBar: AppBar(
            title: Text(optionTitle),
            backgroundColor: AppColors.primaryGold,
          ),
          backgroundColor: AppColors.screenBackground,
          body: Center(
            child: Text('Screen for $optionTitle',
                style: TextStyle(color: AppColors.primaryText)),
          ),
        );
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
  }

  // Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.goNamed('splash');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error, // Error color for logout
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Logout",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonText, // Light text on button
          ),
        ),
      ),
    );
  }
}