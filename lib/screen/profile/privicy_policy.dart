import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utills/themes/light_app_theme.dart';
import '../main/profile_screen.dart';
import 'customer_support_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool showBackButton;

  const PrivacyPolicyScreen({
    Key? key,
    this.showBackButton = true,
  }) : super(key: key);

  final List<Map<String, dynamic>> policySections = const [
    {
      'title': 'Introduction',
      'icon': FontAwesomeIcons.circleInfo,
      'color': Colors.blue,
      'content':
      'Classia Capital Private Limited ("we," "our," or "us") operates the Classia AMC mobile application and website (the "Service"). This Privacy Policy informs you of our policies regarding the collection, use, and disclosure of personal data when you use our Service and the choices you have associated with that data.',
    },
    {
      'title': 'Information We Collect',
      'icon': FontAwesomeIcons.database,
      'color': Colors.purple,
      'content':
      'We collect personal information including your name, email, phone number, date of birth, PAN and Aadhaar details for KYC compliance, bank account details, investment preferences, and financial information. We also automatically collect device information, IP address, app usage statistics, location data (with permission), and use cookies for enhanced user experience.',
    },
    {
      'title': 'How We Use Your Information',
      'icon': FontAwesomeIcons.gear,
      'color': Colors.orange,
      'content':
      'Your information is used for providing investment services, processing transactions, managing your portfolio, KYC verification, regulatory compliance, customer support, service improvements, marketing activities (with consent), and fraud prevention.',
    },
    {
      'title': 'Information Sharing and Disclosure',
      'icon': FontAwesomeIcons.shareNodes,
      'color': Colors.teal,
      'content':
      'We may share your information with Asset Management Companies (AMCs), Registrar and Transfer Agents (RTAs), payment processors, banks, KYC verification agencies, regulatory authorities (SEBI, RBI), service providers, business partners, and legal authorities when required by law.',
    },
    {
      'title': 'Data Security',
      'icon': FontAwesomeIcons.shield,
      'color': Colors.green,
      'content':
      'We implement SSL encryption for data transmission, secure servers and databases, regular security audits, access controls and authentication, and employee training on data protection to safeguard your personal information from unauthorized access, loss, or misuse.',
    },
    {
      'title': 'Data Retention',
      'icon': FontAwesomeIcons.clock,
      'color': Colors.indigo,
      'content':
      'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. Investment records are maintained as per SEBI guidelines (typically 8 years).',
    },
    {
      'title': 'Your Rights',
      'icon': FontAwesomeIcons.userCheck,
      'color': Colors.cyan,
      'content':
      'You have the right to access your personal information, correct inaccurate data, request deletion of your data (subject to legal requirements), withdraw consent for marketing communications, data portability, and file complaints with data protection authorities.',
    },
    {
      'title': 'Cookies and Tracking',
      'icon': FontAwesomeIcons.cookie,
      'color': Colors.brown,
      'content':
      'Our app and website use cookies and similar technologies to enhance user experience, analyze usage, and provide personalized content. You can manage cookie preferences through your device settings.',
    },
    {
      'title': 'Third-Party Services',
      'icon': FontAwesomeIcons.link,
      'color': Colors.deepPurple,
      'content':
      'Our app may contain links to third-party services. We are not responsible for the privacy practices of these external services. Please review their privacy policies before providing any information.',
    },
    {
      'title': 'Children\'s Privacy',
      'icon': FontAwesomeIcons.child,
      'color': Colors.pink,
      'content':
      'Our services are not intended for individuals under 18 years of age. We do not knowingly collect personal information from children under 18.',
    },
    {
      'title': 'International Data Transfers',
      'icon': FontAwesomeIcons.globe,
      'color': Colors.blueAccent,
      'content':
      'Your information may be transferred to and processed in countries other than India. We ensure appropriate safeguards are in place for such transfers.',
    },
    {
      'title': 'Regulatory Compliance',
      'icon': FontAwesomeIcons.gavel,
      'color': Colors.redAccent,
      'content':
      'This Privacy Policy complies with Information Technology Act, 2000 and Rules, SEBI (Investment Advisers) Regulations, 2013, RBI guidelines on data protection, and Google Play Store and Apple App Store policies.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy", style: TextStyle(color: Colors.white)),
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

            SizedBox(height: 24),
            _buildLastUpdated(),
            SizedBox(height: 24),
            _buildPolicySections(),
            SizedBox(height: 24),
            _buildContactSection(context),
            SizedBox(height: 24),
            _buildAcknowledgment(),
            SizedBox(height: 24),
            _buildSupportButton(context),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyHeader() {
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
            child: FaIcon(
              FontAwesomeIcons.shieldHalved,
              size: 48,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your Privacy Matters to Us',
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

  Widget _buildLastUpdated() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(
                FontAwesomeIcons.calendarDays,
                color: Colors.blue[700],
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Updated',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'January 2024',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
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

  Widget _buildPolicySections() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Privacy Policy Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: policySections.length,
            itemBuilder: (context, index) {
              final section = policySections[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _buildPolicyCard(
                  section['title']!,
                  section['content']!,
                  section['icon']!,
                  section['color']!,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(
      String title, String content, IconData icon, Color color) {
    return Container(
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
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(icon, color: color, size: 18),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          iconColor: color,
          collapsedIconColor: Colors.grey[600],
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
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
            "Contact Us",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(20),
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FaIcon(FontAwesomeIcons.buildingColumns,
                          color: Colors.blue, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Classia Capital Private Limited",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildContactItem(
                  FontAwesomeIcons.locationDot,
                  "Address",
                  "58, 2nd Cross Rd, Chowdiah Block, Mannarayanapalya\nChamundi Nagar, RT Nagar, Bengaluru, Karnataka 560032",
                  Colors.red,
                ),
                SizedBox(height: 12),
                _buildContactItem(
                  FontAwesomeIcons.envelope,
                  "Email",
                  "privacy@classiacapital.com",
                  Colors.orange,
                ),
                SizedBox(height: 12),
                _buildContactItem(
                  FontAwesomeIcons.phone,
                  "Phone",
                  "+91 98869 88679",
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, color: color, size: 14),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcknowledgment() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[50]!, Colors.amber[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.circleCheck,
              color: Colors.amber[700], size: 32),
          SizedBox(height: 12),
          Text(
            'Acknowledgment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'By using our services, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerSupportScreen(showBackButton: true),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.headset, color: Colors.white, size: 18),
              SizedBox(width: 12),
              Text(
                'Contact Customer Support',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}