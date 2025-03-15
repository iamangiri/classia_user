import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> securityOptions = [

    {
      "title": "2FA",
      "icon": Icons.verified_user,
    },
    {
      "title": "Change Password",
      "icon": Icons.lock_outline,
    },
    {
      "title": "Change Phone Number",
      "icon": Icons.phone,
    },
    {
      "title": "Notification Settings",
      "icon": Icons.notifications,
    },
    {
      "title": "Dark Mode",
      "icon": Icons.dark_mode,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // White back icon
        title: Text(
          "Security Settings",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: securityOptions.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final option = securityOptions[index];
          return InkWell(
            onTap: () {
              // Navigate based on option title
              switch (option['title']) {
                case "Notification Settings":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
                  );
                  break;
                case "Dark Mode":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DarkModeScreen()),
                  );
                  break;
                case "Clear Cache":
                  _showClearCacheDialog(context);
                  break;
                case "2FA":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TwoFactorAuthScreen()),
                  );
                  break;
                case "Change Password":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                  );
                  break;
                case "Change Phone Number":
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePhoneNumberScreen()),
                  );
                  break;
              }
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
                leading: Icon(option['icon'], color: Colors.white, size: 28),
                title: Text(
                  option['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Clear Cache", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to clear the cache?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () {
              // Perform cache clearing operation here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Cache cleared", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black,
                ),
              );
            },
            child: Text("Clear", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// Dummy destination screens for demonstration purposes

class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Notification Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(child: Text("Notification Settings", style: TextStyle(color: Colors.white))),
    );
  }
}

class DarkModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Dark Mode", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(child: Text("Dark Mode Settings", style: TextStyle(color: Colors.white))),
    );
  }
}

class TwoFactorAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Two-Factor Authentication", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(child: Text("2FA Settings", style: TextStyle(color: Colors.white))),
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Change Password", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(child: Text("Change Password Screen", style: TextStyle(color: Colors.white))),
    );
  }
}

class ChangePhoneNumberScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Change Phone Number", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(child: Text("Change Phone Number Screen", style: TextStyle(color: Colors.white))),
    );
  }
}
