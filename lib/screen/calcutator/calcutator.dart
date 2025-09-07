
import 'package:flutter/material.dart';
import 'dart:math' as math;


class SIPCalculatorScreen extends StatefulWidget {
  @override
  _SIPCalculatorScreenState createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  double investmentAmount = 5000;
  double duration = 10;
  double expectedReturns = 12;
  double annualInc = 0;

  double totalInvested = 0;
  double maturityValue = 0;
  double totalGains = 0;

  @override
  void initState() {
    super.initState();
    calculateSIP();
  }

  void calculateSIP() {
    double monthlyRate = expectedReturns / 100 / 12;
    int totalMonths = (duration * 12).toInt();
    double currentSIP = investmentAmount;

    totalInvested = 0;
    maturityValue = 0;

    for (int month = 1; month <= totalMonths; month++) {
      if (month > 1 && (month - 1) % 12 == 0) {
        currentSIP += annualInc;
      }
      totalInvested += currentSIP;
    }

    // Simple SIP calculation
    if (annualInc == 0) {
      maturityValue = investmentAmount *
          ((math.pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate) *
          (1 + monthlyRate);
    } else {
      // Complex calculation with annual increment
      maturityValue = 0;
      currentSIP = investmentAmount;
      for (int year = 1; year <= duration; year++) {
        double yearlyInvestment = currentSIP * 12;
        double yearsRemaining = duration - year + 1;
        double yearlyFV = yearlyInvestment *
            ((math.pow(1 + monthlyRate, 12) - 1) / monthlyRate) *
            (1 + monthlyRate) *
            math.pow(1 + expectedReturns / 100, yearsRemaining - 1);
        maturityValue += yearlyFV;
        currentSIP += annualInc;
      }
    }

    totalGains = maturityValue - totalInvested;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'SIP Returns Calculator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [

              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Controls
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSlider(
                    'Investment Amount',
                    '₹${investmentAmount.toStringAsFixed(0)}K',
                    investmentAmount,
                    1,
                    100,
                        (value) => setState(() {
                      investmentAmount = value * 1000;
                      calculateSIP();
                    }),
                  ),
                  SizedBox(height: 25),
                  _buildSlider(
                    'Duration',
                    '${duration.toInt()} years',
                    duration,
                    1,
                    30,
                        (value) => setState(() {
                      duration = value;
                      calculateSIP();
                    }),
                  ),
                  SizedBox(height: 25),
                  _buildSlider(
                    'Expected Returns',
                    '${expectedReturns.toInt()}%',
                    expectedReturns,
                    5,
                    30,
                        (value) => setState(() {
                      expectedReturns = value;
                      calculateSIP();
                    }),
                  ),


                ],
              ),
            ),

            SizedBox(height: 25),

            // Results Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildResultCard(
                      'Total Invested',
                      '₹${_formatAmount(totalInvested)}',
                      Colors.blue[400]!,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildResultCard(
                      'Maturity Value',
                      '₹${_formatAmount(maturityValue)}',
                      Colors.black87,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildResultCard(
                      'Gains',
                      '₹${_formatAmount(totalGains)}',
                      Colors.green[400]!,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // Information Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Investment Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _buildInfoRow('Monthly SIP', '₹${investmentAmount.toStringAsFixed(0)}'),
                  _buildInfoRow('Investment Period', '${duration.toInt()} years'),
                  _buildInfoRow('Total Months', '${(duration * 12).toInt()}'),
                  _buildInfoRow('Expected Annual Return', '${expectedReturns.toStringAsFixed(1)}%'),
                  if (annualInc > 0)
                    _buildInfoRow('Annual Step-up', '₹${annualInc.toStringAsFixed(0)}'),
                  Divider(height: 20, color: Colors.blue[200]),
                  _buildInfoRow('Wealth Created', '₹${_formatAmount(totalGains)}', isHighlight: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String title, String value, double currentValue, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blue[400],
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.blue[600],
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: title.contains('Investment') ? currentValue / 1000 : currentValue,
            min: min,
            max: max,
            divisions: title.contains('Investment') ? 99 :
            title.contains('Duration') ? 29 :
            title.contains('Returns') ? 25 : 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? Colors.blue[800] : Colors.grey[700],
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlight ? Colors.green[600] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) { // 1 crore
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) { // 1 lakh
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) { // 1 thousand
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}