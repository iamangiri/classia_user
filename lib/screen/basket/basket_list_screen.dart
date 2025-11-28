import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'basket_api_service.dart';
import 'basket_details_sheet.dart';
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
    var filteredBaskets = baskets.where((b) => b.isDeliveryType).toList();

    if (myBaskets) {
      return filteredBaskets.where((b) =>
          _subscribedBasketIds.contains(b.id.toString())
      ).toList();
    }
    return filteredBaskets;
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
                        ? 'Live Market: Showing DELIVERY type baskets only'
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasketList(false),
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
                        : 'No DELIVERY baskets found',
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
                      if (!widget.basket.isFree)
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



