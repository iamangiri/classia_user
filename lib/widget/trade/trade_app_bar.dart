import 'package:flutter/material.dart';
import 'dart:async';

import '../../screen/calcutator/sip_calcutator.dart';
import '../../screen/homefetures/notification_screen.dart';
import '../../screen/main/profile_screen.dart';
import '../../screen/profile/customer_support_screen.dart';
import '../../themes/app_colors.dart';

class TradeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSupportPressed;

  const TradeAppBar({
    Key? key,
    required this.title,
    this.onSupportPressed,
  }) : super(key: key);

  @override
  State<TradeAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<TradeAppBar> {
  DateTime currentTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentTime = DateTime.now();
        });
      }
    });
  }

  bool _isMarketOpen() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Check if it's Saturday (6) or Sunday (7)
    if (weekday == 6 || weekday == 7) {
      return false;
    }

    // Market hours: 9:15 AM to 3:30 PM (Indian Stock Exchange)
    final marketOpen = DateTime(now.year, now.month, now.day, 9, 15);
    final marketClose = DateTime(now.year, now.month, now.day, 15, 30);

    return now.isAfter(marketOpen) && now.isBefore(marketClose);
  }

  String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    String minute = time.minute.toString().padLeft(2, '0');
    String second = time.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second $period';
  }

  Widget _buildMarketStatusIndicator() {
    final isOpen = _isMarketOpen();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? Colors.green.withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            isOpen ? 'LIVE' : 'CLOSED',
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _formatTime(currentTime),
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 2,
      leading: IconButton(
        icon: Icon(Icons.person, color: AppColors.primaryGold),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        ),
      ),
      title: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          _buildMarketStatusIndicator(),
          SizedBox(height: 5),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.calculate, color: AppColors.primaryGold),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvestmentCalculator()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.support_agent, color: AppColors.primaryGold),
          onPressed: widget.onSupportPressed ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerSupportScreen()),
            );
          },
        ),

      ],
    );
  }
}