import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../service/apiservice/bajaj_api_service.dart';
import '../bajal-auth/bajal_login_screen.dart';
import 'package:go_router/go_router.dart';

class StockHoldingsScreen extends StatefulWidget {
  @override
  _StockHoldingsScreenState createState() => _StockHoldingsScreenState();
}

class _StockHoldingsScreenState extends State<StockHoldingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(Duration(milliseconds: 300));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Stock Holdings'),
      backgroundColor: AppColors.screenBackground ?? Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primaryGold ?? Color(0xFFDAA520),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: BajajApiService.getHoldings(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || _isRefreshing) {
                      return _buildLoadingState();
                    }

                    // Check for errors or no data (not logged in)
                    if (snapshot.hasError || !snapshot.hasData) {
                      return _buildErrorState(); // Shows "Login Required"
                    }

                    final apiData = snapshot.data!;

                    // Check if not logged in (error from API)
                    if (apiData['statusCode'] != 0) {
                      return _buildErrorState(); // Shows "Login Required"
                    }

                    // Check if data is null (logged in but no holdings)
                    if (apiData['data'] == null) {
                      return _buildEmptyState(); // Shows "No Holdings Yet"
                    }

                    final List<dynamic> holdings = apiData['data'] as List<dynamic>;

                    // Check if holdings list is empty
                    if (holdings.isEmpty) {
                      return _buildEmptyState(); // Shows "No Holdings Yet"
                    }

                    // Calculate totals
                    double totalInvested = 0;
                    double totalCurrent = 0;
                    double totalPNL = 0;

                    for (var h in holdings) {
                      final qty = (h['qty'] as num).toDouble();
                      final avgPrice = (h['avg_buy_price'] as num?)?.toDouble() ?? 0.0;
                      final ltp = _getLTP(h);
                      totalInvested += qty * avgPrice;
                      totalCurrent += qty * ltp;
                    }
                    totalPNL = totalCurrent - totalInvested;

                    return Column(
                      children: [
                        _buildPortfolioSummary(totalInvested, totalCurrent, totalPNL),
                        _buildHoldingsList(holdings),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getLTP(Map<String, dynamic> holding) {
    final nse = holding['nse_sec_info'] as Map<String, dynamic>?;
    final bse = holding['bse_sec_info'] as Map<String, dynamic>?;
    return (nse?['ltp'] as num?)?.toDouble() ??
        (bse?['ltp'] as num?)?.toDouble() ??
        0.0;
  }

  Widget _buildPortfolioSummary(double invested, double current, double pnl) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGold ?? Color(0xFFDAA520),
            (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart, color: Colors.white, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Value',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${_formatCurrency(current)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Invested', invested, Colors.white70),
              Container(width: 1, height: 40, color: Colors.white30),
              _summaryItem('P&L', pnl, pnl >= 0 ? Colors.green[100]! : Colors.red[100]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
        SizedBox(height: 6),
        Text(
          '${value >= 0 ? '+' : ''}₹${_formatCurrency(value.abs())}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingsList(List<dynamic> holdings) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
            child: Text(
              'Your Holdings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: holdings.length,
            itemBuilder: (context, index) {
              final holding = holdings[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 500 + (index * 100)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(30 * (1 - value), 0),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _buildHoldingCard(holding),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(Map<String, dynamic> holding) {
    final String symbol = holding['symbol'] ?? 'N/A';
    final int qty = (holding['qty'] as num).toInt();
    final double avgPrice = (holding['avg_buy_price'] as num?)?.toDouble() ?? 0.0;
    final double ltp = _getLTP(holding);

    final double invested = qty * avgPrice;
    final double currentValue = qty * ltp;
    final double pnl = currentValue - invested;
    final double pnlPercent = avgPrice > 0 ? (pnl / invested) * 100 : 0;

    final bool isProfit = pnl >= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryGold!, AppColors.primaryGold!.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                symbol.substring(0, 1),
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  '$qty × ₹${avgPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_formatCurrency(currentValue)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isProfit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isProfit ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isProfit ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primaryGold ?? Color(0xFFDAA520)),
            ),
            SizedBox(height: 20),
            Text('Loading holdings...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }


  Widget _buildErrorState() {
    return Container(
      height: 500,
      margin: EdgeInsets.all(20),
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
                    (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.1),
                    (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: AppColors.primaryGold ?? Color(0xFFDAA520),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Login Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please login with your broker to view your stock holdings and portfolio.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText ?? Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push(BajalLoginScreen.routeName);
              },
              icon: Icon(Icons.login, size: 20),
              label: Text(
                'Login with Broker',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('No Holdings Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Text('Start investing to see your stocks here', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(2)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(2)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(2)}K';
    return value.toStringAsFixed(2);
  }
}