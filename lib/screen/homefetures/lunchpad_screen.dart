import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';

class LaunchpadScreen extends StatefulWidget {
  @override
  _LaunchpadScreenState createState() => _LaunchpadScreenState();
}

class _LaunchpadScreenState extends State<LaunchpadScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'title';
  bool _showFavoritesOnly = false;

  // F&O Data for Mutual Funds
  final List<Map<String, dynamic>> foMutualFunds = [
    {
      'fundName': 'HDFC Nifty 50 ETF',
      'symbol': 'HDFCNIFTY',
      'premium': 2.5,
      'strikePrice': 185.50,
      'expiry': '25 Dec 2025',
      'volume': 15420,
      'openInterest': 8250,
      'changePercent': 3.2,
      'type': 'CALL',
      'color': Colors.green,
      'category': 'ETF',
    },
    {
      'fundName': 'SBI Banking ETF',
      'symbol': 'SBIBANK',
      'premium': 1.8,
      'strikePrice': 45.25,
      'expiry': '30 Dec 2025',
      'volume': 12300,
      'openInterest': 6500,
      'changePercent': -1.5,
      'type': 'PUT',
      'color': Colors.red,
      'category': 'ETF',
    },
    {
      'fundName': 'ICICI Prudential Nifty Next 50',
      'symbol': 'ICICIN50',
      'premium': 3.1,
      'strikePrice': 78.90,
      'expiry': '28 Dec 2025',
      'volume': 18750,
      'openInterest': 9800,
      'changePercent': 2.8,
      'type': 'CALL',
      'color': Colors.green,
      'category': 'ETF',
    },
  ];

  // Recent Launched Funds
  final List<Map<String, dynamic>> recentLaunchedFunds = [
    {
      'fundName': 'Axis ESG Equity Fund',
      'launchDate': '15 Dec 2024',
      'category': 'ESG Equity',
      'minSip': 500,
      'minInvestment': 5000,
      'expenseRatio': 1.25,
      'fundManager': 'Rahul Baijal',
      'aum': 150.5,
      'rating': 4,
      'nav': 10.0,
      'description': 'Invests in companies following ESG principles with strong sustainability practices',
      'keyFeatures': ['ESG Focused', 'Long-term Growth', 'Sustainable Investing'],
      'color': const Color(0xFF10B981),
      'icon': Icons.eco_outlined,
    },
    {
      'fundName': 'HDFC Technology Fund',
      'launchDate': '20 Nov 2024',
      'category': 'Sectoral Equity',
      'minSip': 1000,
      'minInvestment': 10000,
      'expenseRatio': 1.50,
      'fundManager': 'Chirag Setalvad',
      'aum': 250.8,
      'rating': 5,
      'nav': 10.0,
      'description': 'Focused on technology and innovation sector companies with high growth potential',
      'keyFeatures': ['Tech Focus', 'Innovation', 'High Growth'],
      'color': const Color(0xFF6366F1),
      'icon': Icons.computer_outlined,
    },
    {
      'fundName': 'SBI Healthcare Fund',
      'launchDate': '10 Jan 2025',
      'category': 'Sectoral Equity',
      'minSip': 500,
      'minInvestment': 5000,
      'expenseRatio': 1.35,
      'fundManager': 'Dinesh Ahuja',
      'aum': 85.2,
      'rating': 4,
      'nav': 10.0,
      'description': 'Invests in pharmaceutical and healthcare sector companies',
      'keyFeatures': ['Healthcare Focus', 'Defensive Play', 'Demographic Advantage'],
      'color': const Color(0xFFEF4444),
      'icon': Icons.medical_services_outlined,
    },
  ];

  final List<Map<String, dynamic>> upcomingFeatures = [
    {
      'title': 'AI-Powered Portfolio Advisory',
      'progress': 0.85,
      'color': const Color(0xFF8B5CF6),
      'details': {
        'description': 'Get personalized investment recommendations powered by artificial intelligence and machine learning.',
        'keyPoints': ['Smart Recommendations', 'Risk Assessment', 'Goal-based Planning'],
        'releaseDate': 'Q1 2025',
        'strategies': ['Portfolio optimization', 'Risk diversification', 'Goal alignment'],
        'videoUrl': 'https://example.com/ai-advisory-video',
        'resources': [
          {'title': 'AI in Finance Guide', 'url': 'https://www.investopedia.com'},
          {'title': 'Robo Advisory Benefits', 'url': 'https://www.morningstar.com'},
        ],
      },
    },
    {
      'title': 'Real-time Market Alerts',
      'progress': 0.6,
      'color': const Color(0xFFF59E0B),
      'details': {
        'description': 'Get instant notifications about market movements, fund performance changes, and investment opportunities.',
        'keyPoints': ['Smart Alerts', 'Custom Triggers', 'Multi-channel Notifications'],
        'releaseDate': 'Q2 2025',
        'strategies': ['Set price alerts', 'Monitor volatility', 'Track performance'],
        'videoUrl': 'https://example.com/alerts-video',
        'resources': [
          {'title': 'Market Alert Strategies', 'url': 'https://www.valueresearchonline.com'},
          {'title': 'Investment Monitoring', 'url': 'https://www.moneycontrol.com'},
        ],
      },
    },
    {
      'title': 'Social Investment Community',
      'progress': 0.4,
      'color': const Color(0xFF10B981),
      'details': {
        'description': 'Connect with fellow investors, share insights, and learn from experienced mutual fund investors.',
        'keyPoints': ['Investor Forums', 'Strategy Sharing', 'Expert Insights'],
        'releaseDate': 'Q3 2025',
        'strategies': ['Join discussions', 'Follow experts', 'Share experiences'],
        'videoUrl': 'https://example.com/community-video',
        'resources': [
          {'title': 'Investment Communities', 'url': 'https://www.reddit.com/r/investing'},
          {'title': 'Social Trading Guide', 'url': 'https://www.investopedia.com'},
        ],
      },
    },
  ];

  Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    for (var feature in upcomingFeatures) {
      _favorites[feature['title']] = false;
    }
    for (var fund in recentLaunchedFunds) {
      _favorites[fund['fundName']] = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFeatures {
    var filtered = upcomingFeatures.where((feature) {
      final matchesFavorite = !_showFavoritesOnly || _favorites[feature['title']]!;
      return matchesFavorite;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'progress') {
        return b['progress'].compareTo(a['progress']);
      } else if (_sortBy == 'releaseDate') {
        return a['details']['releaseDate'].compareTo(b['details']['releaseDate']);
      }
      return a['title'].compareTo(b['title']);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeroSection(),
            _buildFOSection(),
            _buildRecentLaunchedFunds(),
            _buildUpcomingFeaturesSection(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      floatingActionButton: _buildModernFab(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      title: Text(
        'Investment Launchpad',
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primaryGold, size: 24.sp), // 👈 sets back icon color & size
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor ?? Colors.blue,
              AppColors.primaryColor ?? const Color(0xFFDAA520),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.primaryGold, size: 24.sp),
          onPressed: _showNotifications,
        ),
        IconButton(
          icon: Icon(Icons.filter_list_alt, color: AppColors.primaryGold, size: 24.sp),
          onPressed: _showFilterModal,
        ),
      ],
    );
  }


  Widget _buildHeroSection() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
            AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.primaryColor?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              size: 40.sp,
              color: AppColors.primaryColor ?? Colors.blue,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Welcome to Investment Hub',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor ?? Colors.blue[900],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Explore F&O opportunities, discover new funds, and stay ahead with upcoming features',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFOSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.trending_up,
                  size: 24.sp,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'F&O on Mutual Funds',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Trade futures and options on ETFs and mutual fund schemes',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 195.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: foMutualFunds.length,
              itemBuilder: (context, index) => _buildFOCard(foMutualFunds[index]),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildFOCard(Map<String, dynamic> foData) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foData['fundName'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: foData['type'] == 'CALL' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    foData['type'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: foData['type'] == 'CALL' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹${foData['premium'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: foData['color'],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Strike',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹${foData['strikePrice'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.sp, color: AppColors.secondaryText),
                SizedBox(width: 4.w),
                Text(
                  'Expiry: ${foData['expiry']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vol: ${(foData['volume'] / 1000).toStringAsFixed(1)}K',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                  ),
                ),
                Text(
                  '${foData['changePercent'] > 0 ? '+' : ''}${foData['changePercent'].toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: foData['color'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentLaunchedFunds() {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.new_releases_outlined,
                  size: 24.sp,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Recently Launched Funds',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Discover new investment opportunities with fresh fund launches',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          ...recentLaunchedFunds.asMap().entries.map((entry) {
            return _buildRecentFundCard(entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildRecentFundCard(Map<String, dynamic> fund, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: fund['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    fund['icon'],
                    size: 28.sp,
                    color: fund['color'],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fund['fundName'],
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor ?? Colors.blue[900],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _favorites[fund['fundName']]! ? Icons.favorite : Icons.favorite_border,
                              color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                              size: 20.sp,
                            ),
                            onPressed: () => setState(() => _favorites[fund['fundName']] = !_favorites[fund['fundName']]!),
                          ),
                        ],
                      ),
                      Text(
                        fund['category'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: fund['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              fund['description'],
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.secondaryText ?? Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: fund['keyFeatures'].map<Widget>((feature) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: fund['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: fund['color'],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFundStat('NAV', '₹${fund['nav'].toString()}'),
                      _buildFundStat('Min SIP', '₹${fund['minSip']}'),
                      _buildFundStat('AUM', '₹${fund['aum']}Cr'),
                      _buildFundStat('Rating', '${fund['rating']}⭐'),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        'Launched: ${fund['launchDate']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primaryColor ?? Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showFundDetails(fund),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      side: BorderSide(color: fund['color']),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: fund['color'],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _investInFund(fund),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fund['color'],
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 2,
                    ),
                    child: Text(
                      'Invest Now',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor ?? Colors.blue[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.secondaryText ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingFeaturesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.upcoming_outlined,
                  size: 24.sp,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Upcoming Features',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Exciting new features coming to enhance your investment experience',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          _filteredFeatures.isEmpty
              ? _buildEmptyState()
              : Column(
            children: _filteredFeatures
                .asMap()
                .entries
                .map((entry) => _buildFeatureCard(entry.value, entry.key))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.lightbulb_outline, size: 60.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No features found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(feature),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 50.h,
                        child: CircularProgressIndicator(
                          value: feature['progress'],
                          strokeWidth: 4,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(feature['color']),
                        ),
                      ),
                      Text(
                        '${(feature['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor ?? Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'],
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor ?? Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: feature['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Coming ${feature['details']['releaseDate']}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: feature['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _favorites[feature['title']]! ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _favorites[feature['title']] = !_favorites[feature['title']]!),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                feature['details']['description'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.secondaryText ?? Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: feature['details']['keyPoints'].take(3).map<Widget>((point) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: feature['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    point,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: feature['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
              if (feature['progress'] >= 1.0)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Ready to Launch',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
            blurRadius: 12.r,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
        child: Icon(Icons.auto_awesome, color: Colors.white, size: 24.sp),
        onPressed: () => _showNewsletterSignup(),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, size: 24.sp, color: AppColors.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blue[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem(
                    'New F&O Contract Available',
                    'HDFC Nifty 50 ETF options now available for trading',
                    Icons.trending_up,
                    Colors.green,
                    '2 min ago',
                  ),
                  _buildNotificationItem(
                    'Fund Performance Alert',
                    'SBI Healthcare Fund up 15% this month',
                    Icons.show_chart,
                    Colors.blue,
                    '1 hour ago',
                  ),
                  _buildNotificationItem(
                    'New Fund Launch',
                    'Axis ESG Equity Fund is now open for investment',
                    Icons.new_releases,
                    Colors.orange,
                    '3 hours ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, IconData icon, Color color, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor ?? Colors.blue[900],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.secondaryText ?? Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFundDetails(Map<String, dynamic> fund) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: fund['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(fund['icon'], size: 20.sp, color: fund['color']),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    fund['fundName'],
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fund Details',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Category', fund['category']),
                    _buildDetailRow('Fund Manager', fund['fundManager']),
                    _buildDetailRow('Launch Date', fund['launchDate']),
                    _buildDetailRow('Minimum SIP', '₹${fund['minSip']}'),
                    _buildDetailRow('Minimum Investment', '₹${fund['minInvestment']}'),
                    _buildDetailRow('Expense Ratio', '${fund['expenseRatio']}%'),
                    _buildDetailRow('AUM', '₹${fund['aum']} Crores'),
                    SizedBox(height: 20.h),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      fund['description'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor ?? Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  void _investInFund(Map<String, dynamic> fund) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.rocket_launch, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Starting investment in ${fund['fundName']}'),
          ],
        ),
        backgroundColor: fund['color'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _showNewsletterSignup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 32.sp,
                color: AppColors.primaryGold ?? const Color(0xFFDAA520),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Stay Updated',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor ?? Colors.blue[900],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Get notified about new fund launches, F&O opportunities, and feature updates',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.secondaryText ?? Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter your email',
                labelStyle: TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColors.secondaryText,
                ),
              ),
              style: TextStyle(color: AppColors.primaryColor),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('Successfully subscribed to updates!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  );
                },
                child: Text(
                  'Subscribe to Updates',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter & Sort Options',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor ?? Colors.blue[900],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
                      DropdownMenuItem(value: 'progress', child: Text('Sort by Progress')),
                      DropdownMenuItem(value: 'releaseDate', child: Text('Sort by Release Date')),
                    ],
                    onChanged: (value) => setState(() => _sortBy = value!),
                    style: TextStyle(color: AppColors.primaryColor, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            CheckboxListTile(
              title: Text(
                'Show Favorites Only',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
              value: _showFavoritesOnly,
              onChanged: (value) => setState(() => _showFavoritesOnly = value!),
              activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _scrollToFeature(int index) {
    final offset = (index * (200.h + 16.h)) + 600.h; // Account for F&O and recent funds sections
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToDetail(Map<String, dynamic> feature) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LaunchpadDetailsScreen(
          feature: feature,
          isFavorite: _favorites[feature['title']]!,
          onFavoriteToggle: () => setState(() => _favorites[feature['title']] = !_favorites[feature['title']]!),
          onShare: () => _shareFeature(feature),
        ),
      ),
    );
  }

  void _shareFeature(Map<String, dynamic> feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.share, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text('Sharing ${feature['title']}'),
          ],
        ),
        backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}

// Details Screen
class LaunchpadDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> feature;
  final bool isFavorite;
  final Function() onFavoriteToggle;
  final Function() onShare;

  const LaunchpadDetailsScreen({
    Key? key,
    required this.feature,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final details = feature['details'];
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Feature Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor ?? Colors.blue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor ?? Colors.blue,
                AppColors.primaryGold ?? const Color(0xFFDAA520),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: onFavoriteToggle,
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: feature['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 32.sp,
                          color: feature['color'],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'],
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor ?? Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Coming ${details['releaseDate']}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: feature['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Development Progress',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  LinearProgressIndicator(
                    value: feature['progress'],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(feature['color']),
                    minHeight: 8.h,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${(feature['progress'] * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.secondaryText ?? Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    details['description'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.secondaryText ?? Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...details['keyPoints'].map<Widget>((point) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: feature['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.secondaryText ?? Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  SizedBox(height: 20.h),
                  Text(
                    'Investment Strategies',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: details['strategies'].map<Widget>((strategy) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: feature['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: feature['color'].withOpacity(0.3)),
                      ),
                      child: Text(
                        strategy,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: feature['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learning Resources',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...details['resources'].map<Widget>((resource) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: feature['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.library_books,
                        size: 20.sp,
                        color: feature['color'],
                      ),
                    ),
                    title: Text(
                      resource['title'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    subtitle: Text(
                      resource['url'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                    trailing: Icon(
                      Icons.open_in_new,
                      size: 16.sp,
                      color: feature['color'],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${resource['title']}'),
                          backgroundColor: feature['color'],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      );
                    },
                  )).toList(),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            if (feature['progress'] >= 1.0)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48.sp, color: Colors.green),
                    SizedBox(height: 12.h),
                    Text(
                      'Ready to Launch!',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'This feature is complete and ready for release',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.notifications_active, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text('You\'ll be notified when this feature launches'),
                            ],
                          ),
                          backgroundColor: feature['color'],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      );
                    },
                    icon: Icon(Icons.notifications_outlined, size: 20.sp),
                    label: Text(
                      'Notify Me',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      side: BorderSide(color: feature['color']),
                      foregroundColor: feature['color'],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.info, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text('More details coming soon!'),
                            ],
                          ),
                          backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      );
                    },
                    icon: Icon(Icons.info_outline, size: 20.sp),
                    label: Text(
                      'Learn More',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feature['color'],
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}