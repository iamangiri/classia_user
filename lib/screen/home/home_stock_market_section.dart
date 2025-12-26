import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utills/themes/light_app_theme.dart';
import '../market/market_stock_chart_screen.dart';
import '../market/stock_market_screen.dart';

class HomeStockMarketSection extends StatefulWidget {
  const HomeStockMarketSection({Key? key}) : super(key: key);

  @override
  State<HomeStockMarketSection> createState() => _HomeStockMarketSectionState();
}

class _HomeStockMarketSectionState extends State<HomeStockMarketSection> {
  // Top 10 Indian stocks by market cap
  final List<Map<String, dynamic>> topStocks = [
    {
      'symbol': 'RELIANCE',
      'name': 'Reliance Industries',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.industry,
      'emoji': '🏭', // Added emoji field
      'color': Color(0xFFE31E24),
      'sector': 'Conglomerate',
    },
    {
      'symbol': 'TCS',
      'name': 'Tata Consultancy',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.code,
      'emoji': '💻',
      'color': Color(0xFF0F62FE),
      'sector': 'IT Services',
    },
    {
      'symbol': 'HDFCBANK',
      'name': 'HDFC Bank',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.buildingColumns,
      'emoji': '🏦',
      'color': Color(0xFF004C8F),
      'sector': 'Banking',
    },
    {
      'symbol': 'INFY',
      'name': 'Infosys',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.laptop,
      'emoji': '💼',
      'color': Color(0xFF007CC3),
      'sector': 'IT Services',
    },
    {
      'symbol': 'ICICIBANK',
      'name': 'ICICI Bank',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.landmark,
      'emoji': '🏛️',
      'color': Color(0xFFED6C00),
      'sector': 'Banking',
    },
    {
      'symbol': 'HINDUNILVR',
      'name': 'Hindustan Unilever',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.bottleWater,
      'emoji': '🧴',
      'color': Color(0xFF0099CC),
      'sector': 'FMCG',
    },
    {
      'symbol': 'BHARTIARTL',
      'name': 'Bharti Airtel',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.signal,
      'emoji': '📡',
      'color': Color(0xFFE60000),
      'sector': 'Telecom',
    },
    {
      'symbol': 'SBIN',
      'name': 'State Bank of India',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.university,
      'emoji': '🏦',
      'color': Color(0xFF1C4A93),
      'sector': 'Banking',
    },
    {
      'symbol': 'ITC',
      'name': 'ITC Limited',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.building,
      'emoji': '🏢',
      'color': Color(0xFF003D79),
      'sector': 'Conglomerate',
    },
    {
      'symbol': 'LT',
      'name': 'Larsen & Toubro',
      'exchange': 'NSE',
      'icon': FontAwesomeIcons.helmetSafety,
      'emoji': '🏗️',
      'color': Color(0xFF00539F),
      'sector': 'Infrastructure',
    },
  ];

  void _navigateToChart(Map<String, dynamic> stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketStockChartScreen(
          exchange: stock['exchange'],
          symbol: stock['symbol'],
          stockName: stock['name'],
          stockLogo: stock['emoji'], // Use emoji for chart screen
        ),
      ),
    );
  }

  void _navigateToMarketScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MarketScreen(
          showBackButton: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.hintColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.chartLine,
                        size: 18.sp,
                        color: AppTheme.lightTheme.hintColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Market',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'Top stocks by market cap',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToMarketScreen,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.hintColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppTheme.lightTheme.hintColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppTheme.lightTheme.hintColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          FaIcon(
                            FontAwesomeIcons.chevronRight,
                            size: 10.sp,
                            color: AppTheme.lightTheme.hintColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Stock Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.05,
            ),
            itemCount: topStocks.length,
            itemBuilder: (context, index) {
              final stock = topStocks[index];
              return _buildStockCard(stock);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToChart(stock),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background gradient effect
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stock['color'].withOpacity(0.08),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and exchange badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: stock['color'].withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: FaIcon(
                            stock['icon'], // Keep using FontAwesome icon
                            size: 22.sp,
                            color: stock['color'],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.hintColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: AppTheme.lightTheme.hintColor.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'NSE',
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.hintColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    // Stock details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            stock['symbol'],
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightTheme.primaryColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            stock['name'],
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stock['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: stock['color'].withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    stock['sector'],
                                    style: TextStyle(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w700,
                                      color: stock['color'],
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tap indicator
              Positioned(
                bottom: 10.h,
                right: 10.w,
                child: Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.hintColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.arrowRight,
                    size: 9.sp,
                    color: AppTheme.lightTheme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}