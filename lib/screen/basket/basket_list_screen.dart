import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main/profile_screen.dart';
import 'basket_api_service.dart';
import 'basket_details_sheet.dart';
import 'basket_model.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'dart:math';

import 'basket_race_card.dart';

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

