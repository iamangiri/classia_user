import 'package:flutter/material.dart';
import '../screenutills/trade_details_screen.dart';

class TradingCard extends StatefulWidget {
  final String logo;
  final String name;
  final String fundName;
  final double value;

  TradingCard({required this.logo, required this.name, required this.value,required this.fundName});

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
      duration: Duration(seconds: 5),
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
  void dispose() {
    _controller.dispose();
    super.dispose();

  }
  String _truncateText(String text, {int maxWords = 4}) {
    // Normalize non-breaking or narrow spaces to regular space
    final normalized = text
        .replaceAll(RegExp(r'[\u00A0\u202F]'), ' ')
        .trim();

    final words = normalized.split(RegExp(r'\s+'));

    if (words.length <= maxWords) return normalized;

    return words.sublist(0, maxWords).join(' ') + '...';
  }


  @override
  Widget build(BuildContext context) {
    bool isPositive = widget.value >= 0;
    Color textColor = isPositive ? Colors.teal[700]! : Colors.red[700]!;
    double cardWidth = MediaQuery.of(context).size.width * 0.6;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: widget.logo,
              name: widget.name,
              value: widget.value,
              fundName:  widget.fundName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
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
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFDAA520),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.account_balance,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                            : Icon(
                          Icons.account_balance,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,  // ← add this
                        children: [
                          Text(
                            _truncateText(widget.name),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          Text(
                            widget.fundName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.value.toStringAsFixed(2)}%",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isPositive ? "Growth" : "Decline",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14),
              // Progress Bar + Horse
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: cardWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[300],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Container(
                        width: _animation.value * cardWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: isPositive
                                ? [Color(0xFFDAA520), Colors.amber[700]!]
                                : [Colors.red[400]!, Colors.red[700]!],
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double horsePosition =
                          _animation.value * cardWidth;
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
            ],
          ),
        ),
      ),
    );
  }
}

