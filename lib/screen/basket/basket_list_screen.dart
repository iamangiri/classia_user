import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main/profile_screen.dart';
import 'basket_api_service.dart';
import 'basket_details_sheet.dart';
import 'basket_model.dart';
import 'package:classia_amc/themes/app_colors.dart';
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
  Future<List<Basket>>? _futureMyBaskets;
  final bool _isMarketOpen = true;

  late TabController _tabController;
  Set<int> _subscribedBasketIds = {};

  @override
  void initState() {
    super.initState();
    _service = BasketApiService();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _futureBaskets = _service.fetchBaskets();
    _loadMyBaskets();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      _loadMyBaskets();
    }
  }

  Future<void> _loadMyBaskets() async {
    setState(() {
      _futureMyBaskets = _service.fetchMyBaskets();
    });

    // Update subscribed basket IDs for the "All Baskets" tab
    try {
      final myBaskets = await _futureMyBaskets!;
      setState(() {
        _subscribedBasketIds = myBaskets.map((b) => b.id).toSet();
      });
    } catch (e) {
      print('Error loading my baskets: $e');
    }
  }

  Future<void> _subscribeBasket(Basket basket) async {
    setState(() {
      _subscribedBasketIds.add(basket.id);
    });

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

    // Refresh my baskets list
    _loadMyBaskets();
  }

  Future<void> _unsubscribeBasket(int basketId) async {
    setState(() {
      _subscribedBasketIds.remove(basketId);
    });

    // Refresh my baskets list
    _loadMyBaskets();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureBaskets = _service.fetchBaskets();
    });

    if (_tabController.index == 1) {
      _loadMyBaskets();
    } else {
      // Still load my baskets in background to update subscription status
      _loadMyBaskets();
    }
  }

  void _showDetails(Basket basket) {
    final bool isSubscribed = _subscribedBasketIds.contains(basket.id);
    final double investedAmount = 0; // You can add investment tracking if needed

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BasketDetailSheet(
        basket: basket,
        isSubscribed: isSubscribed,
        investedAmount: investedAmount,
        onSubscribe: () => _subscribeBasket(basket),
        onInvest: (amount) {
          // Handle investment if needed
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
        },
        onUnsubscribe: () => _unsubscribeBasket(basket.id),
      ),
    );
  }

  List<Basket> _filterBaskets(List<Basket> baskets) {
    return baskets.where((b) => b.isDeliveryType).toList();
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
              icon: Icon(Icons.person, color: AppColors.primaryGold),
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
                _buildAllBasketsList(),
                _buildMyBasketsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBasketsList() {
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

          final baskets = _filterBaskets(snapshot.data!);

          if (baskets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80.sp,
                    color: AppColors.disabled,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No DELIVERY baskets found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: baskets.length,
            itemBuilder: (context, index) {
              final basket = baskets[index];
              final isSubscribed = _subscribedBasketIds.contains(basket.id);

              return BasketRaceCard(
                basket: basket,
                onTap: () => _showDetails(basket),
                isMarketOpen: _isMarketOpen,
                isSubscribed: isSubscribed,
                investedAmount: 0,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMyBasketsList() {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryGold,
      child: FutureBuilder<List<Basket>>(
        future: _futureMyBaskets,
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
                    textAlign: TextAlign.center,
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

          final baskets = snapshot.data ?? [];

          if (baskets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 80.sp,
                    color: AppColors.disabled,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No subscribed baskets yet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
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
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.w),
            itemCount: baskets.length,
            itemBuilder: (context, index) {
              final basket = baskets[index];

              return BasketRaceCard(
                basket: basket,
                onTap: () => _showDetails(basket),
                isMarketOpen: _isMarketOpen,
                isSubscribed: true, // Always true for my baskets
                investedAmount: 0, // You can add investment tracking if needed
              );
            },
          );
        },
      ),
    );
  }
}