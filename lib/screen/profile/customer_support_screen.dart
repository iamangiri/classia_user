import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

class CustomerSupportScreen extends StatefulWidget {
  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> supportOptions = [
    {
      'title': 'Live Chat',
      'icon': Icons.chat,
      'subtitle': 'Chat with our support team immediately',
      'responseTime': 'Instant',
      'contact': 'Start chat in-app',
      'action': 'startChat',
    },
    {
      'title': 'Email Support',
      'icon': Icons.email,
      'subtitle': 'Send us an email and we’ll respond shortly',
      'responseTime': 'Within 24 hours',
      'contact': 'support@jockeytrading.com',
      'action': 'sendEmail',
    },
    {
      'title': 'Call Support',
      'icon': Icons.call,
      'subtitle': 'Reach our helpline 24/7',
      'responseTime': 'Instant',
      'contact': '+91 123-456-7890',
      'action': 'makeCall',
    },
    {
      'title': 'FAQs',
      'icon': Icons.help_outline,
      'subtitle': 'Browse common questions and answers',
      'responseTime': 'Self-service',
      'contact': 'In-app FAQ section',
      'action': 'viewFAQs',
    },
    {
      'title': 'Submit Feedback',
      'icon': Icons.feedback,
      'subtitle': 'Help us improve by sharing your thoughts',
      'responseTime': 'Acknowledged within 48 hours',
      'contact': 'feedback@jockeytrading.com',
      'action': 'submitFeedback',
    },
    {
      'title': 'Troubleshooting',
      'icon': Icons.build,
      'subtitle': 'Resolve common issues with guided steps',
      'responseTime': 'Self-service',
      'contact': 'In-app guides',
      'action': 'viewTroubleshooting',
    },
  ];

  final List<Map<String, String>> quickTips = [
    {
      'title': 'App Not Loading?',
      'tip': 'Try restarting the app or checking your internet connection.',
    },
    {
      'title': 'Transaction Issues?',
      'tip': 'Verify your account details and ensure sufficient funds.',
    },
    {
      'title': 'Forgot Password?',
      'tip': 'Use the "Forgot Password" link on the login screen.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = supportOptions.where((option) {
      final title = option['title'].toLowerCase();
      final subtitle = option['subtitle'].toLowerCase();
      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Customer Support',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Can We Help You?',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select an option or search for support:',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search support options...',
                hintStyle: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.secondaryText,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Support Options',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            filteredOptions.isEmpty
                ? Center(
              child: Text(
                'No support options found',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16.sp,
                ),
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredOptions.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final option = filteredOptions[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupportDetailScreen(
                          option: option,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6.r,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      leading: Icon(
                        option['icon'],
                        color: AppColors.accent,
                        size: 28.sp,
                      ),
                      title: Text(
                        option['title'],
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      subtitle: Text(
                        option['subtitle'],
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14.sp,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primaryGold,
                        size: 16.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              'Quick Tips',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: quickTips.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final tip = quickTips[index];
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6.r,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title']!,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        tip['tip']!,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SupportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> option;

  const SupportDetailScreen({Key? key, required this.option}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String detailContent = '';
    Widget actionWidget = SizedBox.shrink();

    switch (option['action']) {
      case 'startChat':
        detailContent =
        'Connect with our support team instantly via live chat. Our agents are available 24/7 to assist with any issues or questions.';
        actionWidget = ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Live chat initiated'),
                backgroundColor: AppColors.primaryGold,
              ),
            );
            // Implement chat SDK integration
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Start Chat',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonText,
            ),
          ),
        );
        break;
      case 'sendEmail':
        detailContent =
        'Send us an email at ${option['contact']} and our team will respond within 24 hours. Please include details about your issue for faster resolution.';
        actionWidget = TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your message...',
            hintStyle: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
          ),
        );
        break;
      case 'makeCall':
        detailContent =
        'Call our 24/7 helpline at ${option['contact']} for immediate assistance. Our team is ready to help with any queries.';
        actionWidget = ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Calling support...'),
                backgroundColor: AppColors.primaryGold,
              ),
            );
            // Implement phone call integration
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Call Now',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonText,
            ),
          ),
        );
        break;
      case 'viewFAQs':
        detailContent = 'Browse our comprehensive FAQ section to find answers to common questions about trading, accounts, and more.';
        actionWidget = Column(
          children: [
            _buildFAQItem('How do I reset my password?', 'Use the "Forgot Password" link on the login screen.'),
            SizedBox(height: 8.h),
            _buildFAQItem('Why is my transaction pending?', 'Transactions may take up to 24 hours to process.'),
          ],
        );
        break;
      case 'submitFeedback':
        detailContent =
        'Share your feedback at ${option['contact']} to help us improve. We value your input and will acknowledge your message within 48 hours.';
        actionWidget = TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Type your feedback...',
            hintStyle: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 14.sp,
          ),
        );
        break;
      case 'viewTroubleshooting':
        detailContent =
        'Follow our guided steps to resolve common issues like app crashes, login problems, or transaction errors.';
        actionWidget = Column(
          children: [
            _buildTroubleshootingItem('App Crashing', 'Clear app cache or reinstall the app.'),
            SizedBox(height: 8.h),
            _buildTroubleshootingItem('Login Issues', 'Ensure correct credentials and stable internet.'),
          ],
        );
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: option['title'],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option['title'],
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Response Time: ${option['responseTime']}',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Contact: ${option['contact']}',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              detailContent,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            actionWidget,
            if (option['action'] == 'sendEmail' || option['action'] == 'submitFeedback') ...[
              SizedBox(height: 16.h),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${option['title']} submitted'),
                        backgroundColor: AppColors.primaryGold,
                      ),
                    );
                    // Implement email/feedback submission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            answer,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String issue, String solution) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issue,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            solution,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}