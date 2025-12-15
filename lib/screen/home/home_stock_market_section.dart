import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../market/market_stock_chart_screen.dart';
import '../market/stock_market_screen.dart';

class HomeStockMarketSection extends StatefulWidget {
  const HomeStockMarketSection({Key? key}) : super(key: key);

  @override
  State<HomeStockMarketSection> createState() => _HomeStockMarketSectionState();
}

class _HomeStockMarketSectionState extends State<HomeStockMarketSection> {
  // Top 10 Indian stocks data
  final List<Map<String, dynamic>> topStocks = [
    {
      'symbol': 'RELIANCE',
      'name': 'Reliance Industries',
      'exchange': 'NSE',
      'logo': '🏭',
    },
    {
      'symbol': 'TCS',
      'name': 'Tata Consultancy Services',
      'exchange': 'NSE',
      'logo': '💻',
    },
    {
      'symbol': 'HDFCBANK',
      'name': 'HDFC Bank',
      'exchange': 'NSE',
      'logo': '🏦',
    },
    {
      'symbol': 'INFY',
      'name': 'Infosys',
      'exchange': 'NSE',
      'logo': '💼',
    },
    {
      'symbol': 'ICICIBANK',
      'name': 'ICICI Bank',
      'exchange': 'NSE',
      'logo': '🏛️',
    },
    {
      'symbol': 'HINDUNILVR',
      'name': 'Hindustan Unilever',
      'exchange': 'NSE',
      'logo': '🧴',
    },
    {
      'symbol': 'BHARTIARTL',
      'name': 'Bharti Airtel',
      'exchange': 'NSE',
      'logo': '📱',
    },
    {
      'symbol': 'ITC',
      'name': 'ITC Limited',
      'exchange': 'NSE',
      'logo': '🏢',
    },
    {
      'symbol': 'SBIN',
      'name': 'State Bank of India',
      'exchange': 'NSE',
      'logo': '🏦',
    },
    {
      'symbol': 'LT',
      'name': 'Larsen & Toubro',
      'exchange': 'NSE',
      'logo': '🏗️',
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
          stockLogo: stock['logo'],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Market',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              TextButton(
                onPressed: _navigateToMarketScreen,
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.4,
          ),
          itemCount: topStocks.length,
          itemBuilder: (context, index) {
            final stock = topStocks[index];

            return GestureDetector(
              onTap: () => _navigateToChart(stock),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.screenBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stock['logo'],
                      style: TextStyle(fontSize: 32.sp),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      stock['symbol'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      stock['name'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}