import 'package:flutter/material.dart';

import '../screen/homefetures/notification_screen.dart';
import '../screen/main/profile_screen.dart';
import '../screen/profile/customer_support_screen.dart';
import '../themes/app_colors.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSupportPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onSupportPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 2,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primaryText,),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.support_agent, color: AppColors.primaryText),
          onPressed: onSupportPressed ?? () {
            // TODO: Implement customer support action
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerSupportScreen()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: AppColors.primaryText),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}