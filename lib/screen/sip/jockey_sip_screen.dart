import 'package:flutter/material.dart';
import 'package:classia_amc/screen/sip/sip_portfolio_tab.dart';
import 'package:classia_amc/screen/sip/sip_explore_tab.dart';
import 'package:classia_amc/screen/sip/sip_wishlist_tab.dart';
import '../../themes/app_colors.dart';
import 'dart:ui';

class Goal {
  final int id;
  final String name;
  final IconData icon;
  final double target;
  final double current;
  final double monthlyPayment;
  final Color color;
  final double progress;
  final String lottieAsset;

  Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.target,
    required this.current,
    required this.monthlyPayment,
    required this.color,
    required this.progress,
    required this.lottieAsset,
  });
}

class ExploreGoal {
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  ExploreGoal({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}

// class WishlistItem {
//   final String name;
//   final IconData icon;
//   final double targetAmount;
//   final double monthlySIP;
//   final double progress;
//   final String lottieAsset;
//   final Color color;
//
//   WishlistItem({
//     required this.name,
//     required this.icon,
//     required this.targetAmount,
//     required this.monthlySIP,
//     required this.progress,
//     required this.lottieAsset,
//     required this.color,
//   });
// }

class Fund {
  final String name;
  final String returnRate;
  final String risk;
  final Color color;

  Fund({
    required this.name,
    required this.returnRate,
    required this.risk,
    required this.color,
  });
}

class JockeySipScreen extends StatefulWidget {
  @override
  _JockeySipScreenState createState() => _JockeySipScreenState();
}

class _JockeySipScreenState extends State<JockeySipScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 80.0,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor ?? Colors.blueAccent,
                    (AppColors.primaryColor ?? Colors.blueAccent).withOpacity(0.7),
                  ],
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          SizedBox(height: 4),
                          Container(
                            height: 36,
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _currentIndex = 0),
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: _currentIndex == 0
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Portfolio',
                                              style: TextStyle(
                                                color: _currentIndex == 0
                                                    ? AppColors.primaryColor ?? Colors.blueAccent
                                                    : Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _currentIndex = 1),
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: _currentIndex == 1
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Explore',
                                              style: TextStyle(
                                                color: _currentIndex == 1
                                                    ? AppColors.primaryColor ?? Colors.blueAccent
                                                    : Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _currentIndex = 2),
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          decoration: BoxDecoration(
                                            color: _currentIndex == 2
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Wishlist',
                                              style: TextStyle(
                                                color: _currentIndex == 2
                                                    ? AppColors.primaryColor ?? Colors.blueAccent
                                                    : Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _currentIndex == 0
                    ? PortfolioTab()
                    : _currentIndex == 1
                    ? ExploreTab()
                    : WishlistTab(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new SIP functionality
        },
        backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}