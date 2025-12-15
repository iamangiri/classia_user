import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main/profile_screen.dart';
import 'basket_api_service.dart';
import 'basket_details_sheet.dart';
import 'basket_model.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'basket_race_card.dart';
import 'intra_basket_card.dart';
import 'basket_list_screen.dart';

class MyBasketScreen extends StatefulWidget {
  const MyBasketScreen({super.key});

  @override
  State<MyBasketScreen> createState() => _MyBasketScreenState();
}

class _MyBasketScreenState extends State<MyBasketScreen> {
  late final BasketApiService _service;
  late Future<List<Basket>> _futureMyBaskets;
  final bool _isMarketOpen = true;

  @override
  void initState() {
    super.initState();
    _service = BasketApiService();
    _loadMyBaskets();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMyBaskets() async {
    setState(() {
      _futureMyBaskets = _service.fetchMyBaskets();
    });
  }

  Future<void> _refresh() async {
    await _loadMyBaskets();
  }

  void _showDetails(Basket basket) {
    final double investedAmount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BasketDetailSheet(
        basket: basket,
        isSubscribed: true,
        investedAmount: investedAmount,
        onSubscribe: () {
          // Already subscribed, no action needed
        },
        onInvest: (amount) {
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
      ),
    );
  }

  // ✅ Navigate to BasketListScreen with showBackButton = true
  void _navigateToBrowseBaskets() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BasketListScreen(showBackButton: true),
      ),
    );

    // Refresh when coming back
    if (result == true) {
      _refresh();
    }
  }

  // Categorize baskets by type
  Map<String, List<Basket>> _categorizeBaskets(List<Basket> baskets) {
    Map<String, List<Basket>> categorized = {
      'DELIVERY': [],
      'INTRADAY': [],
      'INTRAHOUR': [],
    };

    for (var basket in baskets) {
      String type = basket.type.toUpperCase();
      if (categorized.containsKey(type)) {
        categorized[type]!.add(basket);
      }
    }

    return categorized;
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'DELIVERY':
        return AppColors.primaryGold;
      case 'INTRADAY':
        return AppColors.warning;
      case 'INTRAHOUR':
        return AppColors.error;
      default:
        return AppColors.primaryGold;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'DELIVERY':
        return Icons.trending_up;
      case 'INTRADAY':
        return Icons.flash_on;
      case 'INTRAHOUR':
        return Icons.speed;
      default:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        title: const Text('My Baskets'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.person, color: AppColors.primaryGold),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.onPrimaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.onPrimaryColor),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Market Status Banner
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
                        ? 'Live Market: Your subscribed baskets'
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

          // Basket List
          Expanded(
            child: _buildMyBasketsList(),
          ),
        ],
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryGold,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading your baskets...',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
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
                    'Error loading baskets',
                    style: TextStyle(
                      color: AppColors.headingText,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: Icon(Icons.refresh, size: 18.sp),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.onPrimaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
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
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Subscribe to baskets to see them here',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: _navigateToBrowseBaskets, // ✅ Updated
                    icon: Icon(Icons.explore, size: 18.sp),
                    label: const Text('Browse Baskets'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.onPrimaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Categorize baskets
          final categorizedBaskets = _categorizeBaskets(baskets);

          return ListView(
            padding: EdgeInsets.all(12.w),
            children: [
              // Summary Card
              Container(
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withOpacity(0.15),
                      AppColors.primaryGold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem(
                      'Total',
                      baskets.length.toString(),
                      Icons.shopping_basket,
                      AppColors.primaryGold,
                    ),
                    _summaryItem(
                      'Delivery',
                      categorizedBaskets['DELIVERY']!.length.toString(),
                      Icons.trending_up,
                      AppColors.primaryGold,
                    ),
                    _summaryItem(
                      'Intraday',
                      categorizedBaskets['INTRADAY']!.length.toString(),
                      Icons.flash_on,
                      AppColors.warning,
                    ),
                    _summaryItem(
                      'Intrahour',
                      categorizedBaskets['INTRAHOUR']!.length.toString(),
                      Icons.speed,
                      AppColors.error,
                    ),
                  ],
                ),
              ),

              // Display baskets by category
              ...categorizedBaskets.entries.expand((entry) {
                final type = entry.key;
                final basketList = entry.value;

                if (basketList.isEmpty) return <Widget>[];

                return [
                  // Category Header
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            _getTypeIcon(type),
                            color: _getTypeColor(type),
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '$type (${basketList.length})',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 1.5,
                          width: 100.w,
                          color: _getTypeColor(type).withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),

                  // Category Baskets
                  ...basketList.map((basket) {
                    final investedAmount = 0.0;

                    if (type == 'DELIVERY') {
                      return BasketRaceCard(
                        basket: basket,
                        onTap: () => _showDetails(basket),
                        isMarketOpen: _isMarketOpen,
                        isSubscribed: true,
                        investedAmount: investedAmount,
                      );
                    } else {
                      return IntraBasketCard(
                        basket: basket,
                        onTap: () => _showDetails(basket),
                        isMarketOpen: _isMarketOpen,
                        isSubscribed: true,
                        investedAmount: investedAmount,
                        basketType: type,
                      );
                    }
                  }).toList(),

                  SizedBox(height: 8.h),
                ];
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}