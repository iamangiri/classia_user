import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../service/apiservice/bajaj_api_service.dart';

class StockMarketFundScreen extends StatefulWidget {
  @override
  _StockMarketFundScreenState createState() => _StockMarketFundScreenState();
}

class _StockMarketFundScreenState extends State<StockMarketFundScreen> with TickerProviderStateMixin {
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
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _isRefreshing = false;
    });
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
                  future: BajajApiService.getFunds(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || _isRefreshing) {
                      return _buildLoadingState();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      print('Error loading funds: ${snapshot.error}');
                      return _buildErrorState();
                    }

                    final apiData = snapshot.data!;

                    if (apiData['statusCode'] != 0 || apiData['data'] == null) {
                      return _buildErrorState();
                    }

                    final fundsData = apiData['data'] as Map<String, dynamic>;

                    return Column(
                      children: [
                        _buildFundsSummaryCard(fundsData),
                        _buildDetailedBreakdown(fundsData),
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

  Widget _buildFundsSummaryCard(Map<String, dynamic> fundsData) {
    final double available = _parseDouble(fundsData['available']);
    final double buypwr = _parseDouble(fundsData['buypwr']);
    final double cashAvailable = _parseDouble(fundsData['cashAvailable']);
    final double marginUtilized = _parseDouble(fundsData['marginUtilized']);
    final double realizedPNL = _parseDouble(fundsData['realizedPNL']);
    final double unRealizedPNL = _parseDouble(fundsData['unRealizedPNL']);

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
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Available Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹${_formatCurrency(available)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat('Buying Power', buypwr),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildMiniStat('Cash Available', cashAvailable),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 6),
        Text(
          '₹${_formatCurrency(value)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdown(Map<String, dynamic> fundsData) {
    final double marginUtilized = _parseDouble(fundsData['marginUtilized']);
    final double openBalance = _parseDouble(fundsData['openBalance']);
    final double payIn = _parseDouble(fundsData['payIn']);
    final double realizedPNL = _parseDouble(fundsData['realizedPNL']);
    final double unRealizedPNL = _parseDouble(fundsData['unRealizedPNL']);

    final List<Map<String, dynamic>> breakdownItems = [
      {
        'icon': Icons.trending_up,
        'label': 'Realized P&L',
        'value': realizedPNL,
        'isProfit': realizedPNL >= 0,
      },
      {
        'icon': Icons.show_chart,
        'label': 'Unrealized P&L',
        'value': unRealizedPNL,
        'isProfit': unRealizedPNL >= 0,
      },
      {
        'icon': Icons.pie_chart,
        'label': 'Margin Utilized',
        'value': marginUtilized,
        'isProfit': null,
      },
      {
        'icon': Icons.payment,
        'label': 'Pay In',
        'value': payIn,
        'isProfit': null,
      },
      {
        'icon': Icons.account_balance,
        'label': 'Opening Balance',
        'value': openBalance,
        'isProfit': null,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Account Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: breakdownItems.length,
            itemBuilder: (context, index) {
              final item = breakdownItems[index];
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 600 + (index * 100)),
                builder: (context, double animValue, child) {
                  return Transform.translate(
                    offset: Offset(20 * (1 - animValue), 0),
                    child: Opacity(
                      opacity: animValue,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBreakdownCard(
                          icon: item['icon'],
                          label: item['label'],
                          value: item['value'],
                          isProfit: item['isProfit'],
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

  Widget _buildBreakdownCard({
    required IconData icon,
    required String label,
    required double value,
    bool? isProfit,
  }) {
    Color valueColor;
    String prefix = '';

    if (isProfit == null) {
      valueColor = AppColors.primaryText ?? Colors.black87;
    } else if (isProfit) {
      valueColor = Colors.green[700]!;
      prefix = '+';
    } else {
      valueColor = Colors.red[700]!;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
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
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$prefix₹${_formatCurrency(value.abs())}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (isProfit != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isProfit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isProfit ? Colors.green[700] : Colors.red[700],
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    isProfit ? 'Profit' : 'Loss',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isProfit ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      margin: EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryGold ?? Color(0xFFDAA520),
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Loading your holdings...',
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
                    Colors.red.withOpacity(0.1),
                    Colors.red.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Unable to Load Holdings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There was an error loading your account information. Please check your connection and try again.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText ?? Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: Icon(Icons.refresh, size: 20),
              label: Text(
                'Retry Loading',
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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }
}