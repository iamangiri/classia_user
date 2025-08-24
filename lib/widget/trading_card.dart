import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_colors.dart';
import '../screenutills/trade_details_screen.dart';


class TradingCard extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;
  final double projection;

  const TradingCard({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
    required this.projection,
  }) : super(key: key);

  @override
  _TradingCardState createState() => _TradingCardState();
}

class _TradingCardState extends State<TradingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant TradingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    double normalizedValue = (widget.value.abs() / 20).clamp(0.0, 1.0); // Changed from 100 to 20 for much better visibility
    _animation = Tween<double>(
      begin: 0,
      end: normalizedValue,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _truncateText(String text, {int maxWords = 4}) {
    final normalized = text.replaceAll(RegExp(r'[\u00A0\u202F]'), ' ').trim();
    final words = normalized.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return normalized;
    return '${words.sublist(0, maxWords).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isPositive = widget.value >= 0;
    final Color textColor = isPositive
        ? AppColors.success ?? Colors.teal[700]!
        : AppColors.error ?? Colors.red[700]!;
    final double cardWidth = MediaQuery.of(context).size.width * 0.9;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: widget.logo,
              name: widget.name,
              fundName: widget.fundName,
              value: widget.value,
              projection: widget.projection,

            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h), // Slightly increased margins
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(10.r), // Slightly increased border radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isDarkMode ? 0.2 : 0.1), // Reduced shadow
              blurRadius: 4.r,
              spreadRadius: 0.5.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.w), // Slightly increased padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( // Added Expanded to prevent overflow
                    child: Row(
                      children: [
                        Container(
                          width: 32.w, // Slightly increased logo size
                          height: 32.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          ),
                          child: widget.logo.isNotEmpty
                              ? ClipOval(
                            child: Image.network(
                              widget.logo,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : SizedBox(
                                  height: 12.w,
                                  width: 12.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5.w,
                                    color: AppColors.primaryGold ?? const Color(0xFFDAA520),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.account_balance,
                                color: Colors.grey[400],
                                size: 18.sp, // Slightly increased icon size
                              ),
                            ),
                          )
                              : Icon(
                            Icons.account_balance,
                            color: Colors.grey[400],
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 8.w), // Slightly increased spacing
                        Expanded( // Added Expanded to prevent text overflow
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _truncateText(widget.name, maxWords: 4), // Reduced max words
                                style: TextStyle(
                                  fontSize: 13.sp, // Slightly increased font size
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Projection: ${widget.projection.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGold,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart,
                            color: textColor,
                            size: 15.sp, // Slightly increased icon size
                          ),
                          SizedBox(width: 3.w), // Slightly increased spacing
                          Text(
                            '${widget.value.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 13.sp, // Slightly increased font size
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h), // Slightly increased spacing
                      Text(
                        isPositive ? 'Growth' : 'Decline',
                        style: TextStyle(
                          fontSize: 9.sp, // Slightly increased font size
                          color: isDarkMode ? Colors.grey[400] : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h), // Slightly increased spacing
              // Progress Bar + Horse
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: cardWidth,
                    height: 5.h, // Slightly increased progress bar height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.5.r),
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: _animation.value * cardWidth,
                        height: 5.h, // Slightly increased progress bar height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5.r),
                          gradient: LinearGradient(
                            colors: isPositive
                                ? [
                              AppColors.primaryGold ?? Colors.amber[700]!,
                              (AppColors.primaryGold ?? Colors.amber[700]!).withOpacity(0.8),
                            ]
                                : [
                              AppColors.error ?? Colors.red[400]!,
                              (AppColors.error ?? Colors.red[400]!).withOpacity(0.8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double horsePosition = _animation.value * cardWidth;
                      return Positioned(
                        left: (horsePosition - 18.w).clamp(0.0, cardWidth - 18.w), // Adjusted for slightly bigger horse
                        top: -25.h, // Slightly adjusted top position
                        child: SizedBox(
                          height: 55.h, // Slightly increased horse height
                          width: 65.w, // Slightly increased horse width
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
            ],
          ),
        ),
      ),
    );
  }
}

