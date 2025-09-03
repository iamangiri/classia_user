import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';

class HomeJockeyTradeSection extends StatefulWidget {
  @override
  _HomeJockeyTradeSectionState createState() => _HomeJockeyTradeSectionState();
}

class _HomeJockeyTradeSectionState extends State<HomeJockeyTradeSection>
    with TickerProviderStateMixin {
  late AnimationController _horseController;
  late AnimationController _fadeController;
  late Animation<double> _horseAnimation;
  late Animation<double> _fadeAnimation;

  // Sample jockey data
  final List<Map<String, dynamic>> _jockeyData = [
    {
      'name': 'HDFC AMC',
      'winRate': 81.2,
      'totalTrades': 415,
      'roi': 28.4,
      'specialty': 'Large Cap',
      'avatar': 'HDFC',
      'color': Colors.deepPurple,
      'isActive': true,
    },
    {
      'name': 'Tata Mutual Fund',
      'winRate': 76.5,
      'totalTrades': 380,
      'roi': 24.9,
      'specialty': 'Balanced Advantage',
      'avatar': 'TATA',
      'color': Colors.blue,
      'isActive': true,
    },
    {
      'name': 'ICICI Prudential',
      'winRate': 79.3,
      'totalTrades': 398,
      'roi': 26.7,
      'specialty': 'Multi Cap',
      'avatar': 'ICICI',
      'color': Colors.orange,
      'isActive': true,
    },
    {
      'name': 'SBI Mutual Fund',
      'winRate': 83.1,
      'totalTrades': 433,
      'roi': 29.5,
      'specialty': 'Index Funds',
      'avatar': 'SBI',
      'color': Colors.green,
      'isActive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _horseController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _horseAnimation = Tween<double>(
      begin: 0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _horseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _horseController.repeat();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _horseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                  Colors.grey[900]!.withOpacity(0.95),
                  Colors.grey[800]!.withOpacity(0.9),
                ]
                    : [
                  Colors.white.withOpacity(0.95),
                  Colors.grey[50]!.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 20.h),
                _buildJockeyStats(),
                SizedBox(height: 20.h),
                _buildActiveJockeys(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Fixed Header with Horse Animation inside Stack
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jockey Trading',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText ?? Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Bet on the jockey, not the horse.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText ?? Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 80.h,
            width: 80.w,
            child: Image.asset(
              'assets/images/jt1.gif',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  /// Jockey Stats Row
  Widget _buildJockeyStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Jockeys',
              '10',
              Icons.person_outline,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Avg Win Rate',
              '78.9%',
              Icons.analytics_outlined,
              Colors.green,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard(
              'Total ROI',
              '₹2.4M',
              Icons.account_balance_wallet_outlined,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText ?? Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Active Jockeys List
  Widget _buildActiveJockeys() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Performing Jockeys',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText ?? Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all jockeys
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryGold ?? Color(0xFFDAA520),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 160.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _jockeyData.length,
            itemBuilder: (context, index) {
              final jockey = _jockeyData[index];
              return _buildJockeyCard(jockey);
            },
          ),
        ),
      ],
    );
  }

  /// ✅ Responsive Jockey Card
  Widget _buildJockeyCard(Map<String, dynamic> jockey) {
    double cardWidth = MediaQuery.of(context).size.width * 0.42;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            jockey['color'].withOpacity(0.1),
            jockey['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: jockey['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      jockey['color'],
                      jockey['color'].withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    jockey['avatar'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.circle,
                  size: 8.sp,
                  color: jockey['isActive'] ? Colors.green : Colors.grey),
            ],
          ),
          SizedBox(height: 8.h),
          Flexible(
            child: Text(
              jockey['name'],
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText ?? Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            jockey['specialty'],
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${jockey['winRate']}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
              Text(
                '+${jockey['roi']}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: jockey['color'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
