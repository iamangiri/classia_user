import 'package:classia_amc/screen/market/market_stock_chart_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../../themes/app_colors.dart';
import '../../utills/constent/market_stock_list.dart';


class StockMarketScreen extends StatefulWidget {
  @override
  _StockMarketScreenState createState() => _StockMarketScreenState();
}

class _StockMarketScreenState extends State<StockMarketScreen> with TickerProviderStateMixin {
  String _selectedExchange = 'All';
  final List<String> _exchanges = ['All', 'NSE', 'BSE'];
  String _searchQuery = '';
  final Random _random = Random();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  // Generate random stock price data for demo
  Map<String, dynamic> _generateStockData(Map<String, String> stock) {
    final basePrice = 100 + _random.nextDouble() * 2000;
    final changePercent = (_random.nextDouble() - 0.5) * 10;
    final isPositive = changePercent >= 0;

    return {
      ...stock,
      'price': basePrice.toStringAsFixed(2),
      'change': changePercent.toStringAsFixed(2),
      'isPositive': isPositive,
      'volume': '${(_random.nextInt(900) + 100)}K',
      'high': (basePrice + _random.nextDouble() * 50).toStringAsFixed(2),
      'low': (basePrice - _random.nextDouble() * 50).toStringAsFixed(2),
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredStocks = MarketStockList.companies
        .where((stock) =>
    _searchQuery.isEmpty ||
        stock['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        stock['symbol']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .where((stock) => _selectedExchange == 'All' || stock['exchange'] == _selectedExchange)
        .map((stock) => _generateStockData(stock))
        .toList();

    return CustomScrollView(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSearchSection(),
          ),
        ),

        // Exchange Filter
        SliverToBoxAdapter(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(-0.5, 0),
              end: Offset.zero,
            ).animate(_fadeAnimation),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildExchangeFilter(),
            ),
          ),
        ),

        // Market Overview Cards
        SliverToBoxAdapter(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_fadeAnimation),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildMarketOverview(),
            ),
          ),
        ),

        // Stocks List
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (filteredStocks.isEmpty) {
                return _buildEmptyState();
              }

              return AnimatedBuilder(
                animation: _listAnimationController,
                builder: (context, child) {
                  // Calculate animation delay with a maximum limit to prevent blur effect
                  final delayFactor = (index * 0.05).clamp(0.0, 0.5);
                  final animationValue = Curves.easeOutCubic.transform(
                    (_listAnimationController.value - delayFactor).clamp(0.0, 1.0),
                  );

                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - animationValue)),
                    child: Opacity(
                      opacity: animationValue,
                      child: _buildStockCard(filteredStocks[index], index),
                    ),
                  );
                },
              );
            },
            childCount: filteredStocks.isEmpty ? 1 : filteredStocks.length,
          ),
        ),

        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
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
                  hintText: 'Search stocks by name or symbol...',
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

  Widget _buildExchangeFilter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Exchange',
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
              children: _exchanges.asMap().entries.map((entry) {
                final index = entry.key;
                final exchange = entry.value;
                final isSelected = _selectedExchange == exchange;

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
                                onTap: () => setState(() => _selectedExchange = exchange),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Text(
                                    exchange,
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

  Widget _buildMarketOverview() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Market Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildOverviewCard('NIFTY 50', '19,435.25', '+125.30', '+0.65%', true)),
              SizedBox(width: 12),
              Expanded(child: _buildOverviewCard('SENSEX', '65,512.10', '-89.45', '-0.14%', false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String index, String value, String change, String changePercent, bool isPositive) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText ?? Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              SizedBox(width: 4),
              Text(
                '$change ($changePercent)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock, int index) {
    final isPositive = stock['isPositive'] as bool;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
          color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Handle stock tap - navigate to stock details
            _showStockDetails(stock);
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Company Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGold ?? Color(0xFFDAA520),
                            (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          stock['name']!.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // Company Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText ?? Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                stock['symbol']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryText ?? Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stock['exchange'] == 'NSE'
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  stock['exchange']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: stock['exchange'] == 'NSE' ? Colors.blue : Colors.purple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${stock['price']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText ?? Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 14,
                              color: changeColor,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${stock['change']}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: changeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Additional Stock Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStockInfo('Volume', stock['volume']!),
                    _buildStockInfo('High', '₹${stock['high']}'),
                    _buildStockInfo('Low', '₹${stock['low']}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText ?? Colors.grey[600],
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
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
              'No Stocks Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search query or filters',
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
                _selectedExchange = 'All';
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

  void _showStockDetails(Map<String, dynamic> stock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Stock details content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold ?? Color(0xFFDAA520),
                                  (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                stock['name']!.substring(0, 2).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stock['name']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText ?? Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${stock['symbol']} • ${stock['exchange']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondaryText ?? Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Price Section
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
                              (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Price',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText ?? Colors.black87,
                                  ),
                                ),
                                Text(
                                  '₹${stock['price']}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText ?? Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondaryText ?? Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      stock['isPositive'] ? Icons.trending_up : Icons.trending_down,
                                      size: 20,
                                      color: stock['isPositive'] ? Colors.green : Colors.red,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${stock['change']}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: stock['isPositive'] ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // Stock Stats
                      Text(
                        'Stock Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText ?? Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStockInfo('Day High', '₹${stock['high']}'),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailStockInfo('Day Low', '₹${stock['low']}'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailStockInfo('Volume', stock['volume']!),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailStockInfo('Exchange', stock['exchange']!),
                          ),
                        ],
                      ),

                      SizedBox(height: 32),

                      // Action Buttons
                      Column(
                        children: [
                          // View Chart Button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigate to TradeChartScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MarketStockChartScreen(
                                      exchange: stock['exchange']!,
                                      symbol: stock['symbol']!,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.trending_up_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: Text(
                                'View Chart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                elevation: 4,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Handle buy action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    elevation: 4,
                                  ),
                                  child: Text(
                                    'Buy',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Handle sell action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    elevation: 4,
                                  ),
                                  child: Text(
                                    'Sell',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 32), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStockInfo(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

