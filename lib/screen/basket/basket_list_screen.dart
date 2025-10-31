import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'basket_api_service.dart';
import 'basket_model.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'dart:math';

class BasketListScreen extends StatefulWidget {
  const BasketListScreen({super.key});

  @override
  State<BasketListScreen> createState() => _BasketListScreenState();
}

class _BasketListScreenState extends State<BasketListScreen>
    with SingleTickerProviderStateMixin {
  late final BasketApiService _service;
  late Future<List<Basket>> _futureBaskets;
  final bool _isMarketOpen = true;

  late TabController _tabController;
  Set<String> _subscribedBasketIds = {};
  Map<String, double> _investedAmounts = {};

  @override
  void initState() {
    super.initState();
    _service = BasketApiService();
    _tabController = TabController(length: 2, vsync: this);
    _loadSubscriptions();
    _futureBaskets = _service.fetchBaskets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load subscribed baskets from SharedPreferences
  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedList = prefs.getStringList('subscribed_baskets') ?? [];
    final investmentsJson = prefs.getString('invested_amounts') ?? '{}';

    setState(() {
      _subscribedBasketIds = subscribedList.toSet();
      _investedAmounts = Map<String, double>.from(
          json.decode(investmentsJson).map((k, v) => MapEntry(k, v.toDouble()))
      );
    });
  }

  // Save subscribed basket
  Future<void> _subscribeBasket(Basket basket) async {
    final prefs = await SharedPreferences.getInstance();
    _subscribedBasketIds.add(basket.id.toString());
    await prefs.setStringList(
      'subscribed_baskets',
      _subscribedBasketIds.toList(),
    );

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Subscribed to ${basket.basketName}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  // Invest in basket
  Future<void> _investInBasket(Basket basket, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final basketId = basket.id.toString();

    _investedAmounts[basketId] = (_investedAmounts[basketId] ?? 0) + amount;

    await prefs.setString(
      'invested_amounts',
      json.encode(_investedAmounts),
    );

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Invested ₹${amount.toStringAsFixed(0)} in ${basket.basketName}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    }
  }

  // Unsubscribe basket
  Future<void> _unsubscribeBasket(String basketId) async {
    final prefs = await SharedPreferences.getInstance();
    _subscribedBasketIds.remove(basketId);
    await prefs.setStringList(
      'subscribed_baskets',
      _subscribedBasketIds.toList(),
    );
    setState(() {});
  }

  Future<void> _refresh() async {
    await _loadSubscriptions();
    setState(() {
      _futureBaskets = _service.fetchBaskets();
    });
  }

  void _showDetails(Basket basket) {
    final bool isSubscribed = _subscribedBasketIds.contains(basket.id.toString());
    final double investedAmount = _investedAmounts[basket.id.toString()] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BasketDetailSheet(
        basket: basket,
        isSubscribed: isSubscribed,
        investedAmount: investedAmount,
        onSubscribe: () => _subscribeBasket(basket),
        onInvest: (amount) => _investInBasket(basket, amount),
        onUnsubscribe: () => _unsubscribeBasket(basket.id.toString()),
      ),
    );
  }

  List<Basket> _filterBaskets(List<Basket> baskets, bool myBaskets) {
    if (myBaskets) {
      return baskets.where((b) =>
          _subscribedBasketIds.contains(b.id.toString())
      ).toList();
    }
    return baskets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('Classia Baskets'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimaryColor,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              border: Border(
                top: BorderSide(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryGold,
              indicatorWeight: 3,
              labelColor: AppColors.primaryGold,
              unselectedLabelColor: AppColors.onPrimaryColor.withOpacity(0.6),
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grid_view, size: 18.sp),
                      SizedBox(width: 6.w),
                      const Text('All Baskets'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet, size: 18.sp),
                      SizedBox(width: 6.w),
                      const Text('My Baskets'),
                      if (_subscribedBasketIds.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_subscribedBasketIds.length}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.onPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Disclaimer Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isMarketOpen ? Icons.circle : Icons.access_time,
                  color: _isMarketOpen ? AppColors.success : AppColors.warning,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isMarketOpen
                        ? 'Live Market: Basket race based on real-time market value'
                        : 'Market Closed: Showing last closing value',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Baskets Tab
                _buildBasketList(false),
                // My Baskets Tab
                _buildBasketList(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketList(bool myBaskets) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryGold,
      child: FutureBuilder<List<Basket>>(
        future: _futureBaskets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGold,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: AppColors.errorColor),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _refresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final baskets = _filterBaskets(snapshot.data!, myBaskets);

          if (baskets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    myBaskets ? Icons.shopping_basket_outlined : Icons.inbox_outlined,
                    size: 80.sp,
                    color: AppColors.disabled,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    myBaskets
                        ? 'No subscribed baskets yet'
                        : 'No baskets found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  if (myBaskets) ...[
                    SizedBox(height: 8.h),
                    TextButton(
                      onPressed: () => _tabController.animateTo(0),
                      child: Text(
                        'Browse All Baskets',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: baskets.length,
            itemBuilder: (context, index) {
              final basket = baskets[index];
              final isSubscribed = _subscribedBasketIds.contains(basket.id.toString());
              final investedAmount = _investedAmounts[basket.id.toString()] ?? 0;

              return BasketRaceCard(
                basket: basket,
                onTap: () => _showDetails(basket),
                isMarketOpen: _isMarketOpen,
                isSubscribed: isSubscribed,
                investedAmount: investedAmount,
              );
            },
          );
        },
      ),
    );
  }
}

// ===============================================
// BASKET RACE CARD WITH HORSE ANIMATION
// ===============================================
class BasketRaceCard extends StatefulWidget {
  final Basket basket;
  final VoidCallback onTap;
  final bool isMarketOpen;
  final bool isSubscribed;
  final double investedAmount;

  const BasketRaceCard({
    super.key,
    required this.basket,
    required this.onTap,
    required this.isMarketOpen,
    required this.isSubscribed,
    required this.investedAmount,
  });

  @override
  State<BasketRaceCard> createState() => _BasketRaceCardState();
}

class _BasketRaceCardState extends State<BasketRaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;
  late double _raceScore;

  @override
  void initState() {
    super.initState();
    _raceScore = (Random().nextDouble() * 9 + 1);

    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _updateHorseAnimation();
  }

  void _updateHorseAnimation() {
    double normalizedValue = (_raceScore / 10).clamp(0.0, 1.0);
    _horseAnimation = Tween<double>(
      begin: 0,
      end: normalizedValue,
    ).animate(CurvedAnimation(
      parent: _horseController,
      curve: Curves.easeInOut,
    ));
    _horseController.forward();
  }

  @override
  void dispose() {
    _horseController.dispose();
    super.dispose();
  }

  Color _volatilityColor(String vol) {
    switch (vol) {
      case 'LOW':
        return AppColors.success.withOpacity(0.2);
      case 'MID':
        return AppColors.warning.withOpacity(0.2);
      case 'HIGH':
        return AppColors.error.withOpacity(0.2);
      default:
        return AppColors.disabled.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double performance = double.tryParse(widget.basket.expectedReturn) ?? 0;
    final bool isPositive = performance >= 0;
    final double cardWidth = MediaQuery.of(context).size.width - 48.w;

    return Card(
      elevation: widget.isSubscribed ? 4 : 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: widget.isSubscribed
              ? AppColors.primaryGold
              : AppColors.primaryGold.withOpacity(0.3),
          width: widget.isSubscribed ? 2 : 1,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: widget.onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.basket.basketName,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.isSubscribed) ...[
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.verified,
                                    color: AppColors.primaryGold,
                                    size: 18.sp,
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'RA: ${widget.basket.raName}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isPositive ? AppColors.success : AppColors.error,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isPositive ? Icons.trending_up : Icons.trending_down,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${widget.basket.expectedReturn}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: isPositive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Expected',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Race Track with Horse
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: cardWidth,
                        height: 8.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: AppColors.primaryGold.withOpacity(0.2),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: _horseAnimation.value * cardWidth,
                            height: 8.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.r),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold,
                                  AppColors.primaryGold.withOpacity(0.6),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          double horsePosition = _horseAnimation.value * cardWidth;
                          return Positioned(
                            left: (horsePosition - 25.w).clamp(0.0, cardWidth - 50.w),
                            top: -35.h,
                            child: SizedBox(
                              height: 50.h,
                              width: 60.w,
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

                  SizedBox(height: 20.h),

                  // Invested Amount (if subscribed)
                  if (widget.isSubscribed && widget.investedAmount > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGold.withOpacity(0.1),
                            AppColors.primaryGold.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.primaryGold,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Invested: ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          Text(
                            '₹${widget.investedAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Info Chips Row
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _miniChip(
                        widget.basket.subscryptionType,
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.primaryColor,
                      ),
                      _miniChip(
                        widget.basket.volatility,
                        _volatilityColor(widget.basket.volatility),
                        widget.basket.volatility == 'LOW'
                            ? AppColors.success
                            : widget.basket.volatility == 'MID'
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                      _miniChip(
                        '₹${widget.basket.subscriptionAmount}',
                        AppColors.primaryGold.withOpacity(0.1),
                        AppColors.primaryGold,
                      ),
                      _miniChip(
                        '${widget.basket.holdings.length} Holdings',
                        AppColors.accent.withOpacity(0.1),
                        AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Subscribed Badge
            if (widget.isSubscribed)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14.r),
                      bottomLeft: Radius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
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
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ===============================================
// BOTTOM SHEET MODAL WITH SUBSCRIBE/INVEST
// ===============================================
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showInvestDialog() {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.primaryGold),
            SizedBox(width: 8.w),
            Text(
              'Invest Amount',
              style: TextStyle(
                color: AppColors.headingText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter amount to invest in ${widget.basket.basketName}',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primaryGold),
                hintText: 'Enter amount',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: AppColors.screenBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.primaryGold, width: 2),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              children: [5000, 10000, 25000, 50000].map((amount) {
                return InkWell(
                  onTap: () => _amountController.text = amount.toString(),
                  child: Chip(
                    label: Text('₹$amount'),
                    backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                widget.onInvest(amount);
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Invest Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
            onPressed: () {
              widget.onUnsubscribe();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Unsubscribe'),
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
                        padding: EdgeInsets.all(12.w),
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
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryGold,
                                  radius: 20.r,
                                  child: Text(
                                    '${h.stockId}',
                                    style: TextStyle(
                                      color: AppColors.onPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stock #${h.stockId}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                          color: AppColors.primaryText,
                                        ),
                                      ),
                                      Text(
                                        '${h.holdinPercentage}% allocation',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (h.tgtPrice != '0' || h.slPrice != '0')
                              Padding(
                                padding: EdgeInsets.only(top: 12.h),
                                child: Row(
                                  children: [
                                    if (h.tgtPrice != '0')
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Target',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: AppColors.secondaryText,
                                                ),
                                              ),
                                              Text(
                                                '₹${h.tgtPrice}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.success,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (h.tgtPrice != '0' && h.slPrice != '0')
                                      SizedBox(width: 8.w),
                                    if (h.slPrice != '0')
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Stop Loss',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: AppColors.secondaryText,
                                                ),
                                              ),
                                              Text(
                                                '₹${h.slPrice}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
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
                              ),
                          ],
                        ),
                      )),

                    SizedBox(height: 80.h), // Space for button
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
                        onPressed: _showInvestDialog,
                        icon: Icon(Icons.add_circle_outline, size: 20.sp),
                        label: const Text('Invest More'),
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
                        onPressed: _confirmUnsubscribe,
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
                    onPressed: () {
                      widget.onSubscribe();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.check_circle, size: 22.sp),
                    label: Text(
                      'Subscribe to Basket',
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
}