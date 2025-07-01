//
// import 'package:flutter/material.dart';
// import 'package:classia_amc/themes/app_colors.dart';
// import '../../service/apiservice/trade_service.dart';
// import '../../widget/custom_app_bar.dart';
// import '../../widget/trading_card.dart';
//
//
// class TradingScreen extends StatefulWidget {
//   @override
//   _TradingScreenState createState() => _TradingScreenState();
// }
//
// class _TradingScreenState extends State<TradingScreen> {
//   List<Map<String, dynamic>> amcList = [];
//   bool isLoading = true;
//   String? errorMessage;
//
//   // Create instance of TradeService
//   final TradeService _tradeService = TradeService();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAmcData();
//   }
//
//   Future<void> _loadAmcData() async {
//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = null;
//       });
//
//       // Use the service to load AMC data
//       final enrichedAmcList = await _tradeService.loadAmcData();
//
//       setState(() {
//         amcList = enrichedAmcList;
//         isLoading = false;
//       });
//
//     } catch (e) {
//       print('Error loading AMC data: $e');
//       setState(() {
//         // Use default data as fallback through service
//         amcList = _tradeService.getDefaultAmcData();
//         amcList.sort((a, b) => b["value"].compareTo(a["value"]));
//         isLoading = false;
//         errorMessage = 'Using default data due to API error';
//       });
//     }
//   }
//
//   Future<void> _refreshData() async {
//     await _loadAmcData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: CustomAppBar(title: 'Jockey Trading'),
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: Column(
//           children: [
//             if (errorMessage != null)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(8),
//                 margin: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[100],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange[300]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.warning, color: Colors.orange[700], size: 16),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         errorMessage!,
//                         style: TextStyle(
//                           color: Colors.orange[700],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             Expanded(
//               child: isLoading
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDAA520)),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Loading AMC data...',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : amcList.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'No AMC data available',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 18,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: _refreshData,
//                       child: Text('Retry'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFDAA520),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: ListView.builder(
//                   itemCount: amcList.length,
//                   itemBuilder: (context, index) {
//                     var amc = amcList[index];
//                     return TradingCard(
//                       logo: amc["logo"],
//                       name: amc["name"],
//                       fundName: amc["fundName"],
//                       value: amc["value"],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:classia_amc/themes/app_colors.dart';
import '../../service/apiservice/trade_service.dart';
import '../../widget/custom_app_bar.dart';
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
  DateTime currentTime = DateTime.now();
  Timer? _timer;

  // Create instance of TradeService
  final TradeService _tradeService = TradeService();

  @override
  void initState() {
    super.initState();
    _loadAmcData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
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

  String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    String minute = time.minute.toString().padLeft(2, '0');
    String second = time.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second $period';
  }

  Widget _buildMarketStatusCard() {
    final isOpen = _isMarketOpen();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOpen
              ? [Color(0xFF4CAF50), Color(0xFF45A049)]
              : [Color(0xFFFF6B6B), Color(0xFFE55353)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOpen ? Icons.trending_up : Icons.access_time,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isOpen ? 'MARKET OPEN' : 'MARKET CLOSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getMarketStatus(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!isOpen) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⚠️ Investment restricted during market hours only',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'CURRENT TIME',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatTime(currentTime),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: 'Jockey Trading'),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            _buildMarketStatusCard(),
            if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDAA520)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading AMC data...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : amcList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No AMC data available',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDAA520),
                      ),
                    ),
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  itemCount: amcList.length,
                  itemBuilder: (context, index) {
                    var amc = amcList[index];
                    return TradingCard(
                      logo: amc["logo"],
                      name: amc["name"],
                      fundName: amc["fundName"],
                      value: amc["value"],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}