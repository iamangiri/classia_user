import 'dart:convert';
import 'package:classia_amc/screen/sip/sip_add_edit_goal_screen.dart';
import 'package:classia_amc/screen/sip/sip_explore_goal_grid.dart';
import 'package:classia_amc/screen/sip/sip_goal_based_fund_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';

class WishlistTab extends StatefulWidget {
  @override
  _WishlistTabState createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> with TickerProviderStateMixin {
  late AnimationController _horseAnimationController;
  late Animation<double> _horseAnimation;
  List<WishlistItem> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _horseAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _horseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _horseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadWishlistItems();
  }

  @override
  void dispose() {
    _horseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistData = prefs.getString('wishlist_items');
    if (wishlistData != null) {
      try {
        final List<dynamic> decoded = jsonDecode(wishlistData);
        setState(() {
          wishlistItems = decoded
              .map((item) => WishlistItem.fromJson(item))
              .toList();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading wishlist: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    }
  }

  Future<void> _saveWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final String encoded = jsonEncode(
        wishlistItems.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('wishlist_items', encoded);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving wishlist: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  void _addOrUpdateWishlistItem(WishlistItem item, {int? index}) {
    setState(() {
      if (index != null && index >= 0 && index < wishlistItems.length) {
        wishlistItems[index] = item;
      } else {
        wishlistItems.add(item);
      }
    });
    _saveWishlistItems();
  }

  String formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  Widget _buildAnimatedHorse() {
    return AnimatedBuilder(
      animation: _horseAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 5 * (0.5 - (_horseAnimation.value - 0.5).abs())),
          child: Transform.rotate(
            angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
            child: Container(
              width: 150.w,
              height: 100.h,
              child: Center(
                child: Image.asset(
                  'assets/images/jt1.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 32.w;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            child: Column(
              children: [
                _buildAnimatedHorse(),
                SizedBox(height: 16.h),
                Text(
                  'Your Wishlist',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Dreams saved for the future',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 24.h),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditGoalScreen(
                      onSave: _addOrUpdateWishlistItem,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.buttonText ?? Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Add New Goal',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (wishlistItems.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No goals added yet. Start by adding a new goal!',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ...wishlistItems.asMap().entries.map((entry) {
            int index = entry.key;
            WishlistItem item = entry.value;
            AnimationController progressController = AnimationController(
              duration: Duration(seconds: 3),
              vsync: this,
            )..forward();
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 600 + (index * 200)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: item.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: item.color,
                                        size: 24.sp,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor ?? Colors.blueAccent,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Monthly SIP: ${formatCurrency(item.monthlySIP)}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: AppColors.secondaryText ?? Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 28.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: ${item.progress.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor ?? Colors.blueAccent,
                                ),
                              ),
                              Text(
                                'Target: ${formatCurrency(item.targetAmount)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor ?? Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: cardWidth - 40.w,
                                height: 6.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: Colors.grey[300],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: Tween<double>(begin: 0, end: item.progress / 100).animate(
                                  CurvedAnimation(
                                    parent: progressController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                builder: (context, child) {
                                  double progressValue = (item.progress / 100).clamp(0.0, 1.0);
                                  return Container(
                                    width: progressValue * (cardWidth - 40.w),
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.r),
                                      gradient: LinearGradient(
                                        colors: [AppColors.primaryGold ?? Color(0xFFDAA520), Colors.amber[700]!],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: Tween<double>(begin: 0, end: item.progress / 100).animate(
                                  CurvedAnimation(
                                    parent: progressController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                builder: (context, child) {
                                  double progressValue = (item.progress / 100).clamp(0.0, 1.0);
                                  double horsePosition = progressValue * (cardWidth - 40.w);
                                  return Positioned(
                                    left: horsePosition - 20.w,
                                    top: -30.h,
                                    child: SizedBox(
                                      height: 70.h,
                                      width: 90.w,
                                      child: Image.asset(
                                        'assets/images/jt1.gif',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditGoalScreen(
                                          onSave: (item) => _addOrUpdateWishlistItem(item as WishlistItem, index: index),
                                          initialItem: item,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.border ?? Colors.grey),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Edit Goal',
                                    style: TextStyle(
                                      color: AppColors.secondaryText ?? Colors.grey,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SipGoalBasedFundScreen(
                                          goal: ExploreGoal(
                                            name: item.name,
                                            icon: item.icon,
                                            description: 'Invest towards your ${item.name} goal with a monthly SIP of ${formatCurrency(item.monthlySIP)}.',
                                            color: item.color,
                                            lottieAsset: '',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Start SIP',
                                    style: TextStyle(
                                      color: AppColors.buttonText ?? Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                progressController.dispose();
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}


IconData getIconDataByName(String name) {
  switch (name) {
    case 'home': return Icons.home;
    case 'car': return Icons.directions_car;
    case 'travel': return Icons.flight;
    case 'education': return Icons.school;
    case 'star': return Icons.star;
  // Add more as needed
    default: return Icons.star; // fallback
  }
}


class WishlistItem {
  final String name;
  final IconData icon;
  final double targetAmount;
  final double monthlySIP;
  final double progress;
  final Color color;

  WishlistItem({
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.monthlySIP,
    required this.progress,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon.codePoint,
      'targetAmount': targetAmount,
      'monthlySIP': monthlySIP,
      'progress': progress,
      'color': color.value,
    };
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      name: json['name'] ?? '',
      icon: getIconDataByName(json['icon'] ?? 'star'),
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      monthlySIP: (json['monthlySIP'] as num?)?.toDouble() ?? 0.0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      color: Color(json['color'] ?? Colors.blue.value),
    );
  }
}