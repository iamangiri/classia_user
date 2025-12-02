import 'package:flutter/material.dart';
import 'dart:ui';
import '../../screenutills/fund_card_items.dart';
import '../../service/apiservice/market_service.dart';
import '../../themes/app_colors.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/custom_app_bar.dart';
import '../market/market_stock_screen.dart';
import '../sip/sip_animated_horse_widget.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with TickerProviderStateMixin {
  String _searchQuery = '';

  // Tab Controller
  late TabController _tabController;

  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start search animation
    _searchAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  String _mapCategory(int catgId, int subCatgId, String planName) {
    // Basic mapping based on catgId; enhance with name checks for Hybrid/Tax Saving
    switch (catgId) {
      case 1:
        if (planName.toLowerCase().contains('balanced') || planName.toLowerCase().contains('hybrid')) {
          return 'Hybrid';
        } else if (planName.toLowerCase().contains('elss') || planName.toLowerCase().contains('tax')) {
          return 'Tax Saving';
        }
        return 'Equity';
      case 2:
        return 'Debt';
      case 3:
        return 'Debt'; // Liquid/Overnight treated as Debt
      default:
        return 'Equity';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Market',
      ),
      backgroundColor: AppColors.screenBackground ?? Colors.white,
      body: Column(
        children: [
          // Custom Tab Bar
          _buildCustomTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Mutual Fund Tab
                _buildMutualFundTab(),

                // Stock Market Tab
                StockMarketScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGold ?? const Color(0xFFDAA520),
              (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.primaryText ?? Colors.black87,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.primaryText ?? Colors.black87,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, size: 20),
                const SizedBox(width: 8),
                Text('Mutual Funds'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.show_chart, size: 20),
                const SizedBox(width: 8),
                Text('Stock Market'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMutualFundTab() {
    return CustomScrollView(
      slivers: [
        // Search Bar Section
        SliverToBoxAdapter(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(_searchAnimation),
            child: FadeTransition(
              opacity: _searchAnimation,
              child: _buildSearchSection(),
            ),
          ),
        ),

        // Funds List
        SliverToBoxAdapter(
          child: FutureBuilder<Map<String, dynamic>>(
            future: MarketService.getMutualFunds(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              } else if (snapshot.hasError) {
                print('FutureBuilder Error: ${snapshot.error}');
                return _buildErrorState(snapshot.error.toString());
              } else if (!snapshot.hasData || !snapshot.data!['status']) {
                print('No data or status false: ${snapshot.data}');
                return _buildEmptyState(message: 'API returned no data or invalid status. Check logs for details.');
              }

              final apiData = snapshot.data!;
              final List<dynamic>? mfList = apiData['data']?['mfList'];
              if (mfList == null || mfList.isEmpty) {
                print('mfList is null or empty: $mfList');
                return _buildEmptyState(message: 'No funds in API response. Check if token is valid.');
              }

              print('Processing ${mfList.length} funds from API');

              final List<Map<String, dynamic>> funds = mfList.map((dynamic item) {
                final fund = item as Map<String, dynamic>;
                return {
                  'name': fund['planName'] ?? '',
                  'category': _mapCategory(
                    fund['catgId'] ?? 0,
                    fund['subCatgId'] ?? 0,
                    fund['planName'] ?? '',
                  ),
                  'amc': fund['amc'] ?? '',
                  'schemeCode': fund['schemeCode'] ?? '',
                  'planType': fund['planType'] ?? '',
                  'oneYearChange': fund['oneYearChange'] ?? 0,
                  'threeYearsChange': fund['threeYearsChange'] ?? 0,
                  'fiveYearsChange': fund['fiveYearsChange'] ?? 0,
                  'id': fund['id'] ?? 0,
                  'priIsin': fund['priIsin'] ?? '',
                  'exitLoad': fund['exitLoad'] ?? '',
                  'sipAllowed': fund['sipAllowed'] ?? false,
                };
              }).toList();

              final filteredFunds = funds
                  .where((fund) =>
              _searchQuery.isEmpty ||
                  fund['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

              if (filteredFunds.isEmpty) {
                return _buildEmptyState();
              }

              return _buildFundsList(filteredFunds);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFundsList(List<Map<String, dynamic>> funds) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGold ?? const Color(0xFFDAA520),
                        (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mutual Funds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText ?? Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '${funds.length} funds available',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText ?? Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List of Funds
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: funds.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 100)),
                builder: (context, double animValue, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - animValue)),
                    child: Opacity(
                      opacity: animValue,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {},
                          child: FundCard(
                            fund: funds[index],
                            isDarkMode: false,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                border: Border.all(
                  color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search your perfect fund...',
                  hintStyle: TextStyle(
                    color: AppColors.secondaryText?.withOpacity(0.8) ?? Colors.grey.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      size: 24,
                    ),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
                ),
                style: TextStyle(
                  color: AppColors.primaryText ?? Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedHorseWidget(),
            Text(
              'Loading amazing funds...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (AppColors.error ?? Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error ?? Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 4,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.1),
                    (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Funds Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  message ??
                      'Try adjusting your search query\nto discover amazing investment opportunities',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.secondaryText ?? Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {
                _searchQuery = '';
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
              ),
              child: const Text(
                'Reset Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {}),
              child: Text(
                'Retry Loading',
                style: TextStyle(
                  color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}