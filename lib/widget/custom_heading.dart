import 'package:flutter/material.dart';

class CustomHeading extends StatelessWidget {
  final String text;
  final double lineWidth;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Color lineColor;
  final double lineHeight;
  final double spacing;

  const CustomHeading({
    Key? key,
    required this.text,
    this.lineWidth = 100,
    this.textColor = Colors.white,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.lineColor = Colors.amber,
    this.lineHeight = 2,
    this.spacing = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        SizedBox(height: spacing),
        Container(
          width: lineWidth,
          height: lineHeight,
          color: lineColor,
        ),
      ],
    );
  }
}
