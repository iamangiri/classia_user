import 'dart:math';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
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
  String timeUnit = 'Years'; // 'Days', 'Months', 'Years'
  final NumberFormat _currencyFormat = NumberFormat("#,##0", "en_IN");

  // Controllers for input fields
  late TextEditingController _investmentController;
  late TextEditingController _returnController;
  late TextEditingController _timePeriodController;

  @override
  void initState() {
    super.initState();
    _investmentController = TextEditingController(text: monthlyInvestment.toStringAsFixed(0));
    _returnController = TextEditingController(text: expectedReturn.toStringAsFixed(0));
    _timePeriodController = TextEditingController(text: timePeriod.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _investmentController.dispose();
    _returnController.dispose();
    _timePeriodController.dispose();
    super.dispose();
  }

  // Helper method to get time period in days
  double getTimePeriodInDays() {
    switch (timeUnit) {
      case 'Days':
        return timePeriod;
      case 'Months':
        return timePeriod * 30.44; // Average days in a month
      case 'Years':
        return timePeriod * 365.25; // Including leap years
      default:
        return timePeriod * 365.25;
    }
  }

  // Helper method to get time period in years
  double getTimePeriodInYears() {
    switch (timeUnit) {
      case 'Days':
        return timePeriod / 365.25;
      case 'Months':
        return timePeriod / 12;
      case 'Years':
        return timePeriod;
      default:
        return timePeriod;
    }
  }

  // Helper method to get min/max values based on time unit
  Map<String, double> getTimeLimits() {
    switch (timeUnit) {
      case 'Days':
        return {'min': 1, 'max': 14610}; // 40 years = 14610 days
      case 'Months':
        return {'min': 1, 'max': 480}; // 40 years = 480 months
      case 'Years':
        return {'min': 1, 'max': 40};
      default:
        return {'min': 1, 'max': 40};
    }
  }

  @override
  Widget build(BuildContext context) {
    final investedAmount = calculateInvestedAmount();
    final returns = calculateReturns();
    final totalValue = investedAmount + returns;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: 'Plan & Invest',
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
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isSIPSelected = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSIPSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'SIP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSIPSelected
                          ? AppColors.buttonText
                          : AppColors.secondaryText,
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
                  color: !isSIPSelected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Lumpsum',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: !isSIPSelected
                          ? AppColors.buttonText
                          : AppColors.secondaryText,
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
          onChanged: (value) {
            setState(() {
              monthlyInvestment = value;
              _investmentController.text = value.toStringAsFixed(0);
            });
          },
        ),
        _buildInputField(
          label: 'Expected return rate (p.a)',
          value: expectedReturn,
          min: 1,
          max: 30,
          suffix: '%',
          onChanged: (value) {
            setState(() {
              expectedReturn = value;
              _returnController.text = value.toStringAsFixed(0);
            });
          },
        ),
        _buildTimePeriodField(),
      ],
    );
  }

  Widget _buildTimePeriodField() {
    final limits = getTimeLimits();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time period',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.accent, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    controller: _timePeriodController,
                    onChanged: (text) {
                      final newValue = double.tryParse(text) ?? timePeriod;
                      if (newValue >= limits['min']! && newValue <= limits['max']!) {
                        setState(() => timePeriod = newValue);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: timeUnit,
                      items: ['Days', 'Months', 'Years'].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            timeUnit = newValue;
                            // Adjust timePeriod to fit within new unit's limits
                            final newLimits = getTimeLimits();
                            if (timePeriod > newLimits['max']!) {
                              timePeriod = newLimits['max']!;
                            } else if (timePeriod < newLimits['min']!) {
                              timePeriod = newLimits['min']!;
                            }
                            // Update controller text
                            _timePeriodController.text = timePeriod.toStringAsFixed(0);
                          });
                        }
                      },
                      icon: Icon(Icons.arrow_drop_down, color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Slider(
          value: timePeriod,
          min: limits['min']!,
          max: limits['max']!,
          divisions: (limits['max']! - limits['min']!).toInt(),
          label: '${timePeriod.toStringAsFixed(0)} $timeUnit',
          onChanged: (newValue) {
            setState(() {
              timePeriod = newValue;
              _timePeriodController.text = timePeriod.toStringAsFixed(0);
            });
          },
          activeColor: AppColors.accent,
          inactiveColor: AppColors.border,
        ),
        SizedBox(height: 16),
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
    // Determine which controller to use based on the label
    TextEditingController controller;
    if (label.contains('Investment')) {
      controller = _investmentController;
    } else if (label.contains('return')) {
      controller = _returnController;
    } else {
      controller = _timePeriodController;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            SizedBox(
              width: 120,
              child: TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  prefixText: prefix,
                  suffixText: suffix,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accent, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
                controller: controller,
                onChanged: (text) {
                  final newValue = double.tryParse(text) ?? value;
                  if (newValue >= min && newValue <= max) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(0),
          onChanged: (newValue) {
            onChanged(newValue);
            // Update the corresponding controller
            controller.text = newValue.toStringAsFixed(0);
            setState(() {});
          },
          activeColor: AppColors.accent,
          inactiveColor: AppColors.border,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResults(double invested, double returns, double total) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildResultRow('Invested amount', invested),
          Divider(color: AppColors.border),
          _buildResultRow('Est. returns', returns),
          Divider(color: AppColors.border),
          _buildResultRow('Total value', total),
          Divider(color: AppColors.border),
          _buildTimePeriodInfo(),
        ],
      ),
    );
  }

  Widget _buildTimePeriodInfo() {
    final yearsEquivalent = getTimePeriodInYears();
    final daysEquivalent = getTimePeriodInDays();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investment period',
                style: TextStyle(color: AppColors.secondaryText),
              ),
              Text(
                '${timePeriod.toStringAsFixed(0)} $timeUnit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          if (timeUnit != 'Years')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Equivalent years',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${yearsEquivalent.toStringAsFixed(2)} Years',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
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
          Text(
            label,
            style: TextStyle(color: AppColors.secondaryText),
          ),
          Text(
            '₹${_currencyFormat.format(value)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
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

    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: PieChartPainter(
              investedAngle: investedAngle,
              returnsAngle: returnsAngle,
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Invested', AppColors.border),
            SizedBox(width: 20),
            _buildLegendItem('Returns', AppColors.accent),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {},
        child: Text(
          'INVEST NOW',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.buttonText,
          ),
        ),
      ),
    );
  }

  double calculateInvestedAmount() {
    if (isSIPSelected) {
      // For SIP, calculate based on time period
      final yearsEquivalent = getTimePeriodInYears();
      return monthlyInvestment * yearsEquivalent * 12;
    } else {
      // For lumpsum, invested amount is just the principal
      return monthlyInvestment;
    }
  }

  double calculateReturns() {
    final yearsEquivalent = getTimePeriodInYears();

    if (isSIPSelected) {
      // SIP calculation using compound interest formula for regular payments
      final monthlyRate = expectedReturn / 12 / 100;
      final months = yearsEquivalent * 12;

      if (monthlyRate == 0) {
        return 0; // No returns if interest rate is 0
      }

      final futureValue = monthlyInvestment *
          ((pow(1 + monthlyRate, months) - 1) / monthlyRate) *
          (1 + monthlyRate);

      return futureValue - monthlyInvestment * months;
    } else {
      // Lumpsum calculation using compound interest formula
      final futureValue = monthlyInvestment * pow(1 + expectedReturn / 100, yearsEquivalent);
      return futureValue - monthlyInvestment;
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
      ..color = AppColors.border
      ..style = PaintingStyle.fill;

    final returnsPaint = Paint()
      ..color = AppColors.accent
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