import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../service/apiservice/user_service.dart';
import '../../utills/themes/light_app_theme.dart';
import '../../widget/common_app_bar.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool isLoading = false;

  _handleChangePassword() async {
    // Basic validation
    if (_currentPassController.text.isEmpty) {
      _showErrorDialog("Please enter current password");
      return;
    }

    if (_newPassController.text.isEmpty) {
      _showErrorDialog("Please enter new password");
      return;
    }

    if (_newPassController.text.length < 8) {
      _showErrorDialog("New password must be at least 8 characters long");
      return;
    }

    if (_confirmPassController.text.isEmpty) {
      _showErrorDialog("Please confirm your new password");
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      _showErrorDialog("New password and confirm password do not match");
      return;
    }

    setState(() => isLoading = true);

    final response = await UserService.changePassword(
      currentPassword: _currentPassController.text,
      newPassword: _newPassController.text,
      confirmPassword: _confirmPassController.text,
    );

    setState(() => isLoading = false);

    if (response['success'] == true) {
      _showSuccessDialog(response['message']);
    } else {
      // Show detailed error messages
      if (response.containsKey('errors') && response['errors'] != null) {
        final errors = (response['errors'] as List).join('\n');
        _showErrorDialog(errors);
      } else {
        _showErrorDialog(response['message']);
      }
    }
  }

  _showSuccessDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text("Success"),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text("Error"),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Change Password',),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              Text("Update Your Password",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTheme.primaryColor)),

              SizedBox(height: 10),

              Text(
                "Password must be at least 8 characters long",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              SizedBox(height: 20),

              _buildTextField("Current Password", _currentPassController),
              SizedBox(height: 15),
              _buildTextField("New Password", _newPassController),
              SizedBox(height: 15),
              _buildTextField("Confirm Password", _confirmPassController),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isLoading ? null : _handleChangePassword,
                  child: isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Processing...",
                        style:
                        TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )
                      : Text(
                    "Change Password",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
}