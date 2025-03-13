import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          backgroundColor: Colors.grey,
          child: Text(
            userName[0], // Show first letter of user's name
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(width: 16),
        // User Name and Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
            SizedBox(height: 4),
            Text(userEmail,
                style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
        Spacer(),
        // Edit Icon
        IconButton(
          icon: Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // Handle edit action here (e.g., navigate to edit profile page)
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
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // List of account-related options
  Widget _buildAccountOptionsList(BuildContext context) {
    List<Map<String, String>> accountOptions = [
      {"title": "Investment History", "icon": "history"},
      {"title": "Withdrawals", "icon": "withdrawal"},
      {"title": "Security Settings", "icon": "security"},
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
      {"title": "Notification Settings", "icon": "notifications"},
      {"title": "Language", "icon": "language"},
      {"title": "Dark Mode", "icon": "dark_mode"},
      {"title": "About Us", "icon": "info"},
      {"title": "Help Center", "icon": "help"},
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
      case 'withdrawal':
        iconData = Icons.account_balance_wallet;
        break;
      case 'security':
        iconData = Icons.security;
        break;
      case 'notifications':
        iconData = Icons.notifications;
        break;
      case 'language':
        iconData = Icons.language;
        break;
      case 'dark_mode':
        iconData = Icons.dark_mode;
        break;
      case 'info':
        iconData = Icons.info;
        break;
      case 'help':
        iconData = Icons.help;
        break;
      default:
        iconData = Icons.help;
    }

    return InkWell(
      onTap: () {
        // Handle each option tap
        // Example: Navigate to respective screen
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white70, // Theme color border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Card(
         color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          child: ListTile(
            leading: Icon(iconData, color: Colors.white),
            title: Text(option['title']!,
                style: TextStyle(fontSize: 16,color: Colors.white )),
          ),
        ),
      ),
    );
  }

  // Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Handle logout action
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Logout",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
