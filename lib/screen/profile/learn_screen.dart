import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

import '../../widget/learn_app_bar.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

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
      'title': 'Forex Trading Basics',
      'progress': 0.2,
      'color': Colors.green,
      'details': {
        'difficulty': 'Beginner',
        'description': 'An introduction to Forex trading covering currency pairs, pips, and leverage.',
        'keyPoints': ['Currency Pairs', 'Pips', 'Leverage'],
        'example': 'Example: Understanding the EUR/USD currency pair movements.',
        'strategies': ['Demo trading', 'Monitor economic indicators', 'Follow global news'],
        'videoUrl': 'https://example.com/forex-trading-video',
        'resources': [
          {'title': 'BabyPips: Forex 101', 'url': 'https://www.babypips.com/learn/forex'},
          {'title': 'Forex Factory', 'url': 'https://www.forexfactory.com'},
        ],
      },
    },
    {
      'title': 'Cryptocurrency Trading',
      'progress': 0.4,
      'color': Colors.orange,
      'details': {
        'difficulty': 'Intermediate',
        'description': 'Learn how to trade cryptocurrencies, analyze trends, and manage risks in the crypto markets.',
        'keyPoints': ['Bitcoin', 'Ethereum', 'Altcoins', 'Technical Indicators'],
        'example': 'Example: Using RSI and MACD to analyze Bitcoin price movements.',
        'strategies': ['Stay updated with crypto news', 'Use demo accounts', 'Diversify your portfolio'],
        'videoUrl': 'https://example.com/crypto-trading-video',
        'resources': [
          {'title': 'CoinDesk: Crypto News', 'url': 'https://www.coindesk.com'},
          {'title': 'CoinMarketCap', 'url': 'https://coinmarketcap.com'},
        ],
      },
    },
    {
      'title': 'Options Trading',
      'progress': 0.0,
      'color': Colors.purple,
      'details': {
        'difficulty': 'Advanced',
        'description': 'Explore options trading strategies, including calls, puts, and spreads.',
        'keyPoints': ['Calls', 'Puts', 'Spreads', 'Volatility'],
        'example': 'Example: Using a covered call strategy to generate income.',
        'strategies': ['Learn from case studies', 'Practice with virtual trading', 'Monitor volatility'],
        'videoUrl': 'https://example.com/options-trading-video',
        'resources': [
          {'title': 'CBOE: Options Basics', 'url': 'https://www.cboe.com/learncenter'},
          {'title': 'Options Trading Guide', 'url': 'https://www.optionseducation.org'},
        ],
      },
    },
  ];

  Map<String, bool> _bookmarks = {};
  Map<String, double> _progress = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    for (var topic in topics) {
      _progress[topic['title']] = topic['progress'];
      _bookmarks[topic['title']] = false;
    }
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTopics {
    final selectedDifficulty = ['All', 'Beginner', 'Intermediate', 'Advanced'][_tabController.index];
    return topics.where((topic) {
      final matchesSearch = topic['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDifficulty = selectedDifficulty == 'All' || topic['details']['difficulty'] == selectedDifficulty;
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: LearnAppBar(
        title: 'Learn',
        searchController: _searchController,
        showSearch: true,
      ),
      body: Column(
        children: [
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
      padding: EdgeInsets.all(16.w),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) => _buildTopicCard(_filteredTopics[index]),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
      child: InkWell(
        onTap: () => _navigateToDetail(topic),
        borderRadius: BorderRadius.circular(12.r),
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
                                fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
            if (_progress[topic['title']]! >= 1.0)
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
            strokeWidth: 4,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
          ),
        ),
        Text(
          '${(_progress[topic['title']]! * 100).toInt()}%',
          style: TextStyle(color: AppColors.primaryText, fontSize: 12.sp),
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color),
      ),
      child: Text(
        difficulty,
        style: TextStyle(color: color, fontSize: 12.sp),
      ),
    );
  }

  Widget _buildKeyPointsPreview(List<String> keyPoints) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: keyPoints.take(3).map((point) => Chip(
        label: Text(point, style: TextStyle(color: AppColors.secondaryText, fontSize: 12.sp)),
        backgroundColor: AppColors.cardBackground,
        side: BorderSide(color: AppColors.border),
      )).toList(),
    );
  }

  Widget _buildProgressFab() {
    final totalProgress = _progress.values.fold(0.0, (sum, progress) => sum + progress) / _progress.length;

    return FloatingActionButton(
      backgroundColor: AppColors.primaryGold,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: totalProgress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
          ),
          Text(
            '${(totalProgress * 100).toInt()}%',
            style: TextStyle(color: AppColors.buttonText, fontSize: 12.sp),
          ),
        ],
      ),
      onPressed: () => _showOverallProgress(),
    );
  }

  void _showOverallProgress() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Learning Progress',
              style: TextStyle(color: AppColors.primaryText, fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ...topics.map((topic) => ListTile(
              title: Text(topic['title'], style: TextStyle(color: AppColors.primaryText)),
              subtitle: LinearProgressIndicator(
                value: _progress[topic['title']],
                backgroundColor: AppColors.border,
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

  void _navigateToDetail(Map<String, dynamic> topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearnDetailsScreen(
          topic: topic,
          onProgressUpdate: (newProgress) => setState(() => _progress[topic['title']] = newProgress),
          isBookmarked: _bookmarks[topic['title']]!,
          onBookmarkToggle: () => setState(() => _bookmarks[topic['title']] = !_bookmarks[topic['title']]!),
        ),
      ),
    );
  }
}

class LearnDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> topic;
  final Function(double) onProgressUpdate;
  final bool isBookmarked;
  final Function() onBookmarkToggle;

  const LearnDetailsScreen({
    Key? key,
    required this.topic,
    required this.onProgressUpdate,
    required this.isBookmarked,
    required this.onBookmarkToggle,
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
          // Implement URL launching (e.g., url_launcher)
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
    // Simulate quiz completion
    _updateProgress(_currentProgress + 0.2);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz completed! Progress updated.'),
        backgroundColor: AppColors.primaryGold,
      ),
    );
  }
}