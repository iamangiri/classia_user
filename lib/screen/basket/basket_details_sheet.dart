import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';
import '../bajal-auth/bajal_login_screen.dart';
import 'basket_invest_screen.dart';
import 'basket_model.dart';
import 'basket_api_service.dart';



class BasketDetailSheet extends StatefulWidget {
  final Basket basket;
  final bool isSubscribed;
  final double investedAmount;
  final VoidCallback onSubscribe;
  final Function(double) onInvest;
  final VoidCallback onUnsubscribe;

  const BasketDetailSheet({
    super.key,
    required this.basket,
    required this.isSubscribed,
    required this.investedAmount,
    required this.onSubscribe,
    required this.onInvest,
    required this.onUnsubscribe,
  });

  @override
  State<BasketDetailSheet> createState() => _BasketDetailSheetState();
}

class _BasketDetailSheetState extends State<BasketDetailSheet> {
  final TextEditingController _amountController = TextEditingController();
  final BasketApiService _apiService = BasketApiService();
  bool _isLoading = false;
  static const String _tokenKey = 'bajaj_auth_token';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Check Bajaj Access Token
  Future<String?> _getBajajAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting Bajaj access token: $e');
      return null;
    }
  }

  // Navigate to Invest Screen with Token Check
  Future<void> _navigateToInvestScreen() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if Bajaj access token exists
      final token = await _getBajajAccessToken();

      if (mounted) {
        if (token == null || token.isEmpty) {
          // Token not found - Navigate to Bajaj Login Screen
          Navigator.pop(context); // Close bottom sheet first

          // TODO: Replace with your actual Bajaj Login Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BajalLoginScreen()),
          );

          // Show message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.onPrimaryColor),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text('Please login to Bajaj to proceed with investment'),
                  ),
                ],
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              duration: Duration(seconds: 3),
            ),
          );

          // Uncomment this when you have BajalLoginScreen ready
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => BajalLoginScreen()),
          // );
        } else {
          // Token exists - Navigate to Invest Screen
          Navigator.pop(context); // Close bottom sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BasketInvestScreen(
                basketId: widget.basket.id,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking authentication: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSubscribe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.subscribeBasket(widget.basket.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully subscribed to ${widget.basket.basketName}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );

        widget.onSubscribe();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to subscribe: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleUnsubscribe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.unsubscribeBasket(widget.basket.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully unsubscribed from ${widget.basket.basketName}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );

        widget.onUnsubscribe();
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Close bottom sheet
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close dialog on error

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unsubscribe: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmUnsubscribe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8.w),
            Text(
              'Unsubscribe',
              style: TextStyle(
                color: AppColors.headingText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to unsubscribe from ${widget.basket.basketName}?',
          style: TextStyle(color: AppColors.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleUnsubscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimaryColor,
              ),
            )
                : const Text('Unsubscribe'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double performance = double.tryParse(widget.basket.expectedReturn) ?? 0;
    final bool isPositive = performance >= 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.screenBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border(
              top: BorderSide(
                color: AppColors.primaryGold.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.disabled.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              // Header with gradient
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.basket.basketName,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimaryColor,
                            ),
                          ),
                        ),
                        if (widget.isSubscribed)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: AppColors.onPrimaryColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Subscribed',
                                  style: TextStyle(
                                    color: AppColors.onPrimaryColor,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: isPositive ? AppColors.success : AppColors.error,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Expected Return: ${widget.basket.expectedReturn}%',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSubscribed && widget.investedAmount > 0) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.onPrimaryColor,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Invested',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.onPrimaryColor.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  '₹${widget.investedAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.all(20.w),
                  children: [
                    // Info Section
                    _sectionTitle('Basket Information'),
                    SizedBox(height: 12.h),
                    _infoRow('Subscription Type', widget.basket.subscryptionType),
                    _infoRow('Volatility', widget.basket.volatility),
                    _infoRow('Subscription Amount', '₹${widget.basket.subscriptionAmount}'),
                    _infoRow('Research Analyst', widget.basket.raName),

                    SizedBox(height: 24.h),

                    // Holdings Section
                    _sectionTitle('Holdings (${widget.basket.holdings.length})'),
                    SizedBox(height: 12.h),
                    if (widget.basket.holdings.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.h),
                          child: Text(
                            'No holdings added yet',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      )
                    else
                      ...widget.basket.holdings.map((h) => Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.show_chart,
                                    color: AppColors.primaryGold,
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.fullName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          color: AppColors.headingText,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              h.symbol,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            '${h.holdinPercentage}%',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _holdingDetailItem(
                                    'Units',
                                    h.units,
                                    Icons.inventory_2_outlined,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: _holdingDetailItem(
                                    'Order Type',
                                    h.orderType,
                                    Icons.assignment_outlined,
                                  ),
                                ),
                              ],
                            ),
                            if (h.tgtPrice != '0' || h.slPrice != '0') ...[
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  if (h.tgtPrice != '0')
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: AppColors.success.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.trending_up,
                                                  size: 14.sp,
                                                  color: AppColors.success,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  'Target',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: AppColors.secondaryText,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '₹${h.tgtPrice}',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (h.tgtPrice != '0' && h.slPrice != '0') SizedBox(width: 8.w),
                                  if (h.slPrice != '0')
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(10.w),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(
                                            color: AppColors.error.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.trending_down,
                                                  size: 14.sp,
                                                  color: AppColors.error,
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  'Stop Loss',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: AppColors.secondaryText,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '₹${h.slPrice}',
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      )),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),

              // Bottom Action Button
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: widget.isSubscribed
                    ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _navigateToInvestScreen,
                        icon: _isLoading
                            ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimaryColor,
                          ),
                        )
                            : Icon(Icons.add_circle_outline, size: 20.sp),
                        label: Text(_isLoading ? 'Checking...' : 'Invest'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.onPrimaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _confirmUnsubscribe,
                        icon: Icon(Icons.cancel_outlined, size: 18.sp),
                        label: const Text('Exit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubscribe,
                    icon: _isLoading
                        ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimaryColor,
                      ),
                    )
                        : Icon(Icons.check_circle, size: 22.sp),
                    label: Text(
                      _isLoading ? 'Subscribing...' : 'Subscribe to Basket',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.onPrimaryColor,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.headingText,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _holdingDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: AppColors.secondaryText,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}