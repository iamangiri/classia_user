import 'package:flutter/material.dart';

class CustomerSupportScreen extends StatelessWidget {
  final List<Map<String, dynamic>> supportOptions = [
    {
      "title": "Live Chat",
      "icon": Icons.chat,
      "subtitle": "Chat with our support team immediately"
    },
    {
      "title": "Email Support",
      "icon": Icons.email,
      "subtitle": "Send us an email and we'll respond shortly"
    },
    {
      "title": "Call Support",
      "icon": Icons.call,
      "subtitle": "Reach our helpline 24/7"
    },
    {
      "title": "FAQs",
      "icon": Icons.help_outline,
      "subtitle": "Browse common questions and answers"
    },
    {
      "title": "Submit Feedback",
      "icon": Icons.feedback,
      "subtitle": "Help us improve by sharing your thoughts"
    },
    {
      "title": "Troubleshooting",
      "icon": Icons.build,
      "subtitle": "Resolve common issues with guided steps"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // White back icon
        backgroundColor: Colors.black,
        title: Text(
          "Customer Support",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How can we help you?",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Select one of the options below to get support:",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: supportOptions.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = supportOptions[index];
                return InkWell(
                  onTap: () {
                    // Navigate to detailed support option screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupportDetailScreen(
                          optionTitle: option["title"],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900]!.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[700]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(option["icon"],
                          color: Colors.white, size: 28),
                      title: Text(
                        option["title"],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      subtitle: Text(
                        option["subtitle"],
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 16),
                    ),
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
  final String optionTitle;
  const SupportDetailScreen({Key? key, required this.optionTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(optionTitle,
            style: TextStyle(color: Colors.white, fontSize: 22)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Details for $optionTitle",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
