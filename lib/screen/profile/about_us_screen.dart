import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utills/themes/light_app_theme.dart';
import '../../widget/common_app_bar.dart';
import '../main/profile_screen.dart';

class AboutUsScreen extends StatelessWidget {
  final bool showBackButton;

  const AboutUsScreen({
    Key? key,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CommonAppBar(title: 'About Us'),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyHeader(),
            SizedBox(height: 24),
            _buildMissionVision(),
            SizedBox(height: 24),
            _buildWhyChooseUs(context),
            SizedBox(height: 24),
            _buildServicesSection(),
            SizedBox(height: 24),
            _buildRegulatoryInfo(),
            SizedBox(height: 24),
            _buildContactSection(context),
            SizedBox(height: 24),
            _buildCallToAction(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
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
      child: Column(
        children: [
          // Logo Container
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo/logo.jpg',
              width: 140,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 140,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppTheme.lightTheme.primaryColor,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            'MFD Classia Capital Private Limited',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your Trusted Investment Partner',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionVision() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Mission & Vision",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            "Welcome to Classia Capital",
            "At Classia Capital, we specialize in making wealth creation accessible to everyone through our comprehensive Asset Management Company (AMC) platform. Our innovative approach combines cutting-edge technology with deep financial expertise to provide you with seamless investment opportunities in mutual funds and financial markets.",
            FontAwesomeIcons.handshake,
            Colors.blue,
          ),
          SizedBox(height: 12),
          _buildInfoCard(
            "Our Vision",
            "Our mission is to democratize wealth creation by providing world-class investment solutions that are simple, transparent, and accessible to all investors. We envision a future where every individual has the tools and knowledge to build long-term wealth through smart investment strategies.",
            FontAwesomeIcons.bullseye,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Why Choose Us?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildBenefitTile(
            "SEBI Registered & Compliant",
            "Fully regulated Asset Management Company ensuring your investments are safe and secure",
            FontAwesomeIcons.shieldHalved,
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildBenefitTile(
            "Professional Fund Management",
            "Expert fund managers with years of experience in Indian capital markets",
            FontAwesomeIcons.chartLine,
            Colors.blue,
          ),
          SizedBox(height: 12),
          _buildBenefitTile(
            "User-Friendly Platform",
            "Intuitive mobile app and web platform for seamless investment experience",
            FontAwesomeIcons.mobileScreen,
            Colors.purple,
          ),
          SizedBox(height: 12),
          _buildBenefitTile(
            "Real-time Portfolio Tracking",
            "Monitor your investments with detailed analytics and performance reports",
            FontAwesomeIcons.chartPie,
            Colors.orange,
          ),
          SizedBox(height: 12),
          _buildBenefitTile(
            "Dedicated Customer Support",
            "Professional support team to assist you with all your investment queries",
            FontAwesomeIcons.headset,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitTile(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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

  Widget _buildServicesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Investment Solutions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(18),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(FontAwesomeIcons.briefcase,
                          color: Colors.indigo, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Comprehensive Portfolio",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  "We offer a comprehensive range of mutual fund schemes designed to meet diverse investment objectives. From equity funds for growth-oriented investors to debt funds for conservative investors, our portfolio includes carefully curated investment options managed by experienced fund managers with proven track records.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegulatoryInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
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
              FaIcon(FontAwesomeIcons.certificate,
                  color: Colors.green[700], size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Regulatory Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Classia Capital Private Limited is registered with the Securities and Exchange Board of India (SEBI) as an Asset Management Company. All our schemes are designed to comply with SEBI regulations and guidelines, ensuring complete transparency and investor protection.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Get in Touch",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildContactOption(
            context,
            "Address",
            "58, 2nd Cross Rd, Chowdiah Block, Mannarayanapalya\nChamundi Nagar, RT Nagar, Bengaluru, Karnataka 560032",
            FontAwesomeIcons.locationDot,
            Colors.red,
            null,
          ),
          _buildContactOption(
            context,
            "Email Support",
            "support@classiacapital.com",
            FontAwesomeIcons.envelope,
            Colors.orange,
                () => _openEmail(context),
          ),
          _buildContactOption(
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

  Widget _buildContactOption(BuildContext context, String title,
      String subtitle, IconData icon, Color color, VoidCallback? onTap) {
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ),
        trailing: onTap != null
            ? Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(FontAwesomeIcons.angleRight,
              size: 16, color: Colors.grey[600]),
        )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(FontAwesomeIcons.rocket,
                color: Colors.blue[700], size: 28),
          ),
          SizedBox(height: 16),
          Text(
            'Start Your Investment Journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Join thousands of investors who trust Classia Capital for their wealth creation journey. Start investing today with our professionally managed mutual fund schemes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final String email = 'support@classiacapital.com';
    final String subject = 'Inquiry';
    final String body = 'Hello Classia Capital Team,\n\n';

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
              'No email app found. Copy our email address:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
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
              child: Text('Email copied to clipboard!'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 2),
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