import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // White back icon
        backgroundColor: Colors.black,
        title: Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Last Updated: March 15, 2025",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 24),
            // Introduction Section
            _buildSectionHeading("Introduction"),
            _buildSectionContent(
                "At Jockey Trading, your privacy is our priority. We are committed to protecting your personal information and ensuring transparency about how we collect, use, and store your data."),
            SizedBox(height: 16),
            // Data Collection Section
            _buildSectionHeading("Data Collection"),
            _buildSectionContent(
                "We collect information that you provide directly to us when you register, use our services, or communicate with our support team. This may include your name, email, phone number, and financial details."),
            SizedBox(height: 16),
            // Data Usage Section
            _buildSectionHeading("Data Usage"),
            _buildSectionContent(
                "Your data is used to enhance your trading experience, process transactions, and provide personalized services. We also use your information to communicate with you about account updates, promotions, and important security notifications."),
            SizedBox(height: 16),
            // Third Party Services Section
            _buildSectionHeading("Third Party Services"),
            _buildSectionContent(
                "We may share your information with trusted third-party service providers who assist us in operating our platform, subject to strict confidentiality obligations. These partners do not have independent rights to use your data."),
            SizedBox(height: 16),
            // Your Rights Section
            _buildSectionHeading("Your Rights"),
            _buildSectionContent(
                "You have the right to access, update, and delete your personal data. If you wish to exercise any of these rights, please contact our support team."),
            SizedBox(height: 16),
            // Contact Information Section
            _buildSectionHeading("Contact Information"),
            _buildSectionContent(
                "If you have any questions or concerns regarding our Privacy Policy, please contact us at privacy@jockeytrading.com."),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String heading) {
    return Text(
      heading,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        height: 1.5,
      ),
    );
  }
}
