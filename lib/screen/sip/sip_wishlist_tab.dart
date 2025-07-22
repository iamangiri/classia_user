import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';
import 'jockey_sip_screen.dart';

class WishlistTab extends StatefulWidget {
  @override
  _WishlistTabState createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> with TickerProviderStateMixin {
  late AnimationController _horseAnimationController;
  late Animation<double> _horseAnimation;

  @override
  void initState() {
    super.initState();
    _horseAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _horseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _horseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _horseAnimationController.dispose();
    super.dispose();
  }

  final List<WishlistItem> wishlistItems = [
    WishlistItem(
      name: 'Dream Villa',
      icon: Icons.villa,
      targetAmount: 7500000,
      monthlySIP: 30000,
      progress: 0,
      lottieAsset: 'assets/anim/sip_anim_1.json',
      color: Colors.blue,
    ),
    WishlistItem(
      name: 'Higher Education',
      icon: Icons.school,
      targetAmount: 2000000,
      monthlySIP: 15000,
      progress: 0,
      lottieAsset: 'assets/anim/sip_anim_2.json',
      color: Colors.green,
    ),
    WishlistItem(
      name: 'Luxury Yacht',
      icon: Icons.directions_boat,
      targetAmount: 10000000,
      monthlySIP: 50000,
      progress: 0,
      lottieAsset: 'assets/anim/sip_anim_3.json',
      color: Colors.purple,
    ),
  ];

  String formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  Widget _buildAnimatedHorse() {
    return AnimatedBuilder(
      animation: _horseAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 5 * (0.5 - (_horseAnimation.value - 0.5).abs())),
          child: Transform.rotate(
            angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
            child: Container(
              width: 150,
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/jt1.gif',
                  fit: BoxFit.contain,
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
    double cardWidth = MediaQuery.of(context).size.width - 32; // Full width minus padding
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                _buildAnimatedHorse(),
                SizedBox(height: 16),
                Text(
                  'Your Wishlist',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Dreams saved for the future',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 24),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement navigation to add new goal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.buttonText ?? Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add New Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...wishlistItems.asMap().entries.map((entry) {
            int index = entry.key;
            WishlistItem item = entry.value;
            AnimationController progressController = AnimationController(
              duration: Duration(seconds: 3),
              vsync: this,
            )..forward();
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 600 + (index * 200)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor?.withOpacity(0.9) ?? Colors.grey[100]!.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: item.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        color: item.color,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor ?? Colors.blueAccent,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Monthly SIP: ${formatCurrency(item.monthlySIP)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.secondaryText ?? Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Lottie.asset(
                                  item.lottieAsset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: ${item.progress}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor ?? Colors.blueAccent,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Target: ${formatCurrency(item.targetAmount)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor ?? Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: cardWidth - 40, // Account for padding
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey[300],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: Tween<double>(begin: 0, end: item.progress / 100).animate(
                                  CurvedAnimation(
                                    parent: progressController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                builder: (context, child) {
                                  double progressValue = (item.progress / 100).clamp(0.0, 1.0);
                                  return Container(
                                    width: progressValue * (cardWidth - 40),
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: LinearGradient(
                                        colors: [AppColors.primaryGold ?? Color(0xFFDAA520), Colors.amber[700]!],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              AnimatedBuilder(
                                animation: Tween<double>(begin: 0, end: item.progress / 100).animate(
                                  CurvedAnimation(
                                    parent: progressController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                builder: (context, child) {
                                  double progressValue = (item.progress / 100).clamp(0.0, 1.0);
                                  double horsePosition = progressValue * (cardWidth - 40);
                                  return Positioned(
                                    left: horsePosition - 20,
                                    top: -30,
                                    child: SizedBox(
                                      height: 70,
                                      width: 90,
                                      child: Image.asset(
                                        'assets/images/jt1.gif',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // TODO: Implement edit goal logic
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColors.border ?? Colors.grey),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Edit Goal',
                                    style: TextStyle(
                                      color: AppColors.secondaryText ?? Colors.grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement start SIP logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Start SIP',
                                    style: TextStyle(
                                      color: AppColors.buttonText ?? Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                progressController.dispose(); // Dispose controller after animation
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

class WishlistItem {
  final String name;
  final IconData icon;
  final double targetAmount;
  final double monthlySIP;
  final double progress;
  final String lottieAsset;
  final Color color;

  WishlistItem({
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.monthlySIP,
    required this.progress,
    required this.lottieAsset,
    required this.color,
  });
}