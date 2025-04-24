import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';

class LaunchpadScreen extends StatefulWidget {
  @override
  _LaunchpadScreenState createState() => _LaunchpadScreenState();
}

class _LaunchpadScreenState extends State<LaunchpadScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'title'; // Default sorting
  bool _showFavoritesOnly = false;

  final List<Map<String, dynamic>> upcomingFeatures = [
    {
      'title': 'New Mutual Fund Schemes',
      'progress': 0.8,
      'color': Colors.green,
      'details': {
        'description': 'Explore fresh investment opportunities with new mutual fund schemes launching soon.',
        'keyPoints': ['Equity Funds', 'Debt Funds', 'Hybrid Funds'],
        'releaseDate': 'Q1 2025',
        'strategies': ['Research fund managers', 'Analyze past performance', 'Diversify investments'],
        'videoUrl': 'https://example.com/new-schemes-video',
        'resources': [
          {'title': 'AMFI: Fund Basics', 'url': 'https://www.amfiindia.com'},
          {'title': 'Moneycontrol: Fund News', 'url': 'https://www.moneycontrol.com'},
        ],
      },
    },
    {
      'title': 'Live Portfolio Analytics',
      'progress': 0.6,
      'color': Colors.blue,
      'details': {
        'description': 'Track your mutual fund investments with real-time analytics and insights.',
        'keyPoints': ['Performance Charts', 'Risk Analysis', 'Goal Tracking'],
        'releaseDate': 'Q2 2025',
        'strategies': ['Set investment goals', 'Monitor regularly', 'Adjust allocations'],
        'videoUrl': 'https://example.com/portfolio-analytics-video',
        'resources': [
          {'title': 'Morningstar: Portfolio Tools', 'url': 'https://www.morningstar.com'},
          {'title': 'Value Research Online', 'url': 'https://www.valueresearchonline.com'},
        ],
      },
    },
    {
      'title': 'Educational Hub',
      'progress': 0.4,
      'color': Colors.orange,
      'details': {
        'description': 'Learn mutual fund investing with free courses, webinars, and guides.',
        'keyPoints': ['Beginner Guides', 'Webinars', 'Investment Strategies'],
        'releaseDate': 'Q3 2025',
        'strategies': ['Join live sessions', 'Read case studies', 'Practice with simulators'],
        'videoUrl': 'https://example.com/educational-hub-video',
        'resources': [
          {'title': 'Investopedia: Investing Basics', 'url': 'https://www.investopedia.com'},
          {'title': 'SEBI Investor Education', 'url': 'https://investor.sebi.gov.in'},
        ],
      },
    },
  ];

  final List<Map<String, dynamic>> marketUpdates = [
    {
      'fundName': 'SBI Bluechip Fund',
      'nav': 82.45,
      'change': 1.23,
      'changePercent': 1.51,
      'color': Colors.green,
    },
    {
      'fundName': 'HDFC Mid-Cap Opportunities',
      'nav': 145.67,
      'change': -0.89,
      'changePercent': -0.61,
      'color': Colors.red,
    },
    {
      'fundName': 'Axis Long Term Equity',
      'nav': 78.12,
      'change': 0.45,
      'changePercent': 0.58,
      'color': Colors.green,
    },
  ];

  Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    for (var feature in upcomingFeatures) {
      _favorites[feature['title']] = false;
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
      backgroundColor: AppColors.screenBackground,
      appBar: LaunchpadAppBar(
        onFilterPressed: _showFilterModal,
      ),
      body: Column(
        children: [
          _buildClippedHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _buildNewsletterFab(),
    );
  }

  Widget _buildClippedHeader() {
    return ClipPath(
      clipper: CustomHeaderClipper(),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryGold.withOpacity(0.8), AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Features',
                style: TextStyle(
                  color: AppColors.buttonText,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcomingFeatures.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _scrollToFeature(index),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.buttonText.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          upcomingFeatures[index]['title'],
                          style: TextStyle(
                            color: AppColors.buttonText,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMarketUpdatesSection(),
          SizedBox(height: 24.h),
          Text(
            'What’s Coming Next',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _filteredFeatures.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline, size: 60.sp, color: AppColors.secondaryText),
                SizedBox(height: 16.h),
                Text(
                  'No features found',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 18.sp),
                ),
              ],
            ),
          )
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

  Widget _buildMarketUpdatesSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBackground, AppColors.accent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Mutual Fund Market',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Placeholder: Real-time Fund Performance Chart',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Top Funds Today',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          ...marketUpdates.map((fund) => ListTile(
            title: Text(
              fund['fundName'],
              style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp),
            ),
            subtitle: Text(
              'NAV: ₹${fund['nav'].toStringAsFixed(2)}',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp),
            ),
            trailing: Text(
              '${fund['change'] > 0 ? '+' : ''}${fund['change'].toStringAsFixed(2)} (${fund['changePercent'].toStringAsFixed(2)}%)',
              style: TextStyle(
                color: fund['color'],
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing ${fund['fundName']} details'),
                  backgroundColor: AppColors.primaryGold,
                ),
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBackground, feature['color'].withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(feature),
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildProgressIndicator(feature),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'],
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            _buildReleaseBadge(feature['details']['releaseDate']),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _favorites[feature['title']]! ? Icons.favorite : Icons.favorite_border,
                          color: AppColors.primaryGold,
                        ),
                        onPressed: () => setState(() => _favorites[feature['title']] = !_favorites[feature['title']]!),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    feature['details']['description'],
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  _buildKeyPointsPreview(feature['details']['keyPoints']),
                ],
              ),
            ),
            if (feature['progress'] >= 1.0)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> feature) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50.w,
          height: 50.h,
          child: CircularProgressIndicator(
            value: feature['progress'],
            strokeWidth: 5,
            backgroundColor: AppColors.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(feature['color']),
          ),
        ),
        Text(
          '${(feature['progress'] * 100).toInt()}%',
          style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReleaseBadge(String releaseDate) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Text(
        'Coming $releaseDate',
        style: TextStyle(color: AppColors.accent, fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildKeyPointsPreview(List<String> keyPoints) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: keyPoints.take(3).map((point) => Chip(
        label: Text(point, style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp)),
        backgroundColor: AppColors.cardBackground.withOpacity(0.8),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
        elevation: 2,
      )).toList(),
    );
  }

  Widget _buildNewsletterFab() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.3),
            blurRadius: 10.r,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: AppColors.primaryGold.withOpacity(0.9),
        child: Icon(Icons.email, color: AppColors.buttonText, size: 24.sp),
        onPressed: () => _showNewsletterSignup(),
      ),
    );
  }

  void _showNewsletterSignup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stay Updated',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter your email',
                labelStyle: TextStyle(color: AppColors.secondaryText),
                filled: true,
                fillColor: AppColors.border.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: AppColors.primaryText),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subscribed to newsletter!'),
                    backgroundColor: AppColors.primaryGold,
                  ),
                );
              },
              child: Text(
                'Subscribe',
                style: TextStyle(color: AppColors.buttonText, fontSize: 16.sp),
              ),
            ),
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
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter & Sort',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButton<String>(
              value: _sortBy,
              items: [
                DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
                DropdownMenuItem(value: 'progress', child: Text('Sort by Progress')),
                DropdownMenuItem(value: 'releaseDate', child: Text('Sort by Release Date')),
              ],
              onChanged: (value) => setState(() => _sortBy = value!),
              isExpanded: true,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
            ),
            CheckboxListTile(
              title: Text('Show Favorites Only', style: TextStyle(color: AppColors.primaryText)),
              value: _showFavoritesOnly,
              onChanged: (value) => setState(() => _showFavoritesOnly = value!),
              activeColor: AppColors.primaryGold,
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToFeature(int index) {
    final offset = (index * (200.h + 16.h)) + 300.h; // Account for market section height
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
        content: Text('Sharing ${feature['title']}'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }
}

class CustomHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30.h);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 30.h);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LaunchpadAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onFilterPressed;

  const LaunchpadAppBar({Key? key, required this.onFilterPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGold.withOpacity(0.8), AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Launchpad',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primaryText),
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

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
      backgroundColor: AppColors.screenBackground,
      appBar: LaunchpadAppBar(
        onFilterPressed: () {}, // No filter in details screen
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressSection(),
            SizedBox(height: 16.h),
            _buildSection('📘 Overview', Text(details['description'], style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp))),
            _buildSection('🎯 Key Features', _buildKeyPoints(details['keyPoints'])),
            _buildSection('🎥 Video Preview', _buildVideoPlaceholder(details['videoUrl'])),
            _buildSection('📈 Strategies', _buildStrategies(details['strategies'])),
            _buildSection('📚 Resources', _buildResources(details['resources'], context)),
            SizedBox(height: 16.h),
            _buildLearnMoreButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Development Progress',
            style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: feature['progress'],
            backgroundColor: AppColors.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(feature['color']),
          ),
          SizedBox(height: 8.h),
          Text(
            'Expected Release: ${feature['details']['releaseDate']}',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          content,
        ],
      ),
    );
  }

  Widget _buildKeyPoints(List<String> points) {
    return Column(
      children: points.map((point) => ListTile(
        leading: Icon(Icons.circle, size: 8.sp, color: AppColors.primaryGold),
        title: Text(point, style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp)),
      )).toList(),
    );
  }

  Widget _buildVideoPlaceholder(String videoUrl) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle, size: 48.sp, color: AppColors.secondaryText),
            SizedBox(height: 8.h),
            Text(
              'Watch Feature Preview',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategies(List<String> strategies) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: strategies.map((strategy) => Chip(
        label: Text(strategy, style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp)),
        backgroundColor: AppColors.cardBackground,
        side: BorderSide(color: AppColors.border),
        avatar: Icon(Icons.star, size: 16.sp, color: AppColors.primaryGold),
      )).toList(),
    );
  }

  Widget _buildResources(List<Map<String, String>> resources, BuildContext context) {
    return Column(
      children: resources.map((resource) => ListTile(
        title: Text(resource['title']!, style: TextStyle(color: AppColors.primaryText, fontSize: 14.sp)),
        subtitle: Text(resource['url']!, style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp)),
        trailing: Icon(Icons.open_in_new, color: AppColors.primaryGold, size: 16.sp),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${resource['url']}'), backgroundColor: AppColors.primaryGold),
          );
        },
      )).toList(),
    );
  }

  Widget _buildLearnMoreButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.info, color: AppColors.buttonText, size: 20.sp),
        label: Text('Learn More', style: TextStyle(color: AppColors.buttonText, fontSize: 16.sp)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('More details about ${feature['title']}'),
              backgroundColor: AppColors.primaryGold,
            ),
          );
        },
      ),
    );
  }
}