import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main/profile_screen.dart';
import 'basket_api_service.dart';
import 'basket_details_sheet.dart';
import 'basket_model.dart';
import 'package:classia_amc/themes/app_colors.dart';


class IntraBasketListScreen extends StatefulWidget {
  const IntraBasketListScreen({super.key});

  @override
  State<IntraBasketListScreen> createState() => _IntraBasketListScreenState();
}

class _IntraBasketListScreenState extends State<IntraBasketListScreen> {
  late final BasketApiService _service;
  late Future<List<Basket>> _futureBaskets;
  Future<List<Basket>>? _futureMyBaskets;
  final bool _isMarketOpen = true;

  int _currentIndex = 0; // 0 for INTRADAY, 1 for INTRAHOUR
  Set<int> _subscribedBasketIds = <int>{}; // Explicitly typed as Set<int>

  @override
  void initState() {
    super.initState();
    _service = BasketApiService();
    _subscribedBasketIds = <int>{}; // Explicitly initialize as Set<int>
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
        // Ensure we convert to Set<int> properly
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
    await _loadMyBaskets();
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
    final targetType = _currentIndex == 0 ? 'INTRADAY' : 'INTRAHOUR';
    return baskets.where((b) => b.type.toUpperCase() == targetType).toList();
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
                      icon: Icon(Icons.person, color: AppColors.primaryGold,),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      ),
                    ),

                    // Toggle Switch (Intraday / Intrahour)
                    Container(
                      height: 40.h,
                      width: 240.w,
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
                            left: _currentIndex == 0 ? 0 : 120.w,
                            child: Container(
                              width: 120.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGold,
                                    AppColors.primaryGold.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGold.withOpacity(0.4),
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
                                            Icons.flash_on,
                                            color: _currentIndex == 0
                                                ? AppColors.onPrimaryColor
                                                : AppColors.onPrimaryColor.withOpacity(0.6),
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Intraday',
                                            style: TextStyle(
                                              color: _currentIndex == 0
                                                  ? AppColors.onPrimaryColor
                                                  : AppColors.onPrimaryColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
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
                                            Icons.speed,
                                            color: _currentIndex == 1
                                                ? AppColors.onPrimaryColor
                                                : AppColors.onPrimaryColor.withOpacity(0.6),
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Intrahour',
                                            style: TextStyle(
                                              color: _currentIndex == 1
                                                  ? AppColors.onPrimaryColor
                                                  : AppColors.onPrimaryColor.withOpacity(0.6),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
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

                    // Info Icon
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: AppColors.onPrimaryColor,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        _showInfoDialog();
                      },
                      tooltip: 'Info',
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
                    AppColors.primaryGold.withOpacity(0.15),
                    AppColors.primaryGold.withOpacity(0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primaryGold.withOpacity(0.3),
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
                          _currentIndex == 0
                              ? 'Showing INTRADAY baskets - Same day buy & sell'
                              : 'Showing INTRAHOUR baskets - Quick trades within hours',
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
      color: AppColors.primaryGold,
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
                      color: AppColors.primaryGold,
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
                      _currentIndex == 0
                          ? 'No Intraday baskets available'
                          : 'No Intrahour baskets available',
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
              final investedAmount = 0.0; // You can add investment tracking if needed

              return IntraBasketCard(
                basket: basket,
                onTap: () => _showDetails(basket),
                isMarketOpen: _isMarketOpen,
                isSubscribed: isSubscribed,
                investedAmount: investedAmount,
                basketType: _currentIndex == 0 ? 'INTRADAY' : 'INTRAHOUR',
              );
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



class IntraBasketCard extends StatefulWidget {
  final Basket basket;
  final VoidCallback onTap;
  final bool isMarketOpen;
  final bool isSubscribed;
  final double investedAmount;
  final String basketType;

  const IntraBasketCard({
    super.key,
    required this.basket,
    required this.onTap,
    required this.isMarketOpen,
    required this.isSubscribed,
    required this.investedAmount,
    required this.basketType,
  });

  @override
  State<IntraBasketCard> createState() => _IntraBasketCardState();
}
// IntraBasketCard - Updated _IntraBasketCardState class
class _IntraBasketCardState extends State<IntraBasketCard> with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _updateHorseAnimation();
    _horseController.forward();
  }

  void _updateHorseAnimation() {
    // Get the actual performance value (can be negative or positive)
    final double performance = widget.basket.performanceValue;

    // Map performance to 0-10 scale where:
    // performance = 0 → racePosition = 0 (start)
    // performance = 10 → racePosition = 1.0 (end)
    // performance = -10 → racePosition = 0 (start, but will show red)

    // Clamp the performance between -10 and +10, then normalize to 0-1
    double racePosition = (performance.abs() / 10).clamp(0.0, 1.0);

    _horseAnimation = Tween<double>(begin: 0, end: racePosition).animate(
      CurvedAnimation(parent: _horseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(IntraBasketCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.basket.currentPriceValue != widget.basket.currentPriceValue ||
        oldWidget.basket.initialPriceValue != widget.basket.initialPriceValue ||
        oldWidget.basket.expectedReturnValue != widget.basket.expectedReturnValue) {
      _updateHorseAnimation();
      _horseController.reset();
      _horseController.forward();
    }
  }

  @override
  void dispose() {
    _horseController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    return widget.basketType == 'INTRADAY' ? AppColors.warning : AppColors.error;
  }

  Color _volatilityColor(String vol) {
    return switch (vol.toUpperCase()) {
      'LOW' => AppColors.success.withOpacity(0.2),
      'MID' => AppColors.warning.withOpacity(0.2),
      'HIGH' => AppColors.error.withOpacity(0.2),
      _ => AppColors.disabled.withOpacity(0.2),
    };
  }

  Color _volatilityTextColor(String vol) {
    return switch (vol.toUpperCase()) {
      'LOW' => AppColors.success,
      'MID' => AppColors.warning,
      'HIGH' => AppColors.error,
      _ => AppColors.secondaryText,
    };
  }

  Color _actionBgColor(String action) {
    return action.toUpperCase() == 'BUY'
        ? AppColors.success.withOpacity(0.15)
        : AppColors.error.withOpacity(0.15);
  }

  Color _actionTextColor(String action) {
    return action.toUpperCase() == 'BUY' ? AppColors.success : AppColors.error;
  }

  IconData _actionIcon(String action) {
    return action.toUpperCase() == 'BUY' ? Icons.arrow_upward : Icons.arrow_downward;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width - 48.w;
    final String action = widget.basket.action;
    final double performance = widget.basket.performanceValue;
    final bool isPositive = performance >= 0;

    // Determine race bar color based on positive/negative
    final Color raceBarColor = isPositive ? _getTypeColor() : AppColors.error;

    return Card(
      elevation: widget.isSubscribed ? 6 : 3,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
        side: BorderSide(
          color: widget.isSubscribed
              ? _getTypeColor()
              : _getTypeColor().withOpacity(0.25),
          width: widget.isSubscribed ? 2.5 : 1.2,
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: widget.onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Type Icon + Name + RA + Action Badge
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          widget.basketType == 'INTRADAY' ? Icons.flash_on : Icons.speed,
                          color: _getTypeColor(),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
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
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.headingText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.isSubscribed) ...[
                                  SizedBox(width: 8.w),
                                  Icon(Icons.verified, color: _getTypeColor(), size: 20.sp),
                                ],
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  'RA: ${widget.basket.raName}',
                                  style: TextStyle(fontSize: 12.sp, color: AppColors.secondaryText),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: _actionBgColor(action),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(color: _actionTextColor(action), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_actionIcon(action), color: _actionTextColor(action), size: 12.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        action.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _actionTextColor(action),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Price Information
                  Row(
                    children: [
                      Expanded(
                        child: _priceBox(
                          'Initial',
                          widget.basket.initialPriceValue > 0
                              ? '₹${widget.basket.initialPriceValue.toStringAsFixed(0)}'
                              : '₹0',
                          AppColors.primaryColor.withOpacity(0.12),
                          AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _priceBox(
                          'Current',
                          widget.basket.currentPriceValue > 0
                              ? '₹${widget.basket.currentPriceValue.toStringAsFixed(0)}'
                              : '₹0',
                          isPositive
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          isPositive ? AppColors.success : AppColors.error,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.success.withOpacity(0.12)
                              : AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isPositive ? AppColors.success : AppColors.error,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive ? Icons.trending_up : Icons.trending_down,
                                  color: isPositive ? AppColors.success : AppColors.error,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${performance.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: isPositive ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Change',
                              style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Horse Race Animation with 0-10 Scale
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background Track
                      Container(
                        width: cardWidth,
                        height: 10.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          color: raceBarColor.withOpacity(0.18),
                          border: Border.all(color: raceBarColor.withOpacity(0.4), width: 1.5),
                        ),
                      ),

                      // Progress Bar
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: _horseAnimation.value * cardWidth,
                            height: 10.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              gradient: LinearGradient(
                                colors: [raceBarColor, raceBarColor.withOpacity(0.7)],
                              ),
                            ),
                          );
                        },
                      ),

                      // Horse Animation
                      AnimatedBuilder(
                        animation: _horseAnimation,
                        builder: (context, child) {
                          final double horsePosition = _horseAnimation.value * cardWidth;
                          return Positioned(
                            left: (horsePosition - 30.w).clamp(0.0, cardWidth - 60.w),
                            top: -38.h,
                            child: Image.asset(
                              'assets/images/jt1.gif',
                              height: 60.h,
                              width: 70.w,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),

                      // Scale Labels (0 to 10)
                      Positioned(
                        bottom: -20.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0', style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
                            Text('2.5', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
                            Text('5', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
                            Text('7.5', style: TextStyle(fontSize: 9.sp, color: AppColors.secondaryText)),
                            Text('10', style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h), // Extra space for scale labels

                  // Invested Amount
                  if (widget.isSubscribed && widget.investedAmount > 0) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getTypeColor().withOpacity(0.15),
                            _getTypeColor().withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: _getTypeColor().withOpacity(0.4), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: _getTypeColor(), size: 20.sp),
                          SizedBox(width: 10.w),
                          Text('Total Invested: ', style: TextStyle(fontSize: 13.sp, color: AppColors.secondaryText)),
                          Text(
                            '₹${widget.investedAmount.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _getTypeColor()),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Chips
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      _miniChip(widget.basket.subscryptionType, AppColors.primaryColor.withOpacity(0.12), AppColors.primaryColor),
                      _miniChip(widget.basket.volatility, _volatilityColor(widget.basket.volatility), _volatilityTextColor(widget.basket.volatility)),
                      if (!widget.basket.isFree)
                        _miniChip('₹${widget.basket.subscriptionAmountValue.toString()}', _getTypeColor().withOpacity(0.12), _getTypeColor()),
                      _miniChip('${widget.basket.holdingsCount} Holdings', AppColors.accent.withOpacity(0.12), AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),

            // Subscribed Badge
            if (widget.isSubscribed)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getTypeColor(),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.onPrimaryColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('Subscribed', style: TextStyle(color: AppColors.onPrimaryColor, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _priceBox(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.secondaryText)),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _miniChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}