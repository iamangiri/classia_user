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
  bool _isLoading = false;

  // Real features data
  List<Map<String, dynamic>> foMutualFunds = [];
  List<Map<String, dynamic>> recentLaunchedFunds = [];
  List<Map<String, dynamic>> upcomingFeatures = [];

  Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load real features
      _loadUpcomingFeatures();
      _initializeFavorites();

      // TODO: Load F&O data from API
      // await _loadFOData();

      // TODO: Load recent funds from API
      // await _loadRecentFunds();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadUpcomingFeatures() {
    upcomingFeatures = [


      {
        'title': 'Profit in Hours',
        'progress': 0.90,
        'color': const Color(0xFFF59E0B),
        'details': {
          'description': 'Execute quick trades and capture market movements within hours. Perfect for active traders looking for short-term opportunities.',
          'keyPoints': ['Fast Execution', 'Real-time Analytics', 'Smart Alerts'],
          'releaseDate': 'Q1 2025',
          'strategies': ['Scalping strategies', 'News-based trading', 'Technical analysis'],
          'videoUrl': '',
          'resources': [
            {'title': 'Short-term Trading', 'url': 'https://www.zerodha.com'},
            {'title': 'Market Timing Guide', 'url': 'https://www.upstox.com'},
          ],
        },
      },
      {
        'title': 'Smart Portfolio Rebalancing',
        'progress': 0.75,
        'color': const Color(0xFF8B5CF6),
        'details': {
          'description': 'Automatically rebalance your portfolio based on market conditions and your investment goals. Keep your portfolio optimized.',
          'keyPoints': ['Auto-Rebalancing', 'Tax Optimization', 'Goal Alignment'],
          'releaseDate': 'Q2 2025',
          'strategies': ['Threshold rebalancing', 'Periodic rebalancing', 'Tax-loss harvesting'],
          'videoUrl': '',
          'resources': [
            {'title': 'Portfolio Rebalancing', 'url': 'https://www.morningstar.com'},
            {'title': 'Tax-efficient Investing', 'url': 'https://www.valueresearchonline.com'},
          ],
        },
      },
      {
        'title': 'AI-Powered Recommendations',
        'progress': 0.60,
        'color': const Color(0xFF6366F1),
        'details': {
          'description': 'Get personalized investment recommendations powered by artificial intelligence. Smart suggestions based on your risk profile and goals.',
          'keyPoints': ['Personalized Insights', 'Risk Assessment', 'Goal Planning'],
          'releaseDate': 'Q2 2025',
          'strategies': ['AI fund selection', 'Risk profiling', 'Performance prediction'],
          'videoUrl': '',
          'resources': [
            {'title': 'AI in Finance', 'url': 'https://www.investopedia.com'},
            {'title': 'Robo Advisory Guide', 'url': 'https://www.moneycontrol.com'},
          ],
        },
      },
      {
        'title': 'Social Investment Community',
        'progress': 0.40,
        'color': const Color(0xFF14B8A6),
        'details': {
          'description': 'Connect with fellow investors, share insights, and learn from experienced traders. Join discussion forums and follow top performers.',
          'keyPoints': ['Community Forums', 'Expert Insights', 'Strategy Sharing'],
          'releaseDate': 'Q3 2025',
          'strategies': ['Follow leaders', 'Discussion boards', 'Portfolio sharing'],
          'videoUrl': '',
          'resources': [
            {'title': 'Investment Communities', 'url': 'https://www.reddit.com/r/investing'},
            {'title': 'Social Trading', 'url': 'https://www.etoro.com'},
          ],
        },
      },
    ];
  }

  void _initializeFavorites() {
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
      final matchesFavorite = !_showFavoritesOnly || (_favorites[feature['title']] ?? false);
      return matchesFavorite;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'progress') {
        return (b['progress'] ?? 0).compareTo(a['progress'] ?? 0);
      } else if (_sortBy == 'releaseDate') {
        return (a['details']['releaseDate'] ?? '').compareTo(b['details']['releaseDate'] ?? '');
      }
      return (a['title'] ?? '').compareTo(b['title'] ?? '');
    });

    return filtered;
  }

  bool get _isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildModernAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeroSection(),
              if (foMutualFunds.isNotEmpty) _buildFOSection(),
              if (recentLaunchedFunds.isNotEmpty) _buildRecentLaunchedFunds(),
              _buildUpcomingFeaturesSection(),
              SizedBox(height: 24.h),
            ],
          ),
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
          fontSize: _isLandscape ? 16.sp : 19.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white, size: 24.sp),
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
          icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 22.sp),
          onPressed: _showNotifications,
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: Icon(Icons.filter_list_alt, color: Colors.white, size: 22.sp),
          onPressed: _showFilterModal,
          tooltip: 'Filter',
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: EdgeInsets.all(_isLandscape ? 16.w : 20.w),
      padding: EdgeInsets.all(_isLandscape ? 20.w : 24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
            AppColors.primaryGold?.withOpacity(0.1) ?? Colors.amber.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primaryColor?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: _isLandscape ? _buildHeroLandscape() : _buildHeroPortrait(),
    );
  }

  Widget _buildHeroPortrait() {
    return Column(
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
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor ?? Colors.blue[900],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Trade smart with basket investing, make profits in hours with intraday strategies',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.secondaryText ?? Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHeroLandscape() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.rocket_launch_outlined,
            size: 32.sp,
            color: AppColors.primaryColor ?? Colors.blue,
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Investment Hub',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Trade smart with basket investing, make profits in hours with intraday strategies',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondaryText ?? Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFOSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _isLandscape ? 16.w : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'F&O on Mutual Funds',
            'Trade futures and options on ETFs and mutual fund schemes',
            Icons.trending_up,
            const Color(0xFFEF4444),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: _isLandscape ? 160.h : 195.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: foMutualFunds.length,
              itemBuilder: (context, index) => _buildFOCard(foMutualFunds[index]),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildFOCard(Map<String, dynamic> foData) {
    return Container(
      width: _isLandscape ? 240.w : 280.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_isLandscape ? 16.w : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foData['fundName'] ?? '',
                    style: TextStyle(
                      fontSize: _isLandscape ? 14.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor ?? Colors.blue[900],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: foData['type'] == 'CALL' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    foData['type'] ?? '',
                    style: TextStyle(
                      fontSize: 10.sp,
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
                        fontSize: 11.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹${(foData['premium'] ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: _isLandscape ? 16.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: foData['color'] ?? Colors.green,
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
                        fontSize: 11.sp,
                        color: AppColors.secondaryText ?? Colors.grey[600],
                      ),
                    ),
                    Text(
                      '₹${(foData['strikePrice'] ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: _isLandscape ? 14.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Icon(Icons.access_time, size: 12.sp, color: AppColors.secondaryText),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Expiry: ${foData['expiry'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.secondaryText ?? Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vol: ${((foData['volume'] ?? 0) / 1000).toStringAsFixed(1)}K',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.secondaryText ?? Colors.grey[600],
                  ),
                ),
                Text(
                  '${(foData['changePercent'] ?? 0) > 0 ? '+' : ''}${(foData['changePercent'] ?? 0).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: foData['color'] ?? Colors.grey,
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
      margin: EdgeInsets.all(_isLandscape ? 16.w : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Recently Launched Funds',
            'Discover new investment opportunities with fresh fund launches',
            Icons.new_releases_outlined,
            const Color(0xFF10B981),
          ),
          SizedBox(height: 16.h),
          if (_isLandscape)
            _buildFundsGrid()
          else
            ...recentLaunchedFunds.asMap().entries.map((entry) {
              return _buildRecentFundCard(entry.value, entry.key);
            }),
        ],
      ),
    );
  }

  Widget _buildFundsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: recentLaunchedFunds.length,
      itemBuilder: (context, index) => _buildRecentFundCard(recentLaunchedFunds[index], index),
    );
  }

  Widget _buildRecentFundCard(Map<String, dynamic> fund, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: _isLandscape ? 0 : 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_isLandscape ? 16.w : 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: _isLandscape ? 48.w : 56.w,
                  height: _isLandscape ? 48.w : 56.w,
                  decoration: BoxDecoration(
                    color: (fund['color'] as Color?)?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    fund['icon'] ?? Icons.account_balance,
                    size: _isLandscape ? 24.sp : 28.sp,
                    color: fund['color'] ?? Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund['fundName'] ?? '',
                        style: TextStyle(
                          fontSize: _isLandscape ? 14.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor ?? Colors.blue[900],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        fund['category'] ?? '',
                        style: TextStyle(
                          fontSize: _isLandscape ? 11.sp : 13.sp,
                          color: fund['color'] ?? Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    (_favorites[fund['fundName']] ?? false) ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                    size: 20.sp,
                  ),
                  onPressed: () => setState(() => _favorites[fund['fundName']] = !(_favorites[fund['fundName']] ?? false)),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              fund['description'] ?? '',
              style: TextStyle(
                fontSize: _isLandscape ? 11.sp : 13.sp,
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
              children: ((fund['keyFeatures'] as List?) ?? []).take(3).map<Widget>((feature) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (fund['color'] as Color?)?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  feature.toString(),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: fund['color'] ?? Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFundStat('NAV', '₹${fund['nav']?.toString() ?? '0'}'),
                      _buildFundStat('Min SIP', '₹${fund['minSip']?.toString() ?? '0'}'),
                      _buildFundStat('AUM', '₹${fund['aum']?.toString() ?? '0'}Cr'),
                      _buildFundStat('Rating', '${fund['rating']?.toString() ?? '0'}⭐'),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Launched: ${fund['launchDate'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primaryColor ?? Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showFundDetails(fund),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      side: BorderSide(color: fund['color'] ?? Colors.blue),
                    ),
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: _isLandscape ? 11.sp : 13.sp,
                        fontWeight: FontWeight.w600,
                        color: fund['color'] ?? Colors.blue,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _investInFund(fund),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fund['color'] ?? Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 2,
                    ),
                    child: Text(
                      'Invest',
                      style: TextStyle(
                        fontSize: _isLandscape ? 11.sp : 13.sp,
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
            fontSize: _isLandscape ? 11.sp : 13.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor ?? Colors.blue[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: AppColors.secondaryText ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingFeaturesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _isLandscape ? 16.w : 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Upcoming Features',
            'Revolutionary features to transform your investment experience',
            Icons.upcoming_outlined,
            const Color(0xFF8B5CF6),
          ),
          SizedBox(height: 16.h),
          _filteredFeatures.isEmpty
              ? _buildEmptyFilterState()
              : _isLandscape
              ? _buildFeaturesGrid()
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

  Widget _buildFeaturesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredFeatures.length,
      itemBuilder: (context, index) => _buildFeatureCard(_filteredFeatures[index], index),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: _isLandscape ? 20.sp : 24.sp,
                color: color,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: _isLandscape ? 18.sp : 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue[900],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.only(left: _isLandscape ? 40.w : 48.w),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: _isLandscape ? 11.sp : 13.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFilterState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
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
    final isReady = (feature['progress'] ?? 0) >= 0.95;

    return Container(
      margin: EdgeInsets.only(bottom: _isLandscape ? 0 : 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
        border: isReady ? Border.all(color: Colors.green.withOpacity(0.3), width: 2) : null,
      ),
      child: InkWell(
        onTap: (){},
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(_isLandscape ? 16.w : 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: _isLandscape ? 40.w : 50.w,
                        height: _isLandscape ? 40.h : 50.h,
                        child: CircularProgressIndicator(
                          value: feature['progress'] ?? 0,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(feature['color'] ?? Colors.blue),
                        ),
                      ),
                      Text(
                        '${((feature['progress'] ?? 0) * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: _isLandscape ? 10.sp : 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor ?? Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] ?? '',
                          style: TextStyle(
                            fontSize: _isLandscape ? 14.sp : 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor ?? Colors.blue[900],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isReady
                                ? Colors.green.withOpacity(0.1)
                                : (feature['color'] as Color?)?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isReady ? 'Almost Ready!' : 'Coming ${feature['details']?['releaseDate'] ?? 'Soon'}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: isReady ? Colors.green : feature['color'] ?? Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      (_favorites[feature['title']] ?? false) ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                      size: 20.sp,
                    ),
                    onPressed: () => setState(() => _favorites[feature['title']] = !(_favorites[feature['title']] ?? false)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                feature['details']?['description'] ?? '',
                style: TextStyle(
                  fontSize: _isLandscape ? 11.sp : 13.sp,
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
                children: ((feature['details']?['keyPoints'] as List?) ?? []).take(3).map<Widget>((point) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color?)?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    point.toString(),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: feature['color'] ?? Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )).toList(),
              ),
              if (isReady)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Icon(Icons.rocket_launch, color: Colors.green, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Launching Soon',
                        style: TextStyle(
                          fontSize: 11.sp,
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
    return FloatingActionButton(
      backgroundColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
      child: Icon(Icons.auto_awesome, color: Colors.white, size: 24.sp),
      onPressed: () => _showNewsletterSignup(),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 60.sp, color: Colors.grey[300]),
                    SizedBox(height: 16.h),
                    Text(
                      'No new notifications',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'We\'ll notify you about new features',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[400],
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

  void _showFundDetails(Map<String, dynamic> fund) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                    color: (fund['color'] as Color?)?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(fund['icon'] ?? Icons.account_balance, size: 20.sp, color: fund['color'] ?? Colors.blue),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    fund['fundName'] ?? '',
                    style: TextStyle(
                      fontSize: 18.sp,
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Category', fund['category']?.toString() ?? 'N/A'),
                    _buildDetailRow('Fund Manager', fund['fundManager']?.toString() ?? 'N/A'),
                    _buildDetailRow('Launch Date', fund['launchDate']?.toString() ?? 'N/A'),
                    _buildDetailRow('Minimum SIP', '₹${fund['minSip']?.toString() ?? '0'}'),
                    _buildDetailRow('Minimum Investment', '₹${fund['minInvestment']?.toString() ?? '0'}'),
                    _buildDetailRow('Expense Ratio', '${fund['expenseRatio']?.toString() ?? '0'}%'),
                    _buildDetailRow('AUM', '₹${fund['aum']?.toString() ?? '0'} Crores'),
                    SizedBox(height: 20.h),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      fund['description']?.toString() ?? 'No description available',
                      style: TextStyle(
                        fontSize: 13.sp,
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
              fontSize: 13.sp,
              color: AppColors.secondaryText ?? Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
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
            Icon(Icons.rocket_launch, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Starting investment in ${fund['fundName'] ?? 'fund'}',
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ],
        ),
        backgroundColor: fund['color'] ?? Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor ?? Colors.blue[900],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Get notified when basket investing and intraday trading features launch',
              style: TextStyle(
                fontSize: 13.sp,
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
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text('Successfully subscribed to updates!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  );
                },
                child: Text(
                  'Subscribe to Updates',
                  style: TextStyle(
                    fontSize: 14.sp,
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter & Sort Options',
                style: TextStyle(
                  fontSize: 18.sp,
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor ?? Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
                        DropdownMenuItem(value: 'progress', child: Text('Sort by Progress')),
                        DropdownMenuItem(value: 'releaseDate', child: Text('Sort by Release Date')),
                      ],
                      onChanged: (value) {
                        setState(() => _sortBy = value!);
                        setModalState(() {});
                      },
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              CheckboxListTile(
                title: Text(
                  'Show Favorites Only',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryColor ?? Colors.blue[900],
                  ),
                ),
                value: _showFavoritesOnly,
                onChanged: (value) {
                  setState(() => _showFavoritesOnly = value!);
                  setModalState(() {});
                },
                activeColor: AppColors.primaryGold ?? const Color(0xFFDAA520),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> feature) {
    // TODO: Implement navigation to detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${feature['title'] ?? 'feature'} details...'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: feature['color'] ?? Colors.blue,
      ),
    );
  }
}