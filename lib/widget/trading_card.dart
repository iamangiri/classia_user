//
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../screenutills/trade_details_screen.dart';
//
// class TradingCard extends StatefulWidget {
//   final String logo;
//   final String name;
//   final double value;
//
//   TradingCard({required this.logo, required this.name, required this.value});
//
//   @override
//   _TradingCardState createState() => _TradingCardState();
// }
//
// class _TradingCardState extends State<TradingCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 3),
//     );
//     _updateAnimation();
//   }
//
//   @override
//   void didUpdateWidget(covariant TradingCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.value != oldWidget.value) {
//       _updateAnimation();
//     }
//   }
//
//   void _updateAnimation() {
//     double normalizedValue = widget.value >= 0 ? (widget.value / 100) : 0;
//     _animation = Tween<double>(
//       begin: 0,
//       end: normalizedValue.clamp(0.0, 1.0),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//     _controller.forward(from: 0);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isPositive = widget.value >= 0;
//     Color textColor = isPositive ? Colors.tealAccent : Colors.redAccent;
//     double cardWidth = MediaQuery.of(context).size.width * 0.7;
//
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TradingDetailsScreen(
//               logo: widget.logo,
//               name: widget.name,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.grey[900],
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 10,
//               spreadRadius: 2,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         width: 44,
//                         height: 44,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.grey[800],
//                         ),
//                         child: widget.logo.isNotEmpty
//                             ? ClipOval(
//                           child: Image.network(
//                             widget.logo,
//                             fit: BoxFit.cover,
//                             loadingBuilder: (context, child, progress) {
//                               return progress == null
//                                   ? child
//                                   : CircularProgressIndicator(
//                                 color: Colors.tealAccent,
//                               );
//                             },
//                             errorBuilder: (_, __, ___) => Icon(
//                               Icons.account_balance,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         )
//                             : Icon(Icons.account_balance, color: Colors.grey[600]),
//                       ),
//                       SizedBox(width: 12),
//                       Text(
//                         widget.name,
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         "${widget.value.toStringAsFixed(2)}%",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                         ),
//                       ),
//                       Text(
//                         isPositive ? "Growth" : "Decline",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[500],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               // Progress Section
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   Container(
//                     width: cardWidth,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(4),
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   AnimatedBuilder(
//                     animation: _animation,
//                     builder: (context, child) {
//                       return Container(
//                         width: _animation.value * cardWidth,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(4),
//                           gradient: LinearGradient(
//                             colors: isPositive
//                                 ? [Colors.tealAccent, Colors.teal[400]!]
//                                 : [Colors.redAccent, Colors.red[400]!],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   AnimatedBuilder(
//                     animation: _animation,
//                     builder: (context, child) {
//                       double horsePosition =
//                       isPositive ? _animation.value * cardWidth : 0;
//                       return Positioned(
//                         left: horsePosition - 20,
//                         top: -40,
//                         child: SizedBox(
//                           height: 100,
//                           width: 100,
//                           child: Transform.flip(
//                             flipX: true,
//                             child: Lottie.asset("assets/anim/trade-6.json"),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//

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
    Color textColor = isPositive ? Colors.teal[700]! : Colors.red[700]!;
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
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
                                  : CircularProgressIndicator(
                                color: Color(0xFFDAA520),
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
                      SizedBox(width: 12),
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.value.toStringAsFixed(2)}%",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isPositive ? "Growth" : "Decline",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Progress Section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: cardWidth,
                    height: 8,
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
                        height: 8,
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
                      isPositive ? _animation.value * cardWidth : 0;
                      return Positioned(
                        left: horsePosition - 20,
                        top: -40,
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Transform.flip(
                            flipX: true,
                            child: Lottie.asset("assets/anim/anim-4.json"),
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