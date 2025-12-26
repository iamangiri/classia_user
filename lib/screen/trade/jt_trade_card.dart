import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'jt_trade_deatils_screen.dart';

class JtTradeCard extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double? value; // Make nullable
  final Map<String, dynamic> fundData;

  const JtTradeCard({
    Key? key,
    required this.logo,
    required this.name,
    required this.fundName,
    this.value, // Optional now
    required this.fundData,
  }) : super(key: key);

  @override
  _JtTradeCardState createState() => _JtTradeCardState();
}

class _JtTradeCardState extends State<JtTradeCard> with SingleTickerProviderStateMixin {
  late AnimationController _horseController;
  late Animation<double> _horseAnimation;
  bool _imageLoadError = false;

  // Helper to get safe value (0 if null or infinity)
  double get _safeValue {
    if (widget.value == null) return 0.0;
    if (widget.value!.isInfinite || widget.value!.isNaN) return 0.0;
    return widget.value!;
  }

  // Check performance tiers
  bool get _isSuperPerformer => _safeValue.abs() > 100.0;
  bool get _isSuperFastPerformer => _safeValue.abs() > 1000.0; // New tier for 1000%+

  // Get performance color based on tier
  Color get _performanceColor {
    if (_isSuperFastPerformer && _safeValue >= 0) {
      return const Color(0xFFFF6B00); // Orange for super fast
    } else if (_isSuperPerformer && _safeValue >= 0) {
      return const Color(0xFF4CAF50); // Green for super
    } else if (_safeValue >= 0) {
      return const Color(0xFFFFD700); // Gold for normal positive
    } else {
      return const Color(0xFFE53935); // Red for negative
    }
  }

  // Get secondary performance color for gradients
  Color get _performanceColorLight {
    if (_isSuperFastPerformer && _safeValue >= 0) {
      return const Color(0xFFFF8533); // Light orange
    } else if (_isSuperPerformer && _safeValue >= 0) {
      return const Color(0xFF66BB6A); // Light green
    } else if (_safeValue >= 0) {
      return const Color(0xFFDAA520); // Light gold
    } else {
      return const Color(0xFFC62828); // Dark red
    }
  }

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
    double oldValue = oldWidget.value ?? 0.0;
    if (oldValue.isInfinite || oldValue.isNaN) oldValue = 0.0;

    if (_safeValue != oldValue) {
      _updateHorseAnimation();
    }
  }

  void _updateHorseAnimation() {
    // Calculate percentage progress (0-100% -> 0-1.0)
    double absoluteValue = _safeValue.abs();

    // Normalize to 0-1 scale
    // Cap at 100% for display (values >100% will show at 100% with special indicator)
    double normalizedValue = (absoluteValue / 100.0).clamp(0.0, 1.0);

    // If value is 0 or very close to 0, set minimum progress for visibility
    if (absoluteValue < 0.01) {
      normalizedValue = 0.0; // Show 0% if value is 0
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
    final bool isPositive = _safeValue >= 0;
    final double cardWidth = MediaQuery.of(context).size.width - 32.w;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: (_isSuperPerformer && isPositive)
              ? _performanceColor.withOpacity(0.6)
              : const Color(0xFFE0E0E0),
          width: (_isSuperPerformer && isPositive) ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isSuperPerformer && isPositive)
                ? _performanceColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: (_isSuperPerformer && isPositive) ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Super Performer Badge
          if (_isSuperPerformer && isPositive)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _performanceColor,
                      _performanceColorLight,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  boxShadow: _isSuperFastPerformer
                      ? [
                    BoxShadow(
                      color: _performanceColor.withOpacity(0.5),
                      blurRadius: 8.r,
                      spreadRadius: 1.r,
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSuperFastPerformer ? Icons.flash_on : Icons.star,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _isSuperFastPerformer ? 'SUPER FAST' : 'SUPER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Material(
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
                      value: _safeValue,
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
                            color: (_isSuperPerformer && isPositive)
                                ? _performanceColor.withOpacity(0.1)
                                : const Color(0xFFFFD700).withOpacity(0.1),
                            boxShadow: _isSuperFastPerformer && isPositive
                                ? [
                              BoxShadow(
                                color: _performanceColor.withOpacity(0.3),
                                blurRadius: 6.r,
                                spreadRadius: 1.r,
                              ),
                            ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: _imageLoadError || widget.logo.isEmpty || widget.logo.contains('placeholder')
                                ? Container(
                              color: (_isSuperPerformer && isPositive)
                                  ? _performanceColor.withOpacity(0.15)
                                  : const Color(0xFFFFD700).withOpacity(0.15),
                              child: Center(
                                child: Text(
                                  _getFundInitial(),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: (_isSuperPerformer && isPositive)
                                        ? _performanceColor
                                        : const Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                            )
                                : Image.network(
                              widget.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted && !_imageLoadError) {
                                    setState(() {
                                      _imageLoadError = true;
                                    });
                                  }
                                });
                                return Container(
                                  color: (_isSuperPerformer && isPositive)
                                      ? _performanceColor.withOpacity(0.15)
                                      : const Color(0xFFFFD700).withOpacity(0.15),
                                  child: Center(
                                    child: Text(
                                      _getFundInitial(),
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: (_isSuperPerformer && isPositive)
                                            ? _performanceColor
                                            : const Color(0xFFFFD700),
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
                                        (_isSuperPerformer && isPositive)
                                            ? _performanceColor
                                            : const Color(0xFFFFD700),
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
                            gradient: (_isSuperPerformer && isPositive)
                                ? LinearGradient(
                              colors: [
                                _performanceColor,
                                _performanceColorLight,
                              ],
                            )
                                : null,
                            color: (_isSuperPerformer && isPositive)
                                ? null
                                : isPositive
                                ? const Color(0xFF4CAF50).withOpacity(0.1)
                                : const Color(0xFFE53935).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                            boxShadow: _isSuperFastPerformer && isPositive
                                ? [
                              BoxShadow(
                                color: _performanceColor.withOpacity(0.4),
                                blurRadius: 6.r,
                                spreadRadius: 1.r,
                              ),
                            ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSuperFastPerformer && isPositive)
                                Padding(
                                  padding: EdgeInsets.only(right: 3.w),
                                  child: Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                )
                              else if (_isSuperPerformer && isPositive)
                                Padding(
                                  padding: EdgeInsets.only(right: 3.w),
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                color: (_isSuperPerformer && isPositive)
                                    ? Colors.white
                                    : isPositive
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53935),
                                size: 12.sp,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '${_safeValue.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: (_isSuperPerformer && isPositive)
                                      ? Colors.white
                                      : isPositive
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFE53935),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Horse Race Animation with percentage
                    Column(
                      children: [
                        // Percentage display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Performance',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                if (_isSuperFastPerformer && isPositive)
                                  Container(
                                    margin: EdgeInsets.only(right: 4.w),
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _performanceColor,
                                          _performanceColorLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.flash_on,
                                          color: Colors.white,
                                          size: 10.sp,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          '1000+',
                                          style: TextStyle(
                                            fontSize: 8.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_isSuperPerformer && isPositive)
                                  Container(
                                    margin: EdgeInsets.only(right: 4.w),
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: _performanceColor,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '100+',
                                      style: TextStyle(
                                        fontSize: 8.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Text(
                                  '${_safeValue.abs().toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: (_isSuperPerformer && isPositive)
                                        ? _performanceColor
                                        : isPositive
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFE53935),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),

                        // Race track
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Background track
                            Container(
                              width: cardWidth,
                              height: 5.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.5.r),
                                color: (_isSuperPerformer && isPositive)
                                    ? _performanceColor.withOpacity(0.2)
                                    : const Color(0xFFFFD700).withOpacity(0.2),
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
                                      colors: [_performanceColor, _performanceColorLight],
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

                        // Scale markers
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0%',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              '50%',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              _isSuperFastPerformer && isPositive
                                  ? '1000+%'
                                  : _isSuperPerformer && isPositive
                                  ? '100+%'
                                  : '100%',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: (_isSuperPerformer && isPositive)
                                    ? _performanceColor
                                    : Colors.grey[500],
                                fontWeight: (_isSuperPerformer && isPositive)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
          ),
        ],
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
            gradient: (_isSuperPerformer && isPositive)
                ? LinearGradient(
              colors: [
                _performanceColor,
                _performanceColorLight,
              ],
            )
                : null,
            color: (_isSuperPerformer && isPositive)
                ? null
                : isPositive
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : const Color(0xFFE53935).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: _isSuperFastPerformer && isPositive
                ? [
              BoxShadow(
                color: _performanceColor.withOpacity(0.5),
                blurRadius: 8.r,
                spreadRadius: 1.r,
              ),
            ]
                : null,
          ),
          child: Icon(
            _isSuperFastPerformer && isPositive
                ? Icons.flash_on
                : _isSuperPerformer && isPositive
                ? Icons.star
                : isPositive
                ? Icons.rocket_launch
                : Icons.trending_down,
            color: (_isSuperPerformer && isPositive)
                ? Colors.white
                : isPositive
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE53935),
            size: 24.sp,
          ),
        );
      },
    );
  }
}