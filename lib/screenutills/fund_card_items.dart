import 'dart:ui';
import 'package:flutter/material.dart';
import '../screen/market/fund_deatils_screen.dart';
import '../themes/app_colors.dart';

class FundCard extends StatefulWidget {
  final Map<String, dynamic> fund;
  final bool isDarkMode;

  const FundCard({Key? key, required this.fund, required this.isDarkMode}) : super(key: key);

  @override
  _FundCardState createState() => _FundCardState();
}

class _FundCardState extends State<FundCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.01).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.fund['name']?.toString() ?? 'Demo Fund';
    final String returns = widget.fund['returns']?.toString() ?? '0%';
    final String minSip = widget.fund['minSip']?.toString() ?? '₹1000';
    final String rating = widget.fund['rating']?.toString() ?? '0.0';
    final double returnValue = double.tryParse(returns.replaceAll('%', '')) ?? 0.0;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) {
          _tapController.reverse();
          _navigateToDetails(context);
        },
        onTapCancel: () => _tapController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _tapController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 160,
                  height: 190,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (AppColors.primaryGold ?? Color(0xFFDAA520))
                            .withOpacity(0.1),
                        blurRadius: _elevationAnimation.value * 2,
                        offset: Offset(0, _elevationAnimation.value),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(widget.isDarkMode ? 0.3 : 0.08),
                        blurRadius: _elevationAnimation.value,
                        offset: Offset(0, _elevationAnimation.value / 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isDarkMode
                                ? [
                              Color(0xFF1E1E1E).withOpacity(0.9),
                              Color(0xFF2D2D2D).withOpacity(0.7),
                            ]
                                : [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.6),
                            ],
                          ),
                          border: Border.all(
                            color: _isHovered
                                ? (AppColors.primaryGold ?? Color(0xFFDAA520))
                                .withOpacity(0.6)
                                : Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Animated background pattern
                            Positioned.fill(
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: _isHovered ? 0.1 : 0.05,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment.topRight,
                                      radius: 1.5,
                                      colors: [
                                        (AppColors.primaryGold ?? Color(0xFFDAA520))
                                            .withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Top accent line with animation
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 4,
                              width: _isHovered ? double.infinity : 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGold ?? Color(0xFFDAA520),
                                    (AppColors.primaryGold ?? Color(0xFFDAA520))
                                        .withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                            ),

                            // Main content
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),

                                  // Header with icon and title
                                  Row(
                                    children: [
                                      Hero(
                                        tag: 'fund_icon_${widget.fund['id'] ?? name}',
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          width: _isHovered ? 45 : 40,
                                          height: _isHovered ? 45 : 40,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                (AppColors.primaryGold ?? Color(0xFFDAA520))
                                                    .withOpacity(0.2),
                                                (AppColors.primaryGold ?? Color(0xFFDAA520))
                                                    .withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: (AppColors.primaryGold ?? Color(0xFFDAA520))
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.account_balance_outlined,
                                            size: _isHovered ? 26 : 22,
                                            color: AppColors.primaryGold ?? Color(0xFFDAA520),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryText ??
                                                    (widget.isDarkMode ? Colors.white : Colors.black87),
                                                letterSpacing: 0.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (AppColors.primaryGold ?? Color(0xFFDAA520))
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Mutual Fund',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.primaryGold ?? Color(0xFFDAA520),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  Spacer(),

                                  // Compact Returns section
                                  Container(
                                    padding: EdgeInsets.all(8), // Reduced from 12
                                    decoration: BoxDecoration(
                                      color: returnValue >= 0
                                          ? (AppColors.success ?? Colors.green).withOpacity(0.08)
                                          : (AppColors.error ?? Colors.red).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10), // Slightly reduced
                                      border: Border.all(
                                        color: returnValue >= 0
                                            ? (AppColors.success ?? Colors.green).withOpacity(0.25)
                                            : (AppColors.error ?? Colors.red).withOpacity(0.25),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              returnValue >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                              size: 14, // Smaller icon
                                              color: returnValue >= 0
                                                  ? AppColors.success ?? Colors.green
                                                  : AppColors.error ?? Colors.red,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Returns',
                                              style: TextStyle(
                                                fontSize: 12, // Slightly smaller text
                                                color: AppColors.secondaryText ?? Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              returns,
                                              style: TextStyle(
                                                fontSize: 12, // Reduced from 18
                                                fontWeight: FontWeight.w700,
                                                color: returnValue >= 0
                                                    ? AppColors.success ?? Colors.green
                                                    : AppColors.error ?? Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),


                                        SizedBox(height: 2), // Reduced from 6
                                        Container(
                                          height: 2.5, // Slightly thinner
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: AnimatedFractionallySizedBox(
                                            duration: Duration(milliseconds: 600), // Slightly quicker
                                            curve: Curves.easeOutCubic,
                                            widthFactor: (returnValue.abs() / 50).clamp(0.1, 1.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: returnValue >= 0
                                                      ? [
                                                    AppColors.success ?? Colors.green,
                                                    (AppColors.success ?? Colors.green).withOpacity(0.6),
                                                  ]
                                                      : [
                                                    AppColors.error ?? Colors.red,
                                                    (AppColors.error ?? Colors.red).withOpacity(0.6),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Spacer(),

                                  // Bottom section with SIP and rating
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Min SIP',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: AppColors.secondaryText ?? Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            minSip,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryText ??
                                                  (widget.isDarkMode ? Colors.white : Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (AppColors.warning ?? Colors.amber).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              color: AppColors.warning ?? Colors.amber,
                                              size: 14,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              rating,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.warning ?? Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Modern floating action button
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: AnimatedScale(
                                scale: _isHovered ? 1.05 : 1.0,
                                duration: Duration(milliseconds: 200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryGold ?? Color(0xFFDAA520),
                                        (AppColors.primaryGold ?? Color(0xFFDAA520)).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (AppColors.primaryGold ?? Color(0xFFDAA520))
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () => _navigateToDetails(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Invest',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FundDetailsScreen(fund: widget.fund),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        reverseTransitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
}