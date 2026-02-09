import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../themes/app_colors.dart';
import '../bajal-auth/bajal_login_screen.dart';
import 'basket_invest_screen.dart';
import 'basket_model.dart';
import 'basket_api_service.dart';
import 'my_basket_screen.dart';
import '../../service/apiservice/wallet_service.dart';
import '../../utills/constent/user_constant.dart';

class SubscriptionBottomSheet extends StatefulWidget {
  final Basket basket;
  final BasketApiService apiService;
  final VoidCallback onSubscribeSuccess;

  const SubscriptionBottomSheet({
    Key? key,
    required this.basket,
    required this.apiService,
    required this.onSubscribeSuccess,
  }) : super(key: key);

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  late WalletService _walletService;
  bool _isLoading = false;
  bool _isFetchingBalance = true;
  double _walletBalance = 0.0;
  String _selectedPeriod = 'MONTHLY'; // Default period

  @override
  void initState() {
    super.initState();
    _walletService = WalletService(token: UserConstants.TOKEN ?? '');
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    if (!mounted) return;
    setState(() {
      _isFetchingBalance = true;
    });

    try {
      final response = await _walletService.getWalletBalance();
      if (mounted && response['status'] == true && response['data'] != null) {
        setState(() {
          _walletBalance = (response['data']['balance'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint("Error fetching wallet balance: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingBalance = false;
        });
      }
    }
  }

  Future<void> _handleConfirmSubscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.subscribeBasket(
        widget.basket.id,
        period: _selectedPeriod,
      );

      if (!mounted) return;

      final bool isSuccess = response['status'] == true;
      final String message = response['message'] ??
          (isSuccess ? 'Successfully subscribed' : 'Subscription failed');

      Navigator.pop(context); // Close bottom sheet

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSubscribeSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to subscribe: ${e.toString()}'),
            backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    final subscriptionAmount = widget.basket.subscriptionAmountValue.toDouble();
    // Assuming yearly might have a discount or just x12, for now simplistic logic
    // or if the model supported specific prices per period.
    // The user prompt only specified Monthly/Yearly options.
    // We'll display the same amount for now unless logic dictates otherwise.
    // Actually, usually Yearly = Monthly * 12. Let's assume standard pricing for now.
    final displayPrice = _selectedPeriod == 'YEARLY'
        ? subscriptionAmount * 12
        : subscriptionAmount;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Subscription',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Wallet Balance
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border:
                  Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _isFetchingBalance
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : Text(
                        '₹${_walletBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Period Selection
          Text(
            'Select Period',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildPeriodOption('Monthly', 'MONTHLY'),
              SizedBox(width: 12.w),
              _buildPeriodOption('Yearly', 'YEARLY'),
            ],
          ),
          SizedBox(height: 24.h),

          // Price Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${displayPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Subscribe Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: _isLoading || _isFetchingBalance
                  ? null
                  : _handleConfirmSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Confirm Subscription',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildPeriodOption(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryGold : Colors.grey[400]!,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet widget that displays detailed information about a basket
/// including price performance, holdings, and subscription/investment options
///
/// FIXED VERSION: Optimized for older Android devices (Android 10 and below)
class BasketDetailSheet extends StatefulWidget {
  final Basket basket;
  final bool isSubscribed;
  final double investedAmount;
  final VoidCallback onSubscribe;
  final Function(double) onInvest;
  final bool navigateToInvest;

  const BasketDetailSheet({
    super.key,
    required this.basket,
    required this.isSubscribed,
    required this.investedAmount,
    required this.onSubscribe,
    required this.onInvest,
    this.navigateToInvest = true,
  });

  @override
  State<BasketDetailSheet> createState() => _BasketDetailSheetState();
}

class _BasketDetailSheetState extends State<BasketDetailSheet> {
  final TextEditingController _amountController = TextEditingController();
  final BasketApiService _apiService = BasketApiService();
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  late Basket _currentBasket;
  static const String _tokenKey = 'bajaj_auth_token';

  @override
  void initState() {
    super.initState();
    _currentBasket = widget.basket;
    // If holdings are empty, try to fetch full details (in case List API returned lean object)
    if (_currentBasket.holdings.isEmpty) {
      _fetchBasketDetails();
    }
  }

  Future<void> _fetchBasketDetails() async {
    setState(() {
      _isFetchingDetails = true;
    });
    try {
      final fullBasket = await _apiService.fetchBasketById(_currentBasket.id);
      if (mounted) {
        setState(() {
          // Preserve subscription details from the previous state
          _currentBasket = fullBasket.copyWith(
            subscribedVersionId: _currentBasket.subscribedVersionId,
            subscriptionId: _currentBasket.subscriptionId,
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching basket details: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingDetails = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<String?> _getBajajAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting Bajaj access token: $e');
      return null;
    }
  }

  Future<void> _navigateToInvestScreen() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getBajajAccessToken();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        Navigator.pop(context);

        final loginSuccess = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => BajalLoginScreen(
              returnRoute: 'basket_invest',
              returnArguments: {
                'basketId': _currentBasket.id,
                'basket': _currentBasket,
              },
            ),
          ),
        );

        if (!mounted) return;

        if (loginSuccess == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BasketInvestScreen(
                basketId: _currentBasket.id,
                basket: _currentBasket,
              ),
            ),
          );
        } else if (loginSuccess == false) {
          _showSnackBar(
            message: 'Login required to invest in baskets',
            icon: Icons.info_outline,
            backgroundColor: AppColors.warning,
          );
        }
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BasketInvestScreen(
              basketId: _currentBasket.id,
              basket: _currentBasket,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          message: 'Error checking authentication: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: AppColors.error,
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

  void _handleSubscribe() {
    _showSubscriptionBottomSheet();
  }

  void _showSubscriptionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionBottomSheet(
        basket: _currentBasket,
        apiService: _apiService,
        onSubscribeSuccess: () {
          widget.onSubscribe();
          // Optionally refresh details
          _fetchBasketDetails();
        },
      ),
    );
  }

  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.onPrimaryColor, size: 20),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double initialPrice = _currentBasket.initialPriceValue;
    final double currentPrice = _currentBasket.currentPriceValue;
    final double performance = _currentBasket.performanceValue;
    final bool isPositive = performance >= 0;
    final bool hasPriceData = _currentBasket.hasPriceData;

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
              _buildDragHandle(),

              // Header Section
              _buildHeaderSection(
                initialPrice: initialPrice,
                currentPrice: currentPrice,
                performance: performance,
                isPositive: isPositive,
                hasPriceData: hasPriceData,
              ),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  children: [
                    _buildBasketInfoSection(),
                    if (widget.navigateToInvest)
                      _isFetchingDetails
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryGold))
                          : _buildHoldingsSection(),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),

              // Bottom Action Button
              _buildBottomActionButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
      width: 40.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }

  Widget _buildHeaderSection({
    required double initialPrice,
    required double currentPrice,
    required double performance,
    required bool isPositive,
    required bool hasPriceData,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
          // Basket Name and Subscribed Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentBasket.basketName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSubscribed) ...[
                _buildSubscribedBadge(),
                if (_currentBasket.subscribedVersionId != null &&
                    _currentBasket.subscribedVersionId != 0)
                  _buildVersionBadge(_currentBasket.subscribedVersionId!),
              ],
            ],
          ),
          SizedBox(height: 14.h),

          // Price Performance Section
          if (hasPriceData)
            _buildPricePerformanceSection(
              initialPrice: initialPrice,
              currentPrice: currentPrice,
              performance: performance,
              isPositive: isPositive,
            )
          else
            _buildNoPriceDataSection(),

          // Invested Amount Section
          if (widget.isSubscribed && widget.investedAmount > 0) ...[
            SizedBox(height: 12.h),
            _buildInvestedAmountSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscribedBadge() {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
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
            size: 14.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            'Subscribed',
            style: TextStyle(
              color: AppColors.onPrimaryColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionBadge(int versionId) {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        'v$versionId',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildPricePerformanceSection({
    required double initialPrice,
    required double currentPrice,
    required double performance,
    required bool isPositive,
  }) {
    return Column(
      children: [
        // Price boxes
        Row(
          children: [
            Expanded(
              child: _buildPriceBox(
                label: 'Initial Price',
                value: '₹${initialPrice.toStringAsFixed(2)}',
                valueColor: AppColors.onPrimaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildPriceBox(
                label: 'Current Price',
                value: '₹${currentPrice.toStringAsFixed(2)}',
                valueColor: isPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Performance indicator
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
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                '${isPositive ? '+' : ''}${performance.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '(₹${_currentBasket.priceChangeAmount.toStringAsFixed(2)})',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBox({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.onPrimaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.onPrimaryColor.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPriceDataSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.secondaryText,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Price data not available yet',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestedAmountSection() {
    return Container(
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
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Invested',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.onPrimaryColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '₹${widget.investedAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basket Information',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: 12.h),
        _buildInfoRow('Subscription Type', _currentBasket.subscryptionType),
        _buildInfoRow('Volatility', _currentBasket.volatility),
        _buildInfoRow(
            'Subscription Amount', '₹${_currentBasket.subscriptionAmount}'),
        _buildInfoRow('Research Analyst', _currentBasket.raName),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    // Handle empty or null values
    final displayValue = (value.isEmpty) ? '-' : value;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsSection() {
    final holdings = _currentBasket.holdings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          'Holdings (${holdings.length})',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: 12.h),
        if (holdings.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Text(
                'No holdings added yet',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13.sp,
                ),
              ),
            ),
          )
        else
          ...holdings.map((h) => _buildHoldingCard(h)).toList(),
      ],
    );
  }

  Widget _buildHoldingCard(dynamic holding) {
    return Container(
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
          // Holding Header
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
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holding.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: AppColors.headingText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
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
                            holding.symbol,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${holding.holdinPercentage}%',
                          style: TextStyle(
                            fontSize: 11.sp,
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

          // Holding Details
          Row(
            children: [
              Expanded(
                child: _buildHoldingDetailItem(
                  'Units',
                  holding.units,
                  Icons.inventory_2_outlined,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildHoldingDetailItem(
                  'Order Type',
                  holding.orderType,
                  Icons.assignment_outlined,
                ),
              ),
            ],
          ),

          // Target and Stop Loss
          if (holding.tgtPrice != '0' || holding.slPrice != '0') ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                if (holding.tgtPrice != '0')
                  Expanded(
                    child: _buildTargetStopLossBox(
                      label: 'Target',
                      value: '₹${holding.tgtPrice}',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                    ),
                  ),
                if (holding.tgtPrice != '0' && holding.slPrice != '0')
                  SizedBox(width: 8.w),
                if (holding.slPrice != '0')
                  Expanded(
                    child: _buildTargetStopLossBox(
                      label: 'Stop Loss',
                      value: '₹${holding.slPrice}',
                      icon: Icons.trending_down,
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHoldingDetailItem(String label, String value, IconData icon) {
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
        children: [
          Icon(
            icon,
            size: 13.sp,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10.sp,
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

  Widget _buildTargetStopLossBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13.sp, color: color),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: widget.isSubscribed
            ? (widget.navigateToInvest
                ? _buildInvestButton()
                : _buildSubscriptionSuccessCard())
            : _buildSubscribeButton(),
      ),
    );
  }

  Widget _buildInvestButton() {
    return SizedBox(
      width: double.infinity,
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
            : Icon(Icons.add_circle_outline, size: 18.sp),
        label: Text(
          _isLoading ? 'Checking...' : 'Invest',
          style: TextStyle(fontSize: 14.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.onPrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildSubscriptionSuccessCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyBasketScreen(showBackButton: true),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.success.withOpacity(0.1),
              AppColors.primaryGold.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.onPrimaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basket Subscribed Successfully!',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Go to My Baskets to invest in this basket',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryGold,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
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
            : Icon(Icons.check_circle, size: 20.sp),
        label: Text(
          _isLoading ? 'Subscribing...' : 'Subscribe to Basket',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.onPrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
