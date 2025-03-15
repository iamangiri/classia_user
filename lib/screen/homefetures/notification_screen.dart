import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  // Dummy notifications data
  final List<Map<String, String>> notifications = [
    {
      "title": "Market Update",
      "message": "Trade market is reaching new highs today.",
      "date": "2025-03-10 09:30"
    },
    {
      "title": "Deposit Successful",
      "message": "Your deposit of ₹5,000 has been credited.",
      "date": "2025-03-09 15:45"
    },
    {
      "title": "New Feature Alert",
      "message": "Check out our new investment features in the app.",
      "date": "2025-03-08 12:00"
    },
    {
      "title": "Withdrawal Processed",
      "message": "Your withdrawal request has been processed.",
      "date": "2025-03-07 16:20"
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
          "Notifications",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Icon(Icons.notifications, size: 30, color: Colors.white),
              title: Text(
                notification["title"]!,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    notification["message"]!,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 6),
                  Text(
                    notification["date"]!,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
