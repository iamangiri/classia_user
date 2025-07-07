import 'package:flutter/material.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../service/apiservice/trade_service.dart';
import '../../widget/trade/trade_app_bar.dart';
import '../../widget/trade/trade_overlay.dart';
import '../../widget/trading_card.dart';
import 'dart:async';


class TradingScreen extends StatefulWidget {
  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  List<Map<String, dynamic>> amcList = [];
  bool isLoading = true;
  String? errorMessage;
  bool showMarketClosedOverlay = false;

  // Create instance of TradeService
  final TradeService _tradeService = TradeService();

  @override
  void initState() {
    super.initState();
    _loadAmcData();
    _checkMarketStatus();
  }

  void _checkMarketStatus() {
    // Check market status and show overlay if needed
    if (!_isMarketOpen()) {
      setState(() {
        showMarketClosedOverlay = true;
      });
    }
  }

  bool _isMarketOpen() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Check if it's Saturday (6) or Sunday (7)
    if (weekday == 6 || weekday == 7) {
      return false;
    }

    // Market hours: 9:15 AM to 3:30 PM (Indian Stock Exchange)
    final marketOpen = DateTime(now.year, now.month, now.day, 9, 15);
    final marketClose = DateTime(now.year, now.month, now.day, 15, 30);

    return now.isAfter(marketOpen) && now.isBefore(marketClose);
  }

  String _getMarketStatus() {
    if (_isMarketOpen()) {
      return "Market is Open - You can invest now!";
    } else {
      final now = DateTime.now();
      final weekday = now.weekday;

      if (weekday == 6 || weekday == 7) {
        return "Market Closed - Weekend";
      }

      final nextOpen = DateTime(now.year, now.month, now.day, 9, 15);
      final marketClose = DateTime(now.year, now.month, now.day, 15, 30);

      if (now.isBefore(nextOpen)) {
        return "Market Opens at 9:15 AM";
      } else if (now.isAfter(marketClose)) {
        return "Market Closed - Opens Tomorrow at 9:15 AM";
      }

      return "Market is Closed";
    }
  }

  Future<void> _loadAmcData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Use the service to load AMC data
      final enrichedAmcList = await _tradeService.loadAmcData();

      setState(() {
        amcList = enrichedAmcList;
        isLoading = false;
      });

    } catch (e) {
      print('Error loading AMC data: $e');
      setState(() {
        // Use default data as fallback through service
        amcList = _tradeService.getDefaultAmcData();
        amcList.sort((a, b) => b["value"].compareTo(a["value"]));
        isLoading = false;
        errorMessage = 'Using default data due to API error';
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadAmcData();
  }

  Widget _buildCompactErrorMessage() {
    if (errorMessage == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border(
          left: BorderSide(color: Colors.orange, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundsList() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Loading funds...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (amcList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No funds available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: amcList.length,
      itemBuilder: (context, index) {
        var amc = amcList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TradingCard(
            logo: amc["logo"],
            name: amc["name"],
            fundName: amc["fundName"],
            value: amc["value"],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: TradeAppBar(title: 'Jockey Trading'),
      body: Stack(
        children: [
          // Main Content
          RefreshIndicator(
            onRefresh: _refreshData,
            color: AppColors.primaryGold,
            child: Column(
              children: [
                _buildCompactErrorMessage(),
                Expanded(
                  child: _buildFundsList(),
                ),
              ],
            ),
          ),

          // Market Closed Overlay
          if (showMarketClosedOverlay)
            Positioned.fill(
              child:MarketClosedOverlay(
                onExploreFunds: () {
                  context.goNamed('main', queryParameters: {'index': '1'});
                },
              )
            ),
        ],
      ),

      // Floating Action Button for Market Status (Optional)
      floatingActionButton: !_isMarketOpen() && !showMarketClosedOverlay
          ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            showMarketClosedOverlay = true;
          });
        },
        backgroundColor: AppColors.primaryGold,
        icon: Icon(Icons.access_time, color: Colors.white),
        label: Text(
          'Market Status',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : null,
    );
  }
}