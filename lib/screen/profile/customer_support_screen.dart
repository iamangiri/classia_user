import 'package:classia_amc/screen/profile/support/create_ticket_screen.dart';
import 'package:classia_amc/screen/profile/support/ticket_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utills/themes/light_app_theme.dart';
import '../main/profile_screen.dart';

class CustomerSupportScreen extends StatelessWidget {
  final bool showBackButton;

  const CustomerSupportScreen({
    Key? key,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Support", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        )
            : IconButton(
          icon: FaIcon(FontAwesomeIcons.userCircle,
              color: Colors.white, size: 22),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportHeader(),
            SizedBox(height: 24),
            _buildQuickActions(context),
            SizedBox(height: 24),
            _buildFAQsSection(),
            SizedBox(height: 24),
            _buildSupportOptions(context),
            SizedBox(height: 24),
            _buildHelpCenter(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
            FaIcon(FontAwesomeIcons.headset, size: 24, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How can we help you?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We're here to assist you 24/7",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  "Create Ticket",
                  "Report an issue",
                  FontAwesomeIcons.plus,
                  Colors.blue,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateTicketScreen()),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  "My Tickets",
                  "View your tickets",
                  FontAwesomeIcons.ticket,
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TicketListScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title,
      String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildFAQTile(
              "Can I create multiple investment baskets?",
              "Yes, Classia Capital allows you to create unlimited baskets for managing your SIP and lumpsum investments efficiently."
          ),

          _buildFAQTile(
              "Can I edit or change the stocks in a basket anytime?",
              "Absolutely. You can securely add, remove, or update the stocks in any basket whenever needed."
          ),

          _buildFAQTile(
              "Will my basket changes update instantly?",
              "Yes, all changes made to your basket—stocks, amounts, or strategy—are updated instantly and reflected in your portfolio performance."
          ),

          _buildFAQTile(
              "Can I deactivate a basket after creating it?",
              "Yes, you can deactivate any basket at any time. A deactivated basket stays secure and won’t affect your active investments."
          ),

          _buildFAQTile(
              "Does the app support SIP, lumpsum, and KYC?",
              "Yes, Classia Capital includes modern KYC, SIP setup, lumpsum investing, and secure basket management for a seamless investment experience."
          ),

          _buildFAQTile(
              "Can I check the live performance of my baskets?",
              "Yes, you can track real-time performance of all your baskets, including gains, allocation, and market movements."
          ),

        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Support",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildSupportOption(
            context,
            "Email Support",
            "contact@classiacapital.com",
            FontAwesomeIcons.envelope,
            Colors.orange,
                () => _openEmail(context),
          ),
          _buildSupportOption(
            context,
            "Call Support",
            "+91 98869 88679",
            FontAwesomeIcons.phone,
            Colors.green,
                () => _makePhoneCall(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context, String title,
      String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(FontAwesomeIcons.angleRight,
              size: 16, color: Colors.grey[600]),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHelpCenter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.lightbulb,
                  color: Colors.blue[600], size: 20),
              SizedBox(width: 8),
              Text(
                "Need Further Assistance?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Our dedicated support team is available 24/7 to assist you with any questions or concerns. Don't hesitate to reach out - we're here to help!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final String email = 'contact@classiacapital.com';
    final String subject = 'Support Request';
    final String body = 'Hello Classia Capital Support Team,\n\n';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
      'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      final bool canLaunch = await canLaunchUrl(emailUri);

      if (canLaunch) {
        final bool launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          _showEmailOptionsDialog(context, email);
        }
      } else {
        _showEmailOptionsDialog(context, email);
      }
    } catch (e) {
      print('Error launching email: $e');
      _showEmailOptionsDialog(context, email);
    }
  }

  void _showEmailOptionsDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.envelope, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('Contact via Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No email app found. You can:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(
              '1. Copy our email address and use your preferred email app',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.copy,
                        size: 16, color: Colors.blue[700]),
                    onPressed: () {
                      _copyToClipboard(context, email);
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              '2. Or use the ticket system for support',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateTicketScreen()),
              );
            },
            icon: FaIcon(FontAwesomeIcons.ticket, size: 14),
            label: Text('Create Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text('Email copied to clipboard: $text'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context) async {
    final String phoneNumber = '+919886988679';
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(
          context,
          'Cannot Make Call',
          'Unable to open phone app. Please call us at: +91 98869 88679',
        );
      }
    } catch (e) {
      _showErrorDialog(
        context,
        'Error',
        'Failed to open phone app. Please try again or call us at: +91 98869 88679',
      );
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.exclamationTriangle,
                color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}