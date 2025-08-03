import 'package:flutter/material.dart';
import 'package:classia_amc/utills/constent/mutual_fond_data.dart';
import '../../screenutills/fund_card_items.dart';
import '../../themes/app_colors.dart';
import '../../widget/custom_app_bar.dart';
import '../market/all_fund_screen.dart';
import '../market/fund_deatils_screen.dart';
import 'dart:ui';
import '../sip/sip_animated_horse_widget.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with TickerProviderStateMixin {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Equity', 'Debt', 'Hybrid', 'Tax Saving'];
  String _searchQuery = '';

  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    _searchAnimationController.forward();
    Future.delayed(Duration(milliseconds: 200), () {
      _filterAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mutual Funds Market',
      ),
      backgroundColor: AppColors.screenBackground ?? Colors.white,
      body: CustomScrollView(
        slivers: [
          // Search Bar Section
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.5),
                end: Offset.zero,
              ).animate(_searchAnimation),
              child: FadeTransition(
                opacity: _searchAnimation,
                child: _buildSearchSection(),
              ),
            ),
          ),

          // Filter Chips Section
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(-0.5, 0),
                end: Offset.zero,
              ).animate(_filterAnimation),
              child: FadeTransition(
                opacity: _filterAnimation,
                child: _buildFilterSection(),
              ),
            ),
          ),

          // Fund Categories List
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: MutualFondData.mutualFunds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final funds = snapshot.data!
                    .where((fund) =>
                _searchQuery.isEmpty ||
                    fund['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
                    .where((fund) => _selectedFilter == 'All' || fund['category'] == _selectedFilter)
                    .toList();

                if (funds.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    _buildCategorySection('🚀 Top Performing', Icons.trending_up, 'Equity', funds, 0),
                    _buildCategorySection('📈 Equity Funds', Icons.show_chart, 'Equity', funds, 100),
                    _buildCategorySection('💰 Debt Funds', Icons.assessment, 'Debt', funds, 200),
                    _buildCategorySection('🛡️ Tax Saving', Icons.savings, 'Tax Saving', funds, 300),
                    _buildCategorySection('⚖️ Hybrid Funds', Icons.balance, 'Hybrid', funds, 400),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
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
              color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
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
                  color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.3),
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
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryGold ?? Color(0xFFDAA520),
                      size: 24,
                    ),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.primaryGold ?? Color(0xFFDAA520),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 4),
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

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText ?? Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final isSelected = _selectedFilter == filter;

                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          margin: EdgeInsets.only(right: 12),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                colors: [
                                  AppColors.primaryGold ?? Color(0xFFDAA520),
                                  (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                                ],
                              )
                                  : null,
                              color: isSelected
                                  ? null
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ]
                                  : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () => setState(() => _selectedFilter = filter),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.primaryText ?? Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      String category,
      IconData icon,
      String categoryFilter,
      List<Map<String, dynamic>> funds,
      int delayMs,
      ) {
    final categoryFunds = funds
        .where((fund) => fund['category'] == categoryFilter)
        .take(10)
        .toList();

    if (categoryFunds.isEmpty) return SizedBox.shrink();

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
                    padding: EdgeInsets.all(16),
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
                        color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGold ?? Color(0xFFDAA520),
                                (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText ?? Colors.black87,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${categoryFunds.length} funds available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText ?? Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGold ?? Color(0xFFDAA520),
                                (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        ViewAllFundsScreen(
                                          category: category,
                                          filterType: categoryFilter,
                                        ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOutCubic,
                                        )),
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    transitionDuration: Duration(milliseconds: 400),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cards Horizontal List
                  SizedBox(
                    height: 200, // Adjusted for the new card design
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryFunds.length,
                      separatorBuilder: (_, __) => SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          builder: (context, double animValue, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - animValue)),
                              child: Opacity(
                                opacity: animValue,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            FundDetailsScreen(
                                              fund: categoryFunds[index],
                                            ),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeInOutCubic,
                                            )),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        transitionDuration: Duration(milliseconds: 400),
                                      ),
                                    );
                                  },
                                  child: FundCard(
                                    fund: categoryFunds[index],
                                    isDarkMode: false,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedHorseWidget(), // Use the new widget

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
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
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
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText ?? Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
                    (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.primaryGold ?? Color(0xFFDAA520),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Funds Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search query\nto discover amazing investment opportunities',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText ?? Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {
                _searchQuery = '';
                _selectedFilter = 'All';
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
              ),
              child: Text(
                'Reset Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}