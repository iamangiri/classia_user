import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';
import 'dart:ui';

class SipGoalBasedFundScreen extends StatefulWidget {
  final ExploreGoal goal;

  const SipGoalBasedFundScreen({Key? key, required this.goal}) : super(key: key);

  @override
  _SipGoalBasedFundScreenState createState() => _SipGoalBasedFundScreenState();
}

class _SipGoalBasedFundScreenState extends State<SipGoalBasedFundScreen> with TickerProviderStateMixin {
  double _monthlyAmount = 5000; // Default monthly investment amount
  int _selectedYears = 5; // Default investment period
  final Set<Fund> _selectedFunds = {}; // Track selected funds
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<Fund> suggestedFunds = [
    Fund(
      name: 'Growth Equity Fund',
      returnRate: '12.5%',
      risk: 'High',
      color: Colors.green,
    ),
    Fund(
      name: 'Balanced Hybrid Fund',
      returnRate: '9.8%',
      risk: 'Medium',
      color: Colors.blue,
    ),
    Fund(
      name: 'Debt Fund',
      returnRate: '6.2%',
      risk: 'Low',
      color: Colors.grey,
    ),
  ];

  double _calculateExpectedReturn(String returnRate, double monthlyAmount, int years) {
    // Simplified return calculation: FV = P * (1 + r)^t
    double rate = double.parse(returnRate.replaceAll('%', '')) / 100;
    return monthlyAmount * 12 * years * (1 + rate); // Approximate future value
  }

  void _showSipConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor?.withOpacity(0.9) ?? Color(0xFFF5F5F5).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/anim/sip_anim_success.json',
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text(
                'Your SIP is Ready to Start!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor ?? Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Goal: ${widget.goal.name}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Monthly Amount: ₹${_monthlyAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Investment Period: $_selectedYears years',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText ?? Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Selected Funds:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor ?? Colors.blue,
                ),
              ),
              SizedBox(height: 8),
              ..._selectedFunds.isEmpty
                  ? [
                Text(
                  'No funds selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText ?? Colors.grey,
                  ),
                ),
              ]
                  : _selectedFunds.map(
                    (fund) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '• ${fund.name} (${fund.returnRate}, Est. ₹${_calculateExpectedReturn(fund.returnRate, _monthlyAmount, _selectedYears).toStringAsFixed(0)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText ?? Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Return to ExploreTab
                      // Reset state is handled in ExploreTab
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Confirm SIP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonText ?? Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor ?? Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Choose Best Fund for ${widget.goal.name}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor ?? Colors.blue,
          ),
        ),
        backgroundColor: AppColors.surfaceColor?.withOpacity(0.9) ?? Color(0xFFF5F5F5).withOpacity(0.9),
        elevation: 0,
      ),
      backgroundColor: AppColors.surfaceColor ?? Color(0xFFF5F5F5),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor?.withOpacity(0.9) ?? Color(0xFFF5F5F5).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Investment Period',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [5, 10, 20].map((years) {
                        bool isSelected = _selectedYears == years;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryGold ?? Color(0xFFDAA520) : AppColors.surfaceColor ?? Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? (AppColors.primaryGold?.withOpacity(0.8) ?? Color(0xFFDAA520).withOpacity(0.8))
                                      : Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedYears = years;
                                  });
                                },
                                child: Text(
                                  '$years Years',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.buttonText ?? Colors.white
                                        : AppColors.secondaryText ?? Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor ?? Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Investment Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor ?? Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Slider(
                      value: _monthlyAmount,
                      min: 1000,
                      max: 50000,
                      divisions: 49,
                      label: '₹${_monthlyAmount.toStringAsFixed(0)}',
                      activeColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                      inactiveColor: AppColors.secondaryText?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
                      onChanged: (value) {
                        setState(() {
                          _monthlyAmount = value;
                        });
                      },
                    ),
                    Text(
                      '₹${_monthlyAmount.toStringAsFixed(0)} / month',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ...suggestedFunds.map((fund) {
                bool isSelected = _selectedFunds.contains(fund);
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor?.withOpacity(0.9) ?? Color(0xFFF5F5F5).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(
                      color: AppColors.success ?? Colors.green,
                      width: 2,
                    )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fund.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor ?? Colors.blue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Risk: ${fund.risk}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.secondaryText ?? Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Expected Return: ${fund.returnRate}',
                              style: TextStyle(
                                fontSize: 14,
                                color: fund.color,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Est. Value ($_selectedYears yrs): ₹${_calculateExpectedReturn(fund.returnRate, _monthlyAmount, _selectedYears).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.success ?? Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.success ?? Colors.green : AppColors.primaryGold ?? Color(0xFFDAA520),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? (AppColors.success?.withOpacity(0.8) ?? Colors.green.withOpacity(0.8))
                                : (AppColors.primaryGold?.withOpacity(0.8) ?? Color(0xFFDAA520).withOpacity(0.8)),
                            width: 1,
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                _selectedFunds.remove(fund);
                              } else {
                                _selectedFunds.add(fund);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Icon(
                                  Icons.check,
                                  size: 18,
                                  color: AppColors.buttonText ?? Colors.white,
                                ),
                              if (isSelected) SizedBox(width: 8),
                              Text(
                                isSelected ? 'Selected' : 'Choose',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.buttonText ?? Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showSipConfirmationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold ?? Color(0xFFDAA520),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Start SIP Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText ?? Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreGoal {
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  final String lottieAsset;

  ExploreGoal({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    required this.lottieAsset,
  });
}

class Fund {
  final String name;
  final String returnRate;
  final String risk;
  final Color color;

  Fund({
    required this.name,
    required this.returnRate,
    required this.risk,
    required this.color,
  });
}