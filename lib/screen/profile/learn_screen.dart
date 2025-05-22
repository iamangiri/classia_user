import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/learn_app_bar.dart';
import 'package:provider/provider.dart';

class UserPoints with ChangeNotifier {
  int _points = 1000;
  int get points => _points;

  void investPoints(int amount) {
    if (_points >= amount) {
      _points -= amount;
      notifyListeners();
    }
  }

  void withdrawPoints(int amount) {
    _points += amount;
    notifyListeners();
  }

  void convertPoints() {
    _points -= 1000; // Assuming 1000 points are converted
    notifyListeners();
  }
}

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String _sortBy = 'title';
  bool _showBookmarkedOnly = false;
  bool _showCompletedOnly = false;

  final List<Map<String, dynamic>> topics = [
    {
      'title': 'Stock Market Trading',
      'progress': 0.0,
      'color': Colors.blue,
      'details': {
        'difficulty': 'Intermediate',
        'description': 'Learn the fundamentals of stock market trading, including technical analysis, portfolio management, and risk management.',
        'keyPoints': ['Technical Analysis', 'Fundamental Analysis', 'Risk Management', 'Portfolio Management'],
        'example': 'Example: Analyzing a company’s balance sheet to determine its investment potential.',
        'strategies': ['Attend webinars', 'Practice trading on simulators', 'Follow market news'],
        'videoUrl': 'https://example.com/stock-trading-video',
        'resources': [
          {'title': 'Investopedia: Stock Basics', 'url': 'https://www.investopedia.com/stocks'},
          {'title': 'Bloomberg Market News', 'url': 'https://www.bloomberg.com/markets'},
        ],
      },
    },
    {
      'title': 'How to Use This App',
      'progress': 0.0,
      'color': Colors.teal,
      'details': {
        'difficulty': 'Beginner',
        'description': 'A step-by-step guide on how to navigate and use this app effectively.',
        'keyPoints': ['Navigation', 'Trading Points', 'Course Completion', 'Certificates'],
        'example': 'Example: Access your points from the app bar and trade them in the trading section.',
        'strategies': ['Watch the tutorial video', 'Explore each section', 'Complete a practice quiz'],
        'videoUrl': 'https://example.com/app-usage-video',
        'resources': [
          {'title': 'App User Guide', 'url': 'https://example.com/user-guide'},
        ],
      },
    },
    // Other existing topics remain unchanged
  ];

  Map<String, bool> _bookmarks = {};
  Map<String, double> _progress = {};
  Map<String, bool> _completed = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    for (var topic in topics) {
      _progress[topic['title']] = topic['progress'];
      _bookmarks[topic['title']] = false;
      _completed[topic['title']] = false;
    }
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTopics {
    final selectedDifficulty = ['All', 'Beginner', 'Intermediate', 'Advanced'][_tabController.index];
    var filtered = topics.where((topic) {
      final matchesSearch = topic['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDifficulty = selectedDifficulty == 'All' || topic['details']['difficulty'] == selectedDifficulty;
      final matchesBookmark = !_showBookmarkedOnly || _bookmarks[topic['title']]!;
      final matchesCompletion = !_showCompletedOnly || _progress[topic['title']]! >= 1.0;
      return matchesSearch && matchesDifficulty && matchesBookmark && matchesCompletion;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'progress') {
        return _progress[b['title']]!.compareTo(_progress[a['title']]!);
      } else if (_sortBy == 'difficulty') {
        const order = {'Beginner': 1, 'Intermediate': 2, 'Advanced': 3};
        return order[a['details']['difficulty']]!.compareTo(order[b['details']['difficulty']]!);
      }
      return a['title'].compareTo(b['title']);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserPoints(),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: LearnAppBar(
          title: 'Learn',
          searchController: _searchController,
          showSearch: true,
          actions: [
            Consumer<UserPoints>(
              builder: (context, userPoints, child) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  'Points: ${userPoints.points}',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 16.sp),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: AppColors.primaryGold),
              onPressed: _showFilterModal,
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.primaryGold),
              onPressed: _confirmResetProgress,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildClippedHeader(),
            Container(
              color: AppColors.cardBackground,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryGold,
                labelColor: AppColors.primaryText,
                unselectedLabelColor: AppColors.secondaryText,
                labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Beginner'),
                  Tab(text: 'Intermediate'),
                  Tab(text: 'Advanced'),
                ],
                onTap: (index) => setState(() {}),
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
        floatingActionButton: _buildProgressFab(),
      ),
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
                'Explore Topics',
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
                  itemCount: topics.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => _scrollToTopic(index),
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
                          topics[index]['title'],
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
    if (_filteredTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 60.sp, color: AppColors.secondaryText),
            SizedBox(height: 16.h),
            Text(
              'No topics found',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 18.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) => _buildTopicCard(_filteredTopics[index]),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    final isCompleted = _progress[topic['title']]! >= 1.0;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardBackground, topic['color'].withOpacity(0.1)],
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
        onTap: () => _navigateToDetail(topic),
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
                      _buildProgressIndicator(topic),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic['title'],
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            _buildDifficultyBadge(topic['details']['difficulty']),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _bookmarks[topic['title']]! ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.primaryGold,
                        ),
                        onPressed: () => setState(() => _bookmarks[topic['title']] = !_bookmarks[topic['title']]!),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    topic['details']['description'],
                    style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  _buildKeyPointsPreview(topic['details']['keyPoints']),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PointsTradingScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text('Trade Points', style: TextStyle(color: AppColors.buttonText)),
                      ),
                      if (isCompleted)
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CertificateScreen(courseTitle: topic['title']),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: Text('View Certificate', style: TextStyle(color: AppColors.buttonText)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted)
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

  Widget _buildProgressIndicator(Map<String, dynamic> topic) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50.w,
          height: 50.h,
          child: CircularProgressIndicator(
            value: _progress[topic['title']],
            strokeWidth: 5,
            backgroundColor: AppColors.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
          ),
        ),
        Text(
          '${(_progress[topic['title']]! * 100).toInt()}%',
          style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Beginner':
        color = AppColors.success;
        break;
      case 'Intermediate':
        color = AppColors.accent;
        break;
      case 'Advanced':
        color = AppColors.error;
        break;
      default:
        color = AppColors.border;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        difficulty,
        style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w600),
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

  Widget _buildProgressFab() {
    final totalProgress = _progress.values.fold(0.0, (sum, progress) => sum + progress) / _progress.length;

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
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: totalProgress,
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
              backgroundColor: AppColors.buttonText.withOpacity(0.3),
            ),
            Text(
              '${(totalProgress * 100).toInt()}%',
              style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onPressed: () => _showOverallProgress(),
      ),
    );
  }

  void _showOverallProgress() {
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
              'Learning Progress',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...topics.map((topic) => ListTile(
              title: Text(topic['title'], style: TextStyle(color: AppColors.primaryText)),
              subtitle: LinearProgressIndicator(
                value: _progress[topic['title']],
                backgroundColor: AppColors.border.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
              ),
              trailing: Text(
                '${(_progress[topic['title']]! * 100).toInt()}%',
                style: TextStyle(color: AppColors.secondaryText),
              ),
            )).toList(),
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
                DropdownMenuItem(value: 'difficulty', child: Text('Sort by Difficulty')),
              ],
              onChanged: (value) => setState(() => _sortBy = value!),
              isExpanded: true,
              style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
            ),
            CheckboxListTile(
              title: Text('Show Bookmarked Only', style: TextStyle(color: AppColors.primaryText)),
              value: _showBookmarkedOnly,
              onChanged: (value) => setState(() => _showBookmarkedOnly = value!),
              activeColor: AppColors.primaryGold,
            ),
            CheckboxListTile(
              title: Text('Show Completed Only', style: TextStyle(color: AppColors.primaryText)),
              value: _showCompletedOnly,
              onChanged: (value) => setState(() => _showCompletedOnly = value!),
              activeColor: AppColors.primaryGold,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Reset Progress', style: TextStyle(color: AppColors.primaryText)),
        content: Text('Are you sure you want to reset all progress?', style: TextStyle(color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _progress.updateAll((key, value) => 0.0);
                _completed.updateAll((key, value) => false);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Progress reset successfully!'),
                  backgroundColor: AppColors.primaryGold,
                ),
              );
            },
            child: Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _scrollToTopic(int index) {
    final offset = index * (200.h + 16.h);
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToDetail(Map<String, dynamic> topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearnDetailsScreen(
          topic: topic,
          onProgressUpdate: (newProgress) {
            setState(() {
              _progress[topic['title']] = newProgress;
              if (newProgress >= 1.0 && !_completed[topic['title']]!) {
                _completed[topic['title']] = true;
                Provider.of<UserPoints>(context, listen: false).convertPoints();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Course completed! 1000 points converted to ₹1000.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            });
          },
          isBookmarked: _bookmarks[topic['title']]!,
          onBookmarkToggle: () => setState(() => _bookmarks[topic['title']] = !_bookmarks[topic['title']]!),
          onShare: () => _shareTopic(topic),
        ),
      ),
    );
  }

  void _shareTopic(Map<String, dynamic> topic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${topic['title']}'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }
}

class PointsTradingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userPoints = Provider.of<UserPoints>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Trade with Points', style: TextStyle(color: AppColors.buttonText)),
        backgroundColor: AppColors.primaryGold,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              'Available Points: ${userPoints.points}',
              style: TextStyle(color: AppColors.primaryText, fontSize: 20.sp),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                userPoints.investPoints(500);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invested 500 points in Mutual Funds')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              child: Text('Invest 500 Points', style: TextStyle(color: AppColors.buttonText)),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {
                userPoints.withdrawPoints(300);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Withdrawn 300 points from Mutual Funds')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: Text('Withdraw 300 Points', style: TextStyle(color: AppColors.buttonText)),
            ),
          ],
        ),
      ),
    );
  }
}

class CertificateScreen extends StatelessWidget {
  final String courseTitle;

  const CertificateScreen({required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificate', style: TextStyle(color: AppColors.buttonText)),
        backgroundColor: AppColors.primaryGold,
      ),
      body: Container(
        color: AppColors.screenBackground,
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primaryGold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Certificate of Completion',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Awarded to: [Your Name]',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 18.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  'For completing: $courseTitle',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 18.sp),
                ),
                SizedBox(height: 20.h),
                Icon(Icons.card_giftcard, color: AppColors.primaryGold, size: 50.sp),
                SizedBox(height: 10.h),
                Text(
                  'Date: ${DateTime.now().toString().split(' ')[0]}',
                  style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Remaining classes (CustomHeaderClipper, LearnDetailsScreen) remain unchanged
// class LearnScreen extends StatefulWidget {
//   @override
//   _LearnScreenState createState() => _LearnScreenState();
// }
//
// class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   late TabController _tabController;
//   final ScrollController _scrollController = ScrollController();
//   String _sortBy = 'title'; // Default sorting
//   bool _showBookmarkedOnly = false;
//   bool _showCompletedOnly = false;
//
//   final List<Map<String, dynamic>> topics = [
//     {
//       'title': 'Stock Market Trading',
//       'progress': 0.0,
//       'color': Colors.blue,
//       'details': {
//         'difficulty': 'Intermediate',
//         'description': 'Learn the fundamentals of stock market trading, including technical analysis, portfolio management, and risk management.',
//         'keyPoints': ['Technical Analysis', 'Fundamental Analysis', 'Risk Management', 'Portfolio Management'],
//         'example': 'Example: Analyzing a company’s balance sheet to determine its investment potential.',
//         'strategies': ['Attend webinars', 'Practice trading on simulators', 'Follow market news'],
//         'videoUrl': 'https://example.com/stock-trading-video',
//         'resources': [
//           {'title': 'Investopedia: Stock Basics', 'url': 'https://www.investopedia.com/stocks'},
//           {'title': 'Bloomberg Market News', 'url': 'https://www.bloomberg.com/markets'},
//         ],
//       },
//     },
//     {
//       'title': 'Forex Trading Basics',
//       'progress': 0.2,
//       'color': Colors.green,
//       'details': {
//         'difficulty': 'Beginner',
//         'description': 'An introduction to Forex trading covering currency pairs, pips, and leverage.',
//         'keyPoints': ['Currency Pairs', 'Pips', 'Leverage'],
//         'example': 'Example: Understanding the EUR/USD currency pair movements.',
//         'strategies': ['Demo trading', 'Monitor economic indicators', 'Follow global news'],
//         'videoUrl': 'https://example.com/forex-trading-video',
//         'resources': [
//           {'title': 'BabyPips: Forex 101', 'url': 'https://www.babypips.com/learn/forex'},
//           {'title': 'Forex Factory', 'url': 'https://www.forexfactory.com'},
//         ],
//       },
//     },
//     {
//       'title': 'Cryptocurrency Trading',
//       'progress': 0.4,
//       'color': Colors.orange,
//       'details': {
//         'difficulty': 'Intermediate',
//         'description': 'Learn how to trade cryptocurrencies, analyze trends, and manage risks in the crypto markets.',
//         'keyPoints': ['Bitcoin', 'Ethereum', 'Altcoins', 'Technical Indicators'],
//         'example': 'Example: Using RSI and MACD to analyze Bitcoin price movements.',
//         'strategies': ['Stay updated with crypto news', 'Use demo accounts', 'Diversify your portfolio'],
//         'videoUrl': 'https://example.com/crypto-trading-video',
//         'resources': [
//           {'title': 'CoinDesk: Crypto News', 'url': 'https://www.coindesk.com'},
//           {'title': 'CoinMarketCap', 'url': 'https://coinmarketcap.com'},
//         ],
//       },
//     },
//     {
//       'title': 'Options Trading',
//       'progress': 0.0,
//       'color': Colors.purple,
//       'details': {
//         'difficulty': 'Advanced',
//         'description': 'Explore options trading strategies, including calls, puts, and spreads.',
//         'keyPoints': ['Calls', 'Puts', 'Spreads', 'Volatility'],
//         'example': 'Example: Using a covered call strategy to generate income.',
//         'strategies': ['Learn from case studies', 'Practice with virtual trading', 'Monitor volatility'],
//         'videoUrl': 'https://example.com/options-trading-video',
//         'resources': [
//           {'title': 'CBOE: Options Basics', 'url': 'https://www.cboe.com/learncenter'},
//           {'title': 'Options Trading Guide', 'url': 'https://www.optionseducation.org'},
//         ],
//       },
//     },
//   ];
//
//   Map<String, bool> _bookmarks = {};
//   Map<String, double> _progress = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     for (var topic in topics) {
//       _progress[topic['title']] = topic['progress'];
//       _bookmarks[topic['title']] = false;
//     }
//     _searchController.addListener(() {
//       setState(() => _searchQuery = _searchController.text);
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   List<Map<String, dynamic>> get _filteredTopics {
//     final selectedDifficulty = ['All', 'Beginner', 'Intermediate', 'Advanced'][_tabController.index];
//     var filtered = topics.where((topic) {
//       final matchesSearch = topic['title'].toLowerCase().contains(_searchQuery.toLowerCase());
//       final matchesDifficulty = selectedDifficulty == 'All' || topic['details']['difficulty'] == selectedDifficulty;
//       final matchesBookmark = !_showBookmarkedOnly || _bookmarks[topic['title']]!;
//       final matchesCompletion = !_showCompletedOnly || _progress[topic['title']]! >= 1.0;
//       return matchesSearch && matchesDifficulty && matchesBookmark && matchesCompletion;
//     }).toList();
//
//     filtered.sort((a, b) {
//       if (_sortBy == 'progress') {
//         return _progress[b['title']]!.compareTo(_progress[a['title']]!);
//       } else if (_sortBy == 'difficulty') {
//         const order = {'Beginner': 1, 'Intermediate': 2, 'Advanced': 3};
//         return order[a['details']['difficulty']]!.compareTo(order[b['details']['difficulty']]!);
//       }
//       return a['title'].compareTo(b['title']);
//     });
//
//     return filtered;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.screenBackground,
//       appBar: LearnAppBar(
//         title: 'Learn',
//         searchController: _searchController,
//         showSearch: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list, color: AppColors.primaryGold),
//             onPressed: _showFilterModal,
//           ),
//           IconButton(
//             icon: Icon(Icons.refresh, color: AppColors.primaryGold),
//             onPressed: _confirmResetProgress,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildClippedHeader(),
//           Container(
//             color: AppColors.cardBackground,
//             child: TabBar(
//               controller: _tabController,
//               indicatorColor: AppColors.primaryGold,
//               labelColor: AppColors.primaryText,
//               unselectedLabelColor: AppColors.secondaryText,
//               labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
//               tabs: [
//                 Tab(text: 'All'),
//                 Tab(text: 'Beginner'),
//                 Tab(text: 'Intermediate'),
//                 Tab(text: 'Advanced'),
//               ],
//               onTap: (index) => setState(() {}),
//             ),
//           ),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//       floatingActionButton: _buildProgressFab(),
//     );
//   }
//
//   Widget _buildClippedHeader() {
//     return ClipPath(
//       clipper: CustomHeaderClipper(),
//       child: Container(
//         height: 120.h,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [AppColors.primaryGold.withOpacity(0.8), AppColors.accent],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Explore Topics',
//                 style: TextStyle(
//                   color: AppColors.buttonText,
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Expanded(
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: topics.length,
//                   itemBuilder: (context, index) => GestureDetector(
//                     onTap: () => _scrollToTopic(index),
//                     child: Container(
//                       margin: EdgeInsets.symmetric(horizontal: 8.w),
//                       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//                       decoration: BoxDecoration(
//                         color: AppColors.cardBackground.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(16.r),
//                         border: Border.all(color: AppColors.buttonText.withOpacity(0.5)),
//                       ),
//                       child: Center(
//                         child: Text(
//                           topics[index]['title'],
//                           style: TextStyle(
//                             color: AppColors.buttonText,
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     if (_filteredTopics.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.auto_stories, size: 60.sp, color: AppColors.secondaryText),
//             SizedBox(height: 16.h),
//             Text(
//               'No topics found',
//               style: TextStyle(color: AppColors.secondaryText, fontSize: 18.sp),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return ListView.builder(
//       controller: _scrollController,
//       padding: EdgeInsets.all(16.w),
//       itemCount: _filteredTopics.length,
//       itemBuilder: (context, index) => _buildTopicCard(_filteredTopics[index]),
//     );
//   }
//
//   Widget _buildTopicCard(Map<String, dynamic> topic) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       margin: EdgeInsets.only(bottom: 16.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.cardBackground, topic['color'].withOpacity(0.1)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8.r,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () => _navigateToDetail(topic),
//         borderRadius: BorderRadius.circular(16.r),
//         child: Stack(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       _buildProgressIndicator(topic),
//                       SizedBox(width: 16.w),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               topic['title'],
//                               style: TextStyle(
//                                 color: AppColors.primaryText,
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                             SizedBox(height: 8.h),
//                             _buildDifficultyBadge(topic['details']['difficulty']),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           _bookmarks[topic['title']]! ? Icons.bookmark : Icons.bookmark_border,
//                           color: AppColors.primaryGold,
//                         ),
//                         onPressed: () => setState(() => _bookmarks[topic['title']] = !_bookmarks[topic['title']]!),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12.h),
//                   Text(
//                     topic['details']['description'],
//                     style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 12.h),
//                   _buildKeyPointsPreview(topic['details']['keyPoints']),
//                 ],
//               ),
//             ),
//             if (_progress[topic['title']]! >= 1.0)
//               Positioned(
//                 right: 8.w,
//                 top: 8.h,
//                 child: Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressIndicator(Map<String, dynamic> topic) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         SizedBox(
//           width: 50.w,
//           height: 50.h,
//           child: CircularProgressIndicator(
//             value: _progress[topic['title']],
//             strokeWidth: 5,
//             backgroundColor: AppColors.border.withOpacity(0.3),
//             valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
//           ),
//         ),
//         Text(
//           '${(_progress[topic['title']]! * 100).toInt()}%',
//           style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDifficultyBadge(String difficulty) {
//     Color color;
//     switch (difficulty) {
//       case 'Beginner':
//         color = AppColors.success;
//         break;
//       case 'Intermediate':
//         color = AppColors.accent;
//         break;
//       case 'Advanced':
//         color = AppColors.error;
//         break;
//       default:
//         color = AppColors.border;
//     }
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(6.r),
//         border: Border.all(color: color.withOpacity(0.5)),
//       ),
//       child: Text(
//         difficulty,
//         style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w600),
//       ),
//     );
//   }
//
//   Widget _buildKeyPointsPreview(List<String> keyPoints) {
//     return Wrap(
//       spacing: 8.w,
//       runSpacing: 8.h,
//       children: keyPoints.take(3).map((point) => Chip(
//         label: Text(point, style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp)),
//         backgroundColor: AppColors.cardBackground.withOpacity(0.8),
//         side: BorderSide(color: AppColors.border.withOpacity(0.5)),
//         elevation: 2,
//       )).toList(),
//     );
//   }
//
//   Widget _buildProgressFab() {
//     final totalProgress = _progress.values.fold(0.0, (sum, progress) => sum + progress) / _progress.length;
//
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryGold.withOpacity(0.3),
//             blurRadius: 10.r,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: FloatingActionButton(
//         backgroundColor: AppColors.primaryGold.withOpacity(0.9),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             CircularProgressIndicator(
//               value: totalProgress,
//               strokeWidth: 3,
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
//               backgroundColor: AppColors.buttonText.withOpacity(0.3),
//             ),
//             Text(
//               '${(totalProgress * 100).toInt()}%',
//               style: TextStyle(color: AppColors.buttonText, fontSize: 14.sp, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         onPressed: () => _showOverallProgress(),
//       ),
//     );
//   }
//
//   void _showOverallProgress() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//         ),
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Learning Progress',
//               style: TextStyle(
//                 color: AppColors.primaryText,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             ...topics.map((topic) => ListTile(
//               title: Text(topic['title'], style: TextStyle(color: AppColors.primaryText)),
//               subtitle: LinearProgressIndicator(
//                 value: _progress[topic['title']],
//                 backgroundColor: AppColors.border.withOpacity(0.3),
//                 valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
//               ),
//               trailing: Text(
//                 '${(_progress[topic['title']]! * 100).toInt()}%',
//                 style: TextStyle(color: AppColors.secondaryText),
//               ),
//             )).toList(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showFilterModal() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: AppColors.cardBackground,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//         ),
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Filter & Sort',
//               style: TextStyle(
//                 color: AppColors.primaryText,
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             DropdownButton<String>(
//               value: _sortBy,
//               items: [
//                 DropdownMenuItem(value: 'title', child: Text('Sort by Title')),
//                 DropdownMenuItem(value: 'progress', child: Text('Sort by Progress')),
//                 DropdownMenuItem(value: 'difficulty', child: Text('Sort by Difficulty')),
//               ],
//               onChanged: (value) => setState(() => _sortBy = value!),
//               isExpanded: true,
//               style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp),
//             ),
//             CheckboxListTile(
//               title: Text('Show Bookmarked Only', style: TextStyle(color: AppColors.primaryText)),
//               value: _showBookmarkedOnly,
//               onChanged: (value) => setState(() => _showBookmarkedOnly = value!),
//               activeColor: AppColors.primaryGold,
//             ),
//             CheckboxListTile(
//               title: Text('Show Completed Only', style: TextStyle(color: AppColors.primaryText)),
//               value: _showCompletedOnly,
//               onChanged: (value) => setState(() => _showCompletedOnly = value!),
//               activeColor: AppColors.primaryGold,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _confirmResetProgress() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.cardBackground,
//         title: Text('Reset Progress', style: TextStyle(color: AppColors.primaryText)),
//         content: Text('Are you sure you want to reset all progress?', style: TextStyle(color: AppColors.secondaryText)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _progress.updateAll((key, value) => 0.0);
//               });
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('Progress reset successfully!'),
//                   backgroundColor: AppColors.primaryGold,
//                 ),
//               );
//             },
//             child: Text('Reset', style: TextStyle(color: AppColors.error)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _scrollToTopic(int index) {
//     final offset = index * (200.h + 16.h); // Approximate card height + margin
//     _scrollController.animateTo(
//       offset,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   void _navigateToDetail(Map<String, dynamic> topic) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LearnDetailsScreen(
//           topic: topic,
//           onProgressUpdate: (newProgress) => setState(() => _progress[topic['title']] = newProgress),
//           isBookmarked: _bookmarks[topic['title']]!,
//           onBookmarkToggle: () => setState(() => _bookmarks[topic['title']] = !_bookmarks[topic['title']]!),
//           onShare: () => _shareTopic(topic),
//         ),
//       ),
//     );
//   }
//
//   void _shareTopic(Map<String, dynamic> topic) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Sharing ${topic['title']}'),
//         backgroundColor: AppColors.primaryGold,
//       ),
//     );
//   }
// }











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

class LearnDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> topic;
  final Function(double) onProgressUpdate;
  final bool isBookmarked;
  final Function() onBookmarkToggle;
  final Function() onShare;

  const LearnDetailsScreen({
    Key? key,
    required this.topic,
    required this.onProgressUpdate,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onShare,
  }) : super(key: key);

  @override
  _LearnDetailsScreenState createState() => _LearnDetailsScreenState();
}

class _LearnDetailsScreenState extends State<LearnDetailsScreen> {
  late double _currentProgress;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.topic['progress'];
  }

  void _updateProgress(double newProgress) {
    setState(() => _currentProgress = newProgress.clamp(0.0, 1.0));
    widget.onProgressUpdate(newProgress);
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.topic['details'];
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: LearnAppBar(
        title: widget.topic['title'],
        actions: [
          IconButton(
            icon: Icon(
              widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.primaryGold,
            ),
            onPressed: widget.onBookmarkToggle,
          ),
          IconButton(
            icon: Icon(Icons.share, color: AppColors.primaryGold),
            onPressed: widget.onShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressSection(),
            SizedBox(height: 16.h),
            _buildSection('📘 Overview', Text(details['description'], style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp))),
            _buildSection('🎯 Key Concepts', _buildKeyPoints(details['keyPoints'])),
            _buildSection('🎥 Video Tutorial', _buildVideoPlaceholder(details['videoUrl'])),
            _buildSection('💡 Example', _buildExampleCard(details['example'])),
            _buildSection('📈 Strategies', _buildStrategies(details['strategies'])),
            _buildSection('📚 Recommended Resources', _buildResources(details['resources'])),
            SizedBox(height: 16.h),
            _buildQuizButton(),
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
            'Your Progress',
            style: TextStyle(color: AppColors.primaryText, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Slider(
            value: _currentProgress,
            min: 0,
            max: 1,
            divisions: 10,
            label: '${(_currentProgress * 100).round()}%',
            activeColor: AppColors.primaryGold,
            inactiveColor: AppColors.border,
            onChanged: _updateProgress,
          ),
          Text(
            'Adjust your progress manually',
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
              'Watch Tutorial Video',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(String example) {
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
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.primaryGold, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              example,
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14.sp, fontStyle: FontStyle.italic),
            ),
          ),
        ],
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

  Widget _buildResources(List<Map<String, String>> resources) {
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

  Widget _buildQuizButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.quiz, color: AppColors.buttonText, size: 20.sp),
        label: Text('Start Quiz', style: TextStyle(color: AppColors.buttonText, fontSize: 16.sp)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        onPressed: () => _startQuiz(),
      ),
    );
  }

  void _startQuiz() {
    _updateProgress(_currentProgress + 0.2);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz completed! Progress updated.'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }
}