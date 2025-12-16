import 'dart:math';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../widget/common_app_bar.dart';

class LumpsumCalculator extends StatefulWidget {
  const LumpsumCalculator({Key? key}) : super(key: key);

  @override
  _LumpsumCalculatorState createState() => _LumpsumCalculatorState();
}

class _LumpsumCalculatorState extends State<LumpsumCalculator> {
  // Default values with proper constraints
  double totalInvestment = 25000;
  double expectedReturn = 12;
  double timePeriod = 10;
  String timeUnit = 'Years'; // 'Days', 'Months', 'Years'

  final NumberFormat _currencyFormat = NumberFormat("#,##0", "en_IN");

  // Controllers for input fields
  late TextEditingController _investmentController;
  late TextEditingController _returnController;
  late TextEditingController _timePeriodController;

  // Constraints
  static const double MIN_INVESTMENT = 500;
  static const double MAX_INVESTMENT = 10000000;
  static const double MIN_RETURN = 1;
  static const double MAX_RETURN = 30;

  @override
  void initState() {
    super.initState();
    _investmentController = TextEditingController(
      text: totalInvestment.toStringAsFixed(0),
    );
    _returnController = TextEditingController(
      text: expectedReturn.toStringAsFixed(1),
    );
    _timePeriodController = TextEditingController(
      text: timePeriod.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _investmentController.dispose();
    _returnController.dispose();
    _timePeriodController.dispose();
    super.dispose();
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
        return {'min': 30, 'max': 14600}; // 30 days to 40 years
      case 'Months':
        return {'min': 1, 'max': 480}; // 1 month to 40 years
      case 'Years':
        return {'min': 1, 'max': 40}; // 1 to 40 years
      default:
        return {'min': 1, 'max': 40};
    }
  }

  // Validate and update investment amount
  void _updateInvestment(String text) {
    final newValue = double.tryParse(text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(MIN_INVESTMENT, MAX_INVESTMENT);
      setState(() {
        totalInvestment = clampedValue;
      });
      // Update controller only if value was clamped
      if (clampedValue != newValue) {
        _investmentController.text = clampedValue.toStringAsFixed(0);
        _investmentController.selection = TextSelection.fromPosition(
          TextPosition(offset: _investmentController.text.length),
        );
      }
    }
  }

  // Validate and update expected return
  void _updateReturn(String text) {
    final newValue = double.tryParse(text);
    if (newValue != null) {
      final clampedValue = newValue.clamp(MIN_RETURN, MAX_RETURN);
      setState(() {
        expectedReturn = clampedValue;
      });
      // Update controller only if value was clamped
      if (clampedValue != newValue) {
        _returnController.text = clampedValue.toStringAsFixed(1);
        _returnController.selection = TextSelection.fromPosition(
          TextPosition(offset: _returnController.text.length),
        );
      }
    }
  }

  // Validate and update time period
  void _updateTimePeriod(String text) {
    final newValue = double.tryParse(text);
    if (newValue != null) {
      final limits = getTimeLimits();
      final clampedValue = newValue.clamp(limits['min']!, limits['max']!);
      setState(() {
        timePeriod = clampedValue;
      });
      // Update controller only if value was clamped
      if (clampedValue != newValue) {
        _timePeriodController.text = clampedValue.toStringAsFixed(0);
        _timePeriodController.selection = TextSelection.fromPosition(
          TextPosition(offset: _timePeriodController.text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final investedAmount = calculateInvestedAmount();
    final futureValue = calculateFutureValue();
    final returns = futureValue - investedAmount;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Lumpsum Calculator',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calculator Inputs Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1F3A),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildInvestmentField(),
                  SizedBox(height: 24.h),
                  _buildReturnField(),
                  SizedBox(height: 24.h),
                  _buildTimePeriodField(),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Results Section
            Text(
              'Investment Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1F3A),
              ),
            ),
            SizedBox(height: 12.h),
            _buildResults(investedAmount, returns, futureValue),

            SizedBox(height: 24.h),

            // Pie Chart
            _buildPieChart(investedAmount, returns),

            SizedBox(height: 24.h),

            // Disclaimer
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'This calculator provides an estimate based on assumed returns. Actual returns may vary depending on market conditions.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Investment',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Container(
              width: 140.w,
              child: TextFormField(
                controller: _investmentController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1F3A),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1F3A),
                  ),
                  filled: true,
                  fillColor: Color(0xFFDAA520).withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Color(0xFFDAA520).withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Color(0xFFDAA520).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Color(0xFFDAA520),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: _updateInvestment,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFDAA520),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Color(0xFFDAA520),
            overlayColor: Color(0xFFDAA520).withOpacity(0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
            trackHeight: 4.h,
          ),
          child: Slider(
            value: totalInvestment.clamp(MIN_INVESTMENT, MAX_INVESTMENT),
            min: MIN_INVESTMENT,
            max: MAX_INVESTMENT,
            divisions: ((MAX_INVESTMENT - MIN_INVESTMENT) / 500).toInt(),
            onChanged: (value) {
              setState(() {
                totalInvestment = value;
                _investmentController.text = value.toStringAsFixed(0);
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${_formatShort(MIN_INVESTMENT)}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
            Text(
              '₹${_formatShort(MAX_INVESTMENT)}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReturnField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expected Return (p.a.)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Container(
              width: 100.w,
              child: TextFormField(
                controller: _returnController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1F3A),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                ],
                decoration: InputDecoration(
                  suffixText: ' %',
                  suffixStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A1F3A),
                  ),
                  filled: true,
                  fillColor: Color(0xFFDAA520).withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Color(0xFFDAA520).withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Color(0xFFDAA520).withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: Color(0xFFDAA520),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
                onChanged: _updateReturn,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFDAA520),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Color(0xFFDAA520),
            overlayColor: Color(0xFFDAA520).withOpacity(0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
            trackHeight: 4.h,
          ),
          child: Slider(
            value: expectedReturn.clamp(MIN_RETURN, MAX_RETURN),
            min: MIN_RETURN,
            max: MAX_RETURN,
            divisions: ((MAX_RETURN - MIN_RETURN) * 2).toInt(),
            onChanged: (value) {
              setState(() {
                expectedReturn = value;
                _returnController.text = value.toStringAsFixed(1);
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${MIN_RETURN.toInt()}%',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
            Text(
              '${MAX_RETURN.toInt()}%',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
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
              'Time Period',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Row(
              children: [
                Container(
                  width: 80.w,
                  child: TextFormField(
                    controller: _timePeriodController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A1F3A),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFDAA520).withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xFFDAA520).withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xFFDAA520).withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xFFDAA520),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: _updateTimePeriod,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFDAA520).withOpacity(0.1),
                    border: Border.all(
                      color: Color(0xFFDAA520).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: timeUnit,
                      isDense: true,
                      items: ['Days', 'Months', 'Years'].map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A1F3A),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            timeUnit = newValue;
                            final newLimits = getTimeLimits();
                            // Reset to default value within new limits
                            if (timePeriod > newLimits['max']!) {
                              timePeriod = newLimits['max']!;
                            } else if (timePeriod < newLimits['min']!) {
                              timePeriod = newLimits['min']!;
                            }
                            _timePeriodController.text = timePeriod.toStringAsFixed(0);
                          });
                        }
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFFDAA520),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFDAA520),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Color(0xFFDAA520),
            overlayColor: Color(0xFFDAA520).withOpacity(0.2),
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.r),
            trackHeight: 4.h,
          ),
          child: Slider(
            value: timePeriod.clamp(limits['min']!, limits['max']!),
            min: limits['min']!,
            max: limits['max']!,
            divisions: (limits['max']! - limits['min']!).toInt(),
            onChanged: (value) {
              setState(() {
                timePeriod = value;
                _timePeriodController.text = value.toStringAsFixed(0);
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${limits['min']!.toInt()} ${_getUnitLabel(limits['min']!.toInt())}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
            Text(
              '${limits['max']!.toInt()} ${timeUnit}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  String _getUnitLabel(int value) {
    if (timeUnit == 'Days') return value == 1 ? 'Day' : 'Days';
    if (timeUnit == 'Months') return value == 1 ? 'Month' : 'Months';
    return value == 1 ? 'Year' : 'Years';
  }

  Widget _buildResults(double invested, double returns, double total) {
    final yearsEquivalent = getTimePeriodInYears();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFDAA520).withOpacity(0.1),
            Color(0xFFDAA520).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Color(0xFFDAA520).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildResultRow('Invested Amount', invested, Color(0xFF2196F3)),
          Divider(height: 20.h, color: Color(0xFFDAA520).withOpacity(0.3)),
          _buildResultRow('Est. Returns', returns, Color(0xFF4CAF50)),
          Divider(height: 20.h, color: Color(0xFFDAA520).withOpacity(0.3)),
          _buildResultRow('Total Value', total, Color(0xFFDAA520)),
          Divider(height: 20.h, color: Color(0xFFDAA520).withOpacity(0.3)),
          _buildInfoRow(
            'Investment Period',
            '${timePeriod.toInt()} $timeUnit',
          ),
          if (timeUnit != 'Years')
            _buildInfoRow(
              'Equivalent',
              '${yearsEquivalent.toStringAsFixed(2)} Years',
            ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '₹${_currencyFormat.format(value.round())}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A1F3A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(double invested, double returns) {
    final total = invested + returns;
    final investedAngle = total > 0 ? (invested / total) * 360 : 180.0;
    final returnsAngle = total > 0 ? (returns / total) * 360 : 180.0;

    return Column(
      children: [
        SizedBox(
          width: 200.w,
          height: 200.w,
          child: CustomPaint(
            painter: PieChartPainter(
              investedAngle: investedAngle,
              returnsAngle: returnsAngle,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Invested', Color(0xFF2196F3)),
            SizedBox(width: 24.w),
            _buildLegendItem('Returns', Color(0xFF4CAF50)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double calculateInvestedAmount() {
    return totalInvestment;
  }

  // Lumpsum Calculation using compound interest formula
  double calculateFutureValue() {
    final yearsEquivalent = getTimePeriodInYears();
    final annualRate = expectedReturn / 100;

    // Lumpsum Formula: FV = P × (1 + r)^n
    final futureValue = totalInvestment * pow(1 + annualRate, yearsEquivalent);
    return futureValue;
  }

  String _formatShort(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(0)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(0)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
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
      ..color = Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    final returnsPaint = Paint()
      ..color = Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    // Draw invested arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      _radians(investedAngle),
      true,
      investedPaint,
    );

    // Draw returns arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + _radians(investedAngle),
      _radians(returnsAngle),
      true,
      returnsPaint,
    );
  }

  double _radians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}