import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../service/apiservice/bajaj_api_service.dart';
import '../bajal-auth/bajal_login_screen.dart';

class TradeBookScreen extends StatefulWidget {
  @override
  _TradeBookScreenState createState() => _TradeBookScreenState();
}

class _TradeBookScreenState extends State<TradeBookScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;
  String _filterType = 'all'; // all, buy, sell

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
      appBar: CommonAppBar(title: 'Trade Book'),
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
                  future: BajajApiService.getTradeBook(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || _isRefreshing) {
                      return _buildLoadingState();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      print('Error loading tradebook: ${snapshot.error}');
                      return _buildErrorState(); // Shows "Login Required"
                    }

                    final apiData = snapshot.data!;

                    // Check if not logged in (error from API)
                    if (apiData['statusCode'] != 0) {
                      return _buildErrorState(); // Shows "Login Required"
                    }

                    // Check if data is null (logged in but no trades)
                    if (apiData['data'] == null) {
                      return _buildEmptyState(); // Shows "No Trades Yet"
                    }

                    final tradesList = apiData['data'] as List<dynamic>;

                    // Check if trades list is empty
                    if (tradesList.isEmpty) {
                      return _buildEmptyState(); // Shows "No Trades Yet"
                    }

                    return Column(
                      children: [
                        _buildSummaryCard(tradesList),
                        _buildFilterChips(),
                        _buildTradesList(tradesList),
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

  Widget _buildSummaryCard(List<dynamic> trades) {
    int totalTrades = trades.length;
    int buyTrades = trades.where((t) => t['buy_sell'] == 'BUY').length;
    int sellTrades = trades.where((t) => t['buy_sell'] == 'SELL').length;

    double totalBuyValue = 0;
    double totalSellValue = 0;

    for (var trade in trades) {
      double price = _parseDouble(trade['price']);
      int qty = trade['traded_qty'] ?? 0;
      double value = price * qty;

      if (trade['buy_sell'] == 'BUY') {
        totalBuyValue += value;
      } else {
        totalSellValue += value;
      }
    }

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
                  Icons.swap_horiz,
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
                      'Total Trades',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$totalTrades',
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniStat('Buy Trades', buyTrades, Colors.green[400]!),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildMiniStat('Sell Trades', sellTrades, Colors.red[400]!),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildValueStat('Buy Value', totalBuyValue, Colors.green[300]!),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildValueStat('Sell Value', totalSellValue, Colors.red[300]!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueStat(String label, double value, Color color) {
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '₹${_formatCurrency(value)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip('All Trades', 'all'),
          SizedBox(width: 8),
          _buildFilterChip('Buy Only', 'buy'),
          SizedBox(width: 8),
          _buildFilterChip('Sell Only', 'sell'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _filterType == value;
    return Expanded(
      child: FilterChip(
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterType = value;
          });
        },
        selectedColor: AppColors.primaryGold ?? Color(0xFFDAA520),
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: isSelected ? 4 : 0,
        pressElevation: 2,
      ),
    );
  }

  Widget _buildTradesList(List<dynamic> trades) {
    List<dynamic> filteredTrades = trades;

    if (_filterType == 'buy') {
      filteredTrades = trades.where((trade) => trade['buy_sell'] == 'BUY').toList();
    } else if (_filterType == 'sell') {
      filteredTrades = trades.where((trade) => trade['buy_sell'] == 'SELL').toList();
    }

    if (filteredTrades.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.filter_list_off,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No ${_filterType == 'all' ? '' : _filterType} trades found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group trades by symbol
    Map<String, List<dynamic>> groupedTrades = {};
    for (var trade in filteredTrades) {
      String symbol = trade['symbol'] ?? '';
      if (!groupedTrades.containsKey(symbol)) {
        groupedTrades[symbol] = [];
      }
      groupedTrades[symbol]!.add(trade);
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 16),
            child: Text(
              'Trade Details',
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
            itemCount: groupedTrades.length,
            itemBuilder: (context, index) {
              String symbol = groupedTrades.keys.elementAt(index);
              List<dynamic> symbolTrades = groupedTrades[symbol]!;

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
                        child: _buildTradeGroupCard(symbol, symbolTrades),
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

  Widget _buildTradeGroupCard(String symbol, List<dynamic> trades) {
    int totalQty = trades.fold(0, (sum, trade) => sum + (trade['traded_qty'] as int? ?? 0));
    double avgPrice = trades.fold(0.0, (sum, trade) => sum + _parseDouble(trade['price'])) / trades.length;
    bool isBuy = trades.first['buy_sell'] == 'BUY';
    String product = trades.first['product'] ?? '';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isBuy
                        ? [Colors.green[400]!, Colors.green[600]!]
                        : [Colors.red[400]!, Colors.red[600]!],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText ?? Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${trades.length} ${trades.length > 1 ? 'Trades' : 'Trade'} • ${product == 'D' ? 'Delivery' : 'Intraday'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isBuy ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBuy ? 'BUY' : 'SELL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isBuy ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTradeInfoColumn('Total Quantity', '$totalQty'),
                    _buildTradeInfoColumn('Avg Price', '₹${avgPrice.toStringAsFixed(2)}'),
                    _buildTradeInfoColumn('Total Value', '₹${_formatCurrency(totalQty * avgPrice)}'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          ExpansionTile(
            title: Text(
              'View Individual Trades',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGold ?? Color(0xFFDAA520),
              ),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: trades.length,
                itemBuilder: (context, index) {
                  final trade = trades[index];
                  return Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trade ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                            Text(
                              _formatDateTime(trade['trade_time'] ?? ''),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSmallInfo('Qty', '${trade['traded_qty']}'),
                            _buildSmallInfo('Price', '₹${_parseDouble(trade['price']).toStringAsFixed(2)}'),
                            _buildSmallInfo('Trade ID', '${trade['trade_id']}'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTradeInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText ?? Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primaryText ?? Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ],
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
              'Loading your trades...',
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
              'Please login with your broker to view your trade book and executed trades.',
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
      margin: EdgeInsets.all(20),
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
                Icons.inbox,
                size: 64,
                color: AppColors.primaryGold ?? Color(0xFFDAA520),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Trades Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your executed trades will appear here.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryText ?? Colors.grey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
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

  String _formatDateTime(String dateTime) {
    if (dateTime.isEmpty) return '-';

    try {
      final parts = dateTime.split(' ');
      if (parts.length >= 2) {
        final date = parts[0];
        final time = parts[1];
        final timeParts = time.split(':');
        if (timeParts.length >= 2) {
          return '${timeParts[0]}:${timeParts[1]}';
        }
      }
      return dateTime;
    } catch (e) {
      return dateTime;
    }
  }
}