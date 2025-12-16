import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'jt_trade_deatils_screen.dart';

class JtTradeCard extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;
  final Map<String, dynamic> fundData;

  const JtTradeCard({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    required this.value,
    required this.fundData,
  }) : super(key: key);

  @override
  _JtTradeCardState createState() => _JtTradeCardState();
}

class _JtTradeCardState extends State<JtTradeCard> with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _updateHorseAnimation();
    _horseController.forward();
  }

  @override
  void didUpdateWidget(covariant JtTradeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateHorseAnimation();
    }
  }

  void _updateHorseAnimation() {
    // Fix: Handle negative values properly - use absolute value for animation
    double normalizedValue = (widget.value.abs() / 20).clamp(0.0, 1.0);

    // If value is 0 or very close to 0, set minimum progress
    if (widget.value.abs() < 0.01) {
      normalizedValue = 0.05; // Show at least 5% progress for visibility
    }

    _horseAnimation = Tween<double>(
      begin: 0,
      end: normalizedValue,
    ).animate(CurvedAnimation(parent: _horseController, curve: Curves.easeInOut));
    _horseController.forward(from: 0);
  }

  @override
  void dispose() {
    _horseController.dispose();
    super.dispose();
  }

  // Helper method to get fund initial letter
  String _getFundInitial() {
    if (widget.fundName.isNotEmpty) {
      return widget.fundName.substring(0, 1).toUpperCase();
    }
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.value >= 0;
    final double cardWidth = MediaQuery.of(context).size.width - 32.w;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JtTradeDeatilsScreen(
                  logo: widget.logo,
                  name: widget.name,
                  fundName: widget.fundName,
                  value: widget.value,
                  fundData: widget.fundData,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: const Color(0xFFFFD700).withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: _imageLoadError || widget.logo.isEmpty || widget.logo.contains('placeholder')
                            ? Container(
                          color: const Color(0xFFFFD700).withOpacity(0.15),
                          child: Center(
                            child: Text(
                              _getFundInitial(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        )
                            : Image.network(
                          widget.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Set error flag and rebuild
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !_imageLoadError) {
                                setState(() {
                                  _imageLoadError = true;
                                });
                              }
                            });
                            return Container(
                              color: const Color(0xFFFFD700).withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  _getFundInitial(),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fundName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0A1F3A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            : const Color(0xFFE53935).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.trending_up : Icons.trending_down,
                            color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            size: 12.sp,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${widget.value.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Horse Race Animation
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background track
                    Container(
                      width: cardWidth,
                      height: 5.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5.r),
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                      ),
                    ),
                    // Progress bar
                    AnimatedBuilder(
                      animation: _horseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: _horseAnimation.value * cardWidth,
                          height: 5.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.5.r),
                            gradient: LinearGradient(
                              colors: isPositive
                                  ? [const Color(0xFFFFD700), const Color(0xFFDAA520)]
                                  : [const Color(0xFFE53935), const Color(0xFFC62828)],
                            ),
                          ),
                        );
                      },
                    ),
                    // Horse/Icon animation
                    AnimatedBuilder(
                      animation: _horseAnimation,
                      builder: (context, child) {
                        double horsePosition = _horseAnimation.value * cardWidth;
                        return Positioned(
                          left: (horsePosition - 18.w).clamp(0.0, cardWidth - 36.w),
                          top: -26.h,
                          child: _buildRaceIcon(isPositive),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build race icon - try to load GIF, fallback to icon
  Widget _buildRaceIcon(bool isPositive) {
    return Image.asset(
      'assets/images/jt1.gif',
      height: 36.h,
      width: 40.w,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to animated icon if GIF not found
        return Container(
          height: 36.h,
          width: 40.w,
          decoration: BoxDecoration(
            color: isPositive
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : const Color(0xFFE53935).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            isPositive ? Icons.rocket_launch : Icons.trending_down,
            color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            size: 24.sp,
          ),
        );
      },
    );
  }
}