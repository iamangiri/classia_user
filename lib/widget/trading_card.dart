import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../screenutills/trade_details_screen.dart';

class TradingCard extends StatefulWidget {
  final String logo;
  final String name;
  final double value;

  TradingCard({required this.logo, required this.name, required this.value});

  @override
  _TradingCardState createState() => _TradingCardState();
}

class _TradingCardState extends State<TradingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
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
    double normalizedValue = widget.value >= 0 ? (widget.value / 10) : 0;
    _animation = Tween<double>(
      begin: 0,
      end: normalizedValue.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    bool isPositive = widget.value >= 0;
    Color lineColor = isPositive ? Colors.green[400]! : Colors.red[400]!;
    double cardWidth = MediaQuery.of(context).size.width * 0.7;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: widget.logo,
              name: widget.name,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Value Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[800],
                        child: widget.logo.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            widget.logo,
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ));
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image,
                                  size: 40, color: Colors.grey);
                            },
                          ),
                        )
                            : Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                      SizedBox(width: 12),
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.value.toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: lineColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Animated Progress Line with Golden Horse Animation
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background Line
                  Container(
                    width: cardWidth,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[700], // Darker background for progress line
                    ),
                  ),
                  // Dynamic Progress Line
                  if (isPositive)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        double progressWidth = _animation.value * cardWidth;
                        return Container(
                          width: progressWidth,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: lineColor,
                          ),
                        );
                      },
                    ),
                  // Golden Horse Animation Moving Along the Line
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double horsePosition =
                      isPositive ? _animation.value * cardWidth : 0;
                      return Positioned(
                        left: horsePosition - 20,
                        top: -40,
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Transform.flip(
                            flipX: true,
                            child: Lottie.asset("assets/anim/trade-6.json"),
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
