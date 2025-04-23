import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentCalculator extends StatefulWidget {
  @override
  _InvestmentCalculatorState createState() => _InvestmentCalculatorState();
}

class _InvestmentCalculatorState extends State<InvestmentCalculator> {
  bool isSIPSelected = true;
  double monthlyInvestment = 25000;
  double expectedReturn = 12;
  double timePeriod = 10;
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "en_IN");

  @override
  Widget build(BuildContext context) {
    final investedAmount = isSIPSelected
        ? monthlyInvestment * timePeriod * 12
        : monthlyInvestment;
    final returns = calculateReturns();
    final totalValue = investedAmount + returns;

    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Calculator'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildToggleButtons(),
            SizedBox(height: 24),
            _buildCalculatorInputs(),
            SizedBox(height: 24),
            _buildResults(investedAmount, returns, totalValue),
            SizedBox(height: 24),
            _buildPieChart(investedAmount, returns),
            SizedBox(height: 24),
            _buildInvestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSIPSelected = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSIPSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'SIP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSIPSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSIPSelected = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isSIPSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Lumpsum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: !isSIPSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorInputs() {
    return Column(
      children: [
        _buildInputField(
          label: isSIPSelected ? 'Monthly Investment' : 'Lumpsum Investment',
          value: monthlyInvestment,
          min: 500,
          max: isSIPSelected ? 100000 : 10000000,
          prefix: '₹',
          onChanged: (value) => setState(() => monthlyInvestment = value),
        ),
        _buildInputField(
          label: 'Expected return rate (p.a)',
          value: expectedReturn,
          min: 1,
          max: 30,
          suffix: '%',
          onChanged: (value) => setState(() => expectedReturn = value),
        ),
        _buildInputField(
          label: 'Time period',
          value: timePeriod,
          min: 1,
          max: 40,
          suffix: 'Yr',
          onChanged: (value) => setState(() => timePeriod = value),
        ),
      ],
    );
  }
  Widget _buildInputField({
    required String label,
    required double value,
    required double min,
    required double max,
    String? prefix,
    String? suffix,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14)),
            SizedBox(
              width: 120,
              child: TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: prefix,
                  suffixText: suffix,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue, width: 2), // Blue border on focus
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400, width: 1), // Default border
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
                controller: TextEditingController(text: value.toStringAsFixed(0)),
              )
              ,
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: (newValue) => onChanged(newValue),
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[200],
        ),
        SizedBox(height: 16),
      ],
    );
  }


  Widget _buildResults(double invested, double returns, double total) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildResultRow('Invested amount', invested),
          Divider(),
          _buildResultRow('Est. returns', returns),
          Divider(),
          _buildResultRow('Total value', total),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            '₹${_currencyFormat.format(value)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(double invested, double returns) {
    final total = invested + returns;
    final investedAngle = (invested / total) * 360;
    final returnsAngle = (returns / total) * 360;

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: PieChartPainter(
          investedAngle: investedAngle,
          returnsAngle: returnsAngle,
        ),
      ),
    );
  }

  Widget _buildInvestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {},
        child: Text('INVEST NOW', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  double calculateReturns() {
    if (isSIPSelected) {
      final monthlyRate = expectedReturn / 12 / 100;
      final months = timePeriod * 12;
      return monthlyInvestment *
          ((pow(1 + monthlyRate, months) - 1) / monthlyRate) *
          (1 + monthlyRate) -
          monthlyInvestment * months;
    } else {
      return monthlyInvestment *
          pow(1 + expectedReturn / 100, timePeriod) -
          monthlyInvestment;
    }
  }
}

class PieChartPainter extends CustomPainter {
  final double investedAngle;
  final double returnsAngle;

  PieChartPainter({required this.investedAngle, required this.returnsAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final investedPaint = Paint()
      ..color = Colors.blue[100]!
      ..style = PaintingStyle.fill;

    final returnsPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw invested arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      radians(investedAngle),
      true,
      investedPaint,
    );

    // Draw returns arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + radians(investedAngle),
      radians(returnsAngle),
      true,
      returnsPaint,
    );
  }

  double radians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}