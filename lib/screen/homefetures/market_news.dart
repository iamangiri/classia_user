import 'package:cached_network_image/cached_network_image.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketNewsScreen extends StatefulWidget {
  @override
  _MarketNewsScreenState createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dummy data for Trade Market news
  final List<Map<String, String>> tradeMarketNews = [
    {
      'title': 'Trade Market Hits New Highs',
      'date': '2025-03-01',
      'image': 'https://via.placeholder.com/150',
      'content':
      'The trade market has reached new all-time highs today, driven by strong economic data and investor confidence...',
    },
    {
      'title': 'Global Markets Rally Amid Optimism',
      'date': '2025-02-28',
      'image': 'https://via.placeholder.com/150',
      'content':
      'Global markets saw a significant rally as optimism grows over new trade agreements and technological advancements...',
    },
  ];

  // Dummy data for Mutual Fund news
  final List<Map<String, String>> mutualFundNews = [
    {
      'title': 'Mutual Funds See Record Inflows',
      'date': '2025-03-02',
      'image': 'https://via.placeholder.com/150',
      'content':
      'Mutual funds have attracted record inflows this month, with investors favoring large-cap and hybrid funds...',
    },
    {
      'title': 'Top Mutual Fund Picks for Q1',
      'date': '2025-02-27',
      'image': 'https://via.placeholder.com/150',
      'content':
      'Analysts have highlighted the top mutual fund picks for Q1, focusing on growth-oriented equity funds...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildNewsList(List<Map<String, String>> newsList) {
    final filteredNews = newsList.where((news) {
      final title = news['title']!.toLowerCase();
      final content = news['content']!.toLowerCase();
      return selectedCategory == 'All' &&
          (title.contains(_searchQuery) || content.contains(_searchQuery));
    }).toList();

    return filteredNews.isEmpty
        ? Center(
      child: Text(
        'No news found',
        style: TextStyle(
          color: AppColors.secondaryText,
          fontSize: 16.sp,
        ),
      ),
    )
        : ListView.builder(
      itemCount: filteredNews.length,
      itemBuilder: (context, index) {
        final news = filteredNews[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(news: news),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
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
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: news['image']!,
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60.w,
                    height: 60.h,
                    color: AppColors.border,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60.w,
                    height: 60.h,
                    color: AppColors.border,
                    child: Icon(
                      Icons.article,
                      color: AppColors.disabled,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              title: Text(
                news['title'] ?? 'No Title',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                news['date'] ?? '',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar:AppBar(
        backgroundColor: AppColors.primaryGold,
        title: Text(
          'Market News',
          style: TextStyle(
            fontSize: 18.sp, // Optional: for better scaling
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryText,
          unselectedLabelColor: AppColors.secondaryText,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          tabs: [
            Tab(text: 'Trade Market'),
            Tab(text: 'Mutual Fund'),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                hintStyle: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.secondaryText,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewsList(tradeMarketNews),
                _buildNewsList(mutualFundNews),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final Map<String, String> news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'News Details',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: news['image']!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 200.h,
                    color: AppColors.border,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 200.h,
                    color: AppColors.border,
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.disabled,
                      size: 48.sp,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.h),
            Text(
              news['title'] ?? 'No Title',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              news['date'] ?? '',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              news['content'] ?? 'No content available.',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}