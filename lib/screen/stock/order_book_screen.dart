import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';
import '../../service/apiservice/bajaj_api_service.dart';

class OrderBookScreen extends StatefulWidget {
  @override
  _OrderBookScreenState createState() => _OrderBookScreenState();
}

class _OrderBookScreenState extends State<OrderBookScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;
  String _filterStatus = 'all'; // all, complete, pending, rejected

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
      appBar: CommonAppBar(title: 'Order Book'),
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
                  future: BajajApiService.getOrderBook(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || _isRefreshing) {
                      return _buildLoadingState();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      print('Error loading orderbook: ${snapshot.error}');
                      return _buildErrorState();
                    }

                    final apiData = snapshot.data!;

                    if (apiData['statusCode'] != 0 || apiData['data'] == null) {
                      return _buildErrorState();
                    }

                    final ordersList = apiData['data'] as List<dynamic>;

                    if (ordersList.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        _buildSummaryCard(ordersList),
                        _buildFilterChips(),
                        _buildOrdersList(ordersList),
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

  Widget _buildSummaryCard(List<dynamic> orders) {
    int totalOrders = orders.length;
    int completedOrders = orders.where((o) => o['order_status'] == 'complete').length;
    int pendingOrders = orders.where((o) => o['order_status'] == 'pending').length;
    int rejectedOrders = orders.where((o) => o['order_status'] == 'rejected').length;

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
                  Icons.receipt_long,
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
                      'Total Orders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$totalOrders',
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
                _buildMiniStat('Completed', completedOrders, Colors.green[400]!),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildMiniStat('Pending', pendingOrders, Colors.orange[400]!),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildMiniStat('Rejected', rejectedOrders, Colors.red[400]!),
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
              fontSize: 18,
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('Completed', 'complete'),
            SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.primaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: AppColors.primaryGold ?? Color(0xFFDAA520),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: isSelected ? 4 : 0,
      pressElevation: 2,
    );
  }

  Widget _buildOrdersList(List<dynamic> orders) {
    List<dynamic> filteredOrders = orders;

    if (_filterStatus != 'all') {
      filteredOrders = orders.where((order) =>
      order['order_status'] == _filterStatus
      ).toList();
    }

    if (filteredOrders.isEmpty) {
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
                'No ${_filterStatus == 'all' ? '' : _filterStatus} orders found',
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

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 16),
            child: Text(
              'Order Details',
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
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
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
                        child: _buildOrderCard(order),
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    String symbol = order['symbol'] ?? '';
    String buySell = order['buy_sell'] ?? '';
    int qty = order['qty'] ?? 0;
    int tradedQty = order['traded_qty'] ?? 0;
    double tradePrice = _parseDouble(order['trade_price']);
    String status = order['order_status'] ?? '';
    String orderTime = order['order_time'] ?? '';
    String orderType = order['order_type'] ?? '';
    String product = order['product'] ?? '';
    String errorReason = order['error_reason'] ?? '';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'complete':
        statusColor = Colors.green[700]!;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange[700]!;
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = Colors.red[700]!;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey[700]!;
        statusIcon = Icons.info;
    }

    bool isBuy = buySell.toUpperCase() == 'BUY';

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
                      symbol.replaceAll('-EQ', ''),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText ?? Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '$qty Qty ${product == 'D' ? '• Delivery' : '• Intraday'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
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
                _buildOrderDetailRow('Trade Price',
                    tradePrice > 0 ? '₹${tradePrice.toStringAsFixed(2)}' : '-'),
                SizedBox(height: 8),
                _buildOrderDetailRow('Traded Qty', '$tradedQty / $qty'),
                SizedBox(height: 8),
                _buildOrderDetailRow('Order Type', orderType),
                SizedBox(height: 8),
                _buildOrderDetailRow('Time', _formatDateTime(orderTime)),
              ],
            ),
          ),
          if (status == 'rejected' && errorReason.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorReason,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText ?? Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primaryText ?? Colors.black87,
            fontWeight: FontWeight.w600,
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
              'Loading your orders...',
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
              'Unable to Load Orders',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There was an error loading your order book. Please check your connection and try again.',
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
              'No Orders Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText ?? Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your order history will appear here once you start trading.',
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