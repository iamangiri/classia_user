import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:classia_amc/screen/homefetures/investment_history_screen.dart';
import 'package:classia_amc/screen/homefetures/market_news.dart';
import 'package:classia_amc/screen/main/profile_screen.dart';
import 'package:classia_amc/screen/main/wallet_screen.dart';
import 'package:classia_amc/utills/constent/home_screen_data.dart';
import 'package:classia_amc/widget/custom_heading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../screenutills/fund_deatils_screen.dart';
import '../../themes/app_colors.dart';
import '../../widget/custom_app_bar.dart';
import '../homefetures/notification_screen.dart';
import '../homefetures/withdraw_screen.dart';
import 'market_screen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: 'Jockey Trading',
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.9,
                  ),
                  items: HomeScreenData.sliderImages.map((image) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.border,
                              child: Icon(Icons.image, color: AppColors.disabled),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.disabled.withOpacity(0.3),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),

              // Features Section
              CustomHeading(text: 'Features', lineWidth: 40),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: HomeScreenData.features.map((feature) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                        onTap: () => _navigateToFeature(feature['title'], context),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.border.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: FaIcon(
                                feature['icon'],
                                size: 28,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              feature['title'],
                              style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),

              // Trending Funds Section
              CustomHeading(text: 'Trending Funds', lineWidth: 40),
              SizedBox(height: 12),
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: HomeScreenData.trendingFunds.length,
                  itemBuilder: (context, index) {
                    final fund = HomeScreenData.trendingFunds[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FundDetailsScreen(fund: fund!),
                            ),
                          );
                        },
                        child: Container(
                          width: 170,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: fund['logo']!,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(
                                        width: 32,
                                        height: 32,
                                        color: AppColors.border,
                                        child: Icon(
                                          Icons.image,
                                          color: AppColors.disabled,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fund['symbol']!,
                                      style: TextStyle(
                                        color: AppColors.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                fund['company']!,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Spacer(),
                              Text(
                                '₹${fund['price']}',
                                style: TextStyle(
                                  color: AppColors.primaryGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                fund['change']!,
                                style: TextStyle(
                                  color: fund['change']!.startsWith('+')
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // Top Mutual Funds Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomHeading(text: 'Top Mutual Funds', lineWidth: 40),
                  TextButton(
                    onPressed: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MarketScreen())),
                    child: Text(
                      'View More',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75, // Adjusted for taller cards
                ),
                itemCount: HomeScreenData.mutualFunds.length,
                itemBuilder: (context, index) {
                  final fund = HomeScreenData.mutualFunds[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FundDetailsScreen(fund: fund),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: fund['logo']!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    width: 32,
                                    height: 32,
                                    color: AppColors.border,
                                    child: Icon(
                                      Icons.image,
                                      color: AppColors.disabled,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fund['symbol']!,
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            fund['company']!,
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            '₹${fund['price']}',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            fund['change']!,
                            style: TextStyle(
                              color: fund['change']!.startsWith('+')
                                  ? AppColors.success
                                  : AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildProgressFab(),
    );
  }

  void _navigateToFeature(String title, BuildContext context) {
    Widget destination;
    switch (title) {
      case 'Withdraw':
        destination = WithdrawScreen();
        break;
      case 'Deposit':
        destination = InvestmentHistoryScreen();
        break;
      case 'History':
        destination = WalletScreen();
        break;
      case 'Market News':
        destination = MarketNewsScreen();
        break;
      case 'Invest':
        destination = InvestmentHistoryScreen();
        break;
      default:
        destination = Scaffold(
          appBar: AppBar(
            title: Text(title, style: TextStyle(color: AppColors.primaryText)),
            backgroundColor: AppColors.primaryGold,
          ),
          backgroundColor: AppColors.screenBackground,
          body: Center(
            child: Text('Screen for $title', style: TextStyle(color: AppColors.primaryText)),
          ),
        );
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
  }

  Widget _buildProgressFab() {
    final totalProgress = 0.50;
    return FloatingActionButton(
      backgroundColor: AppColors.primaryGold,
      elevation: 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: totalProgress,
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
            backgroundColor: AppColors.screenBackground.withOpacity(0.5),
          ),
          Text(
            '${(totalProgress * 100).toInt()}%',
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}