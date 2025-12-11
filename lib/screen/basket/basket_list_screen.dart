// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../main/profile_screen.dart';
// import 'basket_api_service.dart';
// import 'basket_details_sheet.dart';
// import 'basket_model.dart';
// import 'package:classia_amc/themes/app_colors.dart';
// import 'basket_race_card.dart';
//
// class BasketListScreen extends StatefulWidget {
//   const BasketListScreen({super.key});
//
//   @override
//   State<BasketListScreen> createState() => _BasketListScreenState();
// }
//
// class _BasketListScreenState extends State<BasketListScreen>
//     with SingleTickerProviderStateMixin {
//   late final BasketApiService _service;
//   late Future<List<Basket>> _futureBaskets;
//   Future<List<Basket>>? _futureMyBaskets;
//   final bool _isMarketOpen = true;
//
//   late TabController _tabController;
//   Set<int> _subscribedBasketIds = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _service = BasketApiService();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.addListener(_onTabChanged);
//     _futureBaskets = _service.fetchBaskets();
//     _loadMyBaskets();
//   }
//
//   @override
//   void dispose() {
//     _tabController.removeListener(_onTabChanged);
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   void _onTabChanged() {
//     if (_tabController.index == 1) {
//       _loadMyBaskets();
//     }
//   }
//
//   Future<void> _loadMyBaskets() async {
//     setState(() {
//       _futureMyBaskets = _service.fetchMyBaskets();
//     });
//
//     // Update subscribed basket IDs for the "All Baskets" tab
//     try {
//       final myBaskets = await _futureMyBaskets!;
//       setState(() {
//         _subscribedBasketIds = myBaskets.map((b) => b.id).toSet();
//       });
//     } catch (e) {
//       print('Error loading my baskets: $e');
//     }
//   }
//
//   Future<void> _subscribeBasket(Basket basket) async {
//     setState(() {
//       _subscribedBasketIds.add(basket.id);
//     });
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('✓ Subscribed to ${basket.basketName}'),
//           backgroundColor: AppColors.success,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//         ),
//       );
//     }
//
//     // Refresh my baskets list
//     _loadMyBaskets();
//   }
//
//   Future<void> _unsubscribeBasket(int basketId) async {
//     setState(() {
//       _subscribedBasketIds.remove(basketId);
//     });
//
//     // Refresh my baskets list
//     _loadMyBaskets();
//   }
//
//   Future<void> _refresh() async {
//     setState(() {
//       _futureBaskets = _service.fetchBaskets();
//     });
//
//     if (_tabController.index == 1) {
//       _loadMyBaskets();
//     } else {
//       // Still load my baskets in background to update subscription status
//       _loadMyBaskets();
//     }
//   }
//
//   void _showDetails(Basket basket) {
//     final bool isSubscribed = _subscribedBasketIds.contains(basket.id);
//     final double investedAmount = 0; // You can add investment tracking if needed
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => BasketDetailSheet(
//         basket: basket,
//         isSubscribed: isSubscribed,
//         investedAmount: investedAmount,
//         onSubscribe: () => _subscribeBasket(basket),
//         onInvest: (amount) {
//           // Handle investment if needed
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('✓ Invested ₹${amount.toStringAsFixed(0)} in ${basket.basketName}'),
//                 backgroundColor: AppColors.success,
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//               ),
//             );
//           }
//         },
//         onUnsubscribe: () => _unsubscribeBasket(basket.id),
//       ),
//     );
//   }
//
//   List<Basket> _filterBaskets(List<Basket> baskets) {
//     return baskets.where((b) => b.isDeliveryType).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.screenBackground,
//       appBar: AppBar(
//         title: const Text('Classia Baskets'),
//         centerTitle: true,
//         elevation: 0,
//         leading: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: Icon(Icons.person, color: AppColors.primaryGold),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ProfileScreen()),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: AppColors.primaryColor,
//         foregroundColor: AppColors.onPrimaryColor,
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(50.h),
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.primaryColor.withOpacity(0.1),
//               border: Border(
//                 top: BorderSide(
//                   color: AppColors.primaryGold.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: TabBar(
//               controller: _tabController,
//               indicatorColor: AppColors.primaryGold,
//               indicatorWeight: 3,
//               labelColor: AppColors.primaryGold,
//               unselectedLabelColor: AppColors.onPrimaryColor.withOpacity(0.6),
//               labelStyle: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//               tabs: [
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.grid_view, size: 18.sp),
//                       SizedBox(width: 6.w),
//                       const Text('All Baskets'),
//                     ],
//                   ),
//                 ),
//                 Tab(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.account_balance_wallet, size: 18.sp),
//                       SizedBox(width: 6.w),
//                       const Text('My Baskets'),
//                       if (_subscribedBasketIds.isNotEmpty)
//                         Container(
//                           margin: EdgeInsets.only(left: 6.w),
//                           padding: EdgeInsets.all(4.w),
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryGold,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Text(
//                             '${_subscribedBasketIds.length}',
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               color: AppColors.onPrimaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//             decoration: BoxDecoration(
//               color: AppColors.primaryGold.withOpacity(0.1),
//               border: Border(
//                 bottom: BorderSide(
//                   color: AppColors.primaryGold.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _isMarketOpen ? Icons.circle : Icons.access_time,
//                   color: _isMarketOpen ? AppColors.success : AppColors.warning,
//                   size: 16.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     _isMarketOpen
//                         ? 'Live Market: Showing DELIVERY type baskets only'
//                         : 'Market Closed: Showing last closing value',
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: AppColors.primaryText,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildAllBasketsList(),
//                 _buildMyBasketsList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAllBasketsList() {
//     return RefreshIndicator(
//       onRefresh: _refresh,
//       color: AppColors.primaryGold,
//       child: FutureBuilder<List<Basket>>(
//         future: _futureBaskets,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primaryGold,
//               ),
//             );
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64.sp,
//                     color: AppColors.error,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'Error: ${snapshot.error}',
//                     style: TextStyle(color: AppColors.errorColor),
//                   ),
//                   SizedBox(height: 16.h),
//                   ElevatedButton(
//                     onPressed: _refresh,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryGold,
//                     ),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final baskets = _filterBaskets(snapshot.data!);
//
//           if (baskets.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.inbox_outlined,
//                     size: 80.sp,
//                     color: AppColors.disabled,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'No DELIVERY baskets found',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: AppColors.secondaryText,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: EdgeInsets.all(12.w),
//             itemCount: baskets.length,
//             itemBuilder: (context, index) {
//               final basket = baskets[index];
//               final isSubscribed = _subscribedBasketIds.contains(basket.id);
//
//               return BasketRaceCard(
//                 basket: basket,
//                 onTap: () => _showDetails(basket),
//                 isMarketOpen: _isMarketOpen,
//                 isSubscribed: isSubscribed,
//                 investedAmount: 0,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildMyBasketsList() {
//     return RefreshIndicator(
//       onRefresh: _refresh,
//       color: AppColors.primaryGold,
//       child: FutureBuilder<List<Basket>>(
//         future: _futureMyBaskets,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primaryGold,
//               ),
//             );
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64.sp,
//                     color: AppColors.error,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'Error: ${snapshot.error}',
//                     style: TextStyle(color: AppColors.errorColor),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 16.h),
//                   ElevatedButton(
//                     onPressed: _refresh,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryGold,
//                     ),
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final baskets = snapshot.data ?? [];
//
//           if (baskets.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_basket_outlined,
//                     size: 80.sp,
//                     color: AppColors.disabled,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'No subscribed baskets yet',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: AppColors.secondaryText,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   TextButton(
//                     onPressed: () => _tabController.animateTo(0),
//                     child: Text(
//                       'Browse All Baskets',
//                       style: TextStyle(
//                         color: AppColors.primaryGold,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: EdgeInsets.all(12.w),
//             itemCount: baskets.length,
//             itemBuilder: (context, index) {
//               final basket = baskets[index];
//
//               return BasketRaceCard(
//                 basket: basket,
//                 onTap: () => _showDetails(basket),
//                 isMarketOpen: _isMarketOpen,
//                 isSubscribed: true, // Always true for my baskets
//                 investedAmount: 0, // You can add investment tracking if needed
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main/profile_screen.dart';
import 'basket_api_service.dart';
import 'basket_details_sheet.dart';
import 'basket_model.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'basket_race_card.dart';
import 'intra_basket_card.dart';

class BasketListScreen extends StatefulWidget {
  const BasketListScreen({super.key});

  @override
  State<BasketListScreen> createState() => _BasketListScreenState();
}

class _BasketListScreenState extends State<BasketListScreen> {
  late final BasketApiService _service;
  late Future<List<Basket>> _futureBaskets;
  Future<List<Basket>>? _futureMyBaskets;
  final bool _isMarketOpen = true;

  int _currentIndex = 0; // 0 for DELIVERY, 1 for INTRADAY, 2 for INTRAHOUR
  Set<int> _subscribedBasketIds = <int>{};

  @override
  void initState() {
    super.initState();
    _service = BasketApiService();
    _subscribedBasketIds = <int>{};
    _futureBaskets = _service.fetchBaskets();
    _loadMyBaskets();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMyBaskets() async {
    try {
      final myBaskets = await _service.fetchMyBaskets();
      setState(() {
        _futureMyBaskets = Future.value(myBaskets);
        _subscribedBasketIds = myBaskets.map((b) => b.id).toSet();
      });
    } catch (e) {
      print('Error loading my baskets: $e');
      setState(() {
        _futureMyBaskets = Future.error(e);
        _subscribedBasketIds = {};
      });
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

    _loadMyBaskets();
  }

  Future<void> _unsubscribeBasket(int basketId) async {
    setState(() {
      _subscribedBasketIds.remove(basketId);
    });

    _loadMyBaskets();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureBaskets = _service.fetchBaskets();
    });
    await _loadMyBaskets();
  }

  void _showDetails(Basket basket) {
    final bool isSubscribed = _subscribedBasketIds.contains(basket.id);
    final double investedAmount = 0;

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
    switch (_currentIndex) {
      case 0: // DELIVERY
        return baskets.where((b) => b.type.toUpperCase() == 'DELIVERY').toList();
      case 1: // INTRADAY
        return baskets.where((b) => b.type.toUpperCase() == 'INTRADAY').toList();
      case 2: // INTRAHOUR
        return baskets.where((b) => b.type.toUpperCase() == 'INTRAHOUR').toList();
      default:
        return baskets;
    }
  }

  String _getCurrentTypeLabel() {
    switch (_currentIndex) {
      case 0:
        return 'DELIVERY';
      case 1:
        return 'INTRADAY';
      case 2:
        return 'INTRAHOUR';
      default:
        return 'DELIVERY';
    }
  }

  String _getTypeDescription() {
    switch (_currentIndex) {
      case 0:
        return 'Long-term investment baskets';
      case 1:
        return 'Same day buy & sell';
      case 2:
        return 'Quick trades within hours';
      default:
        return '';
    }
  }

  Color _getTypeColor() {
    switch (_currentIndex) {
      case 0:
        return AppColors.primaryGold;
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.error;
      default:
        return AppColors.primaryGold;
    }
  }

  IconData _getTypeIcon() {
    switch (_currentIndex) {
      case 0:
        return Icons.trending_up;
      case 1:
        return Icons.flash_on;
      case 2:
        return Icons.speed;
      default:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: CustomScrollView(
        slivers: [
          // Custom AppBar
          SliverAppBar(
            toolbarHeight: 70.h,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            elevation: 2,
            flexibleSpace: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Button
                    IconButton(
                      icon: Icon(Icons.person, color: AppColors.primaryGold),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      ),
                    ),

                    // Toggle Switch (Delivery / Intraday / Intrahour)
                    Container(
                      height: 40.h,
                      width: 300.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: _currentIndex == 0 ? 0 : (_currentIndex == 1 ? 100.w : 200.w),
                            child: Container(
                              width: 100.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getTypeColor(),
                                    _getTypeColor().withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getTypeColor().withOpacity(0.4),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _currentIndex = 0),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            color: _currentIndex == 0
                                                ? AppColors.onPrimaryColor
                                                : AppColors.onPrimaryColor.withOpacity(0.6),
                                            size: 14.sp,
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            'Delivery',
                                            style: TextStyle(
                                              color: _currentIndex == 0
                                                  ? AppColors.onPrimaryColor
                                                  : AppColors.onPrimaryColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _currentIndex = 1),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.flash_on,
                                            color: _currentIndex == 1
                                                ? AppColors.onPrimaryColor
                                                : AppColors.onPrimaryColor.withOpacity(0.6),
                                            size: 14.sp,
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            'Intraday',
                                            style: TextStyle(
                                              color: _currentIndex == 1
                                                  ? AppColors.onPrimaryColor
                                                  : AppColors.onPrimaryColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _currentIndex = 2),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.speed,
                                            color: _currentIndex == 2
                                                ? AppColors.onPrimaryColor
                                                : AppColors.onPrimaryColor.withOpacity(0.6),
                                            size: 14.sp,
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            'Intrahour',
                                            style: TextStyle(
                                              color: _currentIndex == 2
                                                  ? AppColors.onPrimaryColor
                                                  : AppColors.onPrimaryColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),

          // Market Status Banner
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getTypeColor().withOpacity(0.15),
                    _getTypeColor().withOpacity(0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: _getTypeColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: _isMarketOpen
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isMarketOpen ? Icons.circle : Icons.access_time,
                      color: _isMarketOpen ? AppColors.success : AppColors.warning,
                      size: 12.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isMarketOpen ? 'Market Open' : 'Market Closed',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingText,
                          ),
                        ),
                        Text(
                          'Showing ${_getCurrentTypeLabel()} baskets - ${_getTypeDescription()}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Basket List
          SliverToBoxAdapter(
            child: _buildBasketList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketList() {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: _getTypeColor(),
      child: FutureBuilder<List<Basket>>(
        future: _futureBaskets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: _getTypeColor(),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading baskets...',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
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
                        backgroundColor: _getTypeColor(),
                        foregroundColor: AppColors.onPrimaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final baskets = _filterBaskets(snapshot.data!);

          if (baskets.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
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
                      'No ${_getCurrentTypeLabel()} baskets available',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check back later for new opportunities',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(12.w),
            itemCount: baskets.length,
            itemBuilder: (context, index) {
              final basket = baskets[index];
              final isSubscribed = _subscribedBasketIds.contains(basket.id);
              final investedAmount = 0.0;

              // Use different card based on type
              if (_currentIndex == 0) {
                // DELIVERY type - use BasketRaceCard
                return BasketRaceCard(
                  basket: basket,
                  onTap: () => _showDetails(basket),
                  isMarketOpen: _isMarketOpen,
                  isSubscribed: isSubscribed,
                  investedAmount: investedAmount,
                );
              } else {
                // INTRADAY or INTRAHOUR - use IntraBasketCard
                return IntraBasketCard(
                  basket: basket,
                  onTap: () => _showDetails(basket),
                  isMarketOpen: _isMarketOpen,
                  isSubscribed: isSubscribed,
                  investedAmount: investedAmount,
                  basketType: _getCurrentTypeLabel(),
                );
              }
            },
          );
        },
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryGold, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Basket Types',
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
            _infoItem(
              Icons.trending_up,
              'Delivery',
              'Long-term investment baskets for holding positions over multiple days.',
              AppColors.primaryGold,
            ),
            SizedBox(height: 16.h),
            _infoItem(
              Icons.flash_on,
              'Intraday',
              'Buy and sell on the same trading day. Positions must be closed before market closes.',
              AppColors.warning,
            ),
            SizedBox(height: 16.h),
            _infoItem(
              Icons.speed,
              'Intrahour',
              'Ultra-fast trades completed within hours. High-frequency trading opportunities.',
              AppColors.error,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
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

  Widget _infoItem(IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}