import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import '../../screenutills/support_list.dart';
import '../../service/apiservice/support_service.dart';

class CustomerSupportScreen extends StatefulWidget {
  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Map<String, dynamic>> supportOptions = [


    {
      'title': 'Email Support',
      'icon': Icons.email_outlined,
      'subtitle': 'Send detailed queries to our support team',
      'responseTime': 'Within 24 hours',
      'contact': 'support@classiacapital.com',
      'action': 'sendEmail',
      'priority': 'medium',
    },
    {
      'title': 'Phone Support',
      'icon': Icons.phone_outlined,
      'subtitle': 'Speak directly with our customer care team',
      'responseTime': 'Instant',
      'contact': '+91 98869 88679',
      'action': 'makeCall',
      'priority': 'high',
    },
    {
      'title': 'Investment FAQs',
      'icon': Icons.quiz_outlined,
      'subtitle': 'Browse mutual fund and investment queries',
      'responseTime': 'Self-service',
      'contact': 'Comprehensive FAQ section',
      'action': 'viewFAQs',
      'priority': 'medium',
    },
    {
      'title': 'Submit Feedback',
      'icon': Icons.rate_review_outlined,
      'subtitle': 'Share your experience and suggestions',
      'responseTime': 'Acknowledged within 48 hours',
      'contact': 'feedback@classiacapital.com',
      'action': 'submitFeedback',
      'priority': 'low',
    },
    {
      'title': 'Raise Support Ticket',
      'icon': Icons.support_outlined,
      'subtitle': 'Submit detailed investment-related queries',
      'responseTime': 'Within 24 hours',
      'contact': 'Secure ticket system',
      'action': 'createSupportTicket',
      'priority': 'medium',
    },
    {
      'title': 'My Support Tickets',
      'icon': Icons.assignment_outlined,
      'subtitle': 'Track your submitted queries and responses',
      'responseTime': 'Real-time updates',
      'contact': 'Personal ticket dashboard',
      'action': 'viewSupportTickets',
      'priority': 'medium',
    },
  ];

  final List<Map<String, String>> quickTips = [
    {
      'title': 'Investment Not Reflecting?',
      'tip': 'Mutual fund investments may take 1-3 business days to reflect in your portfolio.',
    },
    {
      'title': 'KYC Issues?',
      'tip': 'Ensure all documents are clear and match your PAN details exactly.',
    },
    {
      'title': 'Forgot Login Credentials?',
      'tip': 'Use "Forgot Password" or contact support for account recovery assistance.',
    },
    {
      'title': 'SIP Not Executed?',
      'tip': 'Check if you have sufficient bank balance and valid mandate setup.',
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

class SupportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> option;

  const SupportDetailScreen({Key? key, required this.option}) : super(key: key);

  @override
  _SupportDetailScreenState createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitSupportTicket() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in both title and description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await SupportService().createSupportTicket(
      _titleController.text,
      _descriptionController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Support ticket submitted successfully'),
          backgroundColor: AppColors.primaryGold,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit support ticket'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String detailContent = '';
    Widget actionWidget = SizedBox.shrink();

    switch (widget.option['action']) {
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
        'Send us an email at ${widget.option['contact']} and our team will respond within 24 hours. Please include details about your issue for faster resolution.';
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
        'Call our 24/7 helpline at ${widget.option['contact']} for immediate assistance. Our team is ready to help with any queries.';
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
        'Share your feedback at ${widget.option['contact']} to help us improve. We value your input and will acknowledge your message within 48 hours.';
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
      case 'createSupportTicket':
        detailContent =
        'Submit a support ticket with a title and detailed description of your issue. Our team will respond within 24 hours.';
        actionWidget = Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter ticket title...',
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
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter detailed description...',
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
            ),
            SizedBox(height: 16.h),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator(color: AppColors.primaryGold)
                  : ElevatedButton(
                onPressed: _submitSupportTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Submit Ticket',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ),
          ],
        );
        break;
      case 'viewSupportTickets':
        detailContent = 'View all your submitted support tickets and their statuses.';
        actionWidget = ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SupportTicketListScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'View Tickets',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonText,
            ),
          ),
        );
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: widget.option['title'],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.option['title'],
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Response Time: ${widget.option['responseTime']}',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Contact: ${widget.option['contact']}',
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
            if (widget.option['action'] == 'sendEmail' || widget.option['action'] == 'submitFeedback') ...[
              SizedBox(height: 16.h),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.option['title']} submitted'),
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
}