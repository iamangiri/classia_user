
import 'package:flutter/material.dart';
import '../screen/calcutator/main_calcutator_screen.dart';
import '../screen/main/profile_screen.dart';
import '../screen/profile/customer_support_screen.dart';
import '../screen/profile/my_wallet_screen.dart';
import '../themes/app_colors.dart';
import '../utills/themes/light_app_theme.dart';


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
      backgroundColor: AppTheme.lightTheme.primaryColor,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          color: AppColors.primaryGold,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 2,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.person, color: AppColors.primaryGold,),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.calculate, color: AppColors.primaryGold),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvestmentCalculator()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.wallet, color: AppColors.primaryGold),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyWalletScreen()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.support_agent, color: AppColors.primaryGold),
          onPressed: onSupportPressed ?? () {
            // TODO: Implement customer support action
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  CustomerSupportScreen(showBackButton :true)),
            );
          },
        ),


      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}