import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';
import 'jockey_sip_screen.dart';

class PortfolioTab extends StatefulWidget {
  @override
  _PortfolioTabState createState() => _PortfolioTabState();
}

class _PortfolioTabState extends State<PortfolioTab> with TickerProviderStateMixin {
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

  final List<Goal> portfolioGoals = [
    Goal(
      id: 1,
      name: 'Dream Home',
      icon: Icons.home,
      target: 5000000,
      current: 1250000,
      monthlyPayment: 25000,
      color: Colors.blue,
      progress: 25,
      lottieAsset: 'assets/anim/sip_anim_1.json',
    ),
    Goal(
      id: 2,
      name: 'New Car',
      icon: Icons.directions_car,
      target: 800000,
      current: 320000,
      monthlyPayment: 15000,
      color: Colors.green,
      progress: 40,
      lottieAsset: 'assets/anim/sip_anim_2.json',
    ),
    Goal(
      id: 3,
      name: 'Retirement Fund',
      icon: Icons.savings,
      target: 10000000,
      current: 2000000,
      monthlyPayment: 50000,
      color: Colors.purple,
      progress: 20,
      lottieAsset: 'assets/anim/sip_anim_3.json',
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
                  'Your Investment Journey',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor ?? Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Watch your goals gallop towards success!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ...portfolioGoals.asMap().entries.map((entry) {
            int index = entry.key;
            Goal goal = entry.value;
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
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: goal.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      goal.icon,
                                      color: goal.color,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          goal.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor ?? Colors.blueAccent,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Monthly: ${formatCurrency(goal.monthlyPayment)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.secondaryText ?? Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Target',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText ?? Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(goal.target),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor ?? Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Lottie.asset(
                                      goal.lottieAsset,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress: ${goal.progress}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor ?? Colors.blueAccent,
                                ),
                              ),
                              SizedBox(width: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: AppColors.success ?? Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'On Track',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.success ?? Colors.green,
                                    ),
                                  ),
                                ],
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
                                animation: Tween<double>(begin: 0, end: goal.progress / 100).animate(
                                  CurvedAnimation(
                                    parent: progressController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                builder: (context, child) {
                                  double progressValue = (goal.progress / 100).clamp(0.0, 1.0);
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
                                animation: Tween<double>(begin: 0, end: goal.progress / 100).animate(
                                  CurvedAnimation(
                                    parent: progressController,
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                                builder: (context, child) {
                                  double progressValue = (goal.progress / 100).clamp(0.0, 1.0);
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Value',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText ?? Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(goal.current),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success ?? Colors.green,
                                    ),
                                  ),
                                ],
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