import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../themes/app_colors.dart';
import 'jockey_sip_screen.dart';
import 'dart:ui';

class ExploreTab extends StatefulWidget {
  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with TickerProviderStateMixin {
  ExploreGoal? _selectedGoal;
  double _monthlyAmount = 5000; // Default monthly investment amount
  int _selectedYears = 5; // Default investment period
  late AnimationController _horseAnimationController;
  late Animation<double> _horseAnimation;
  final Set<Fund> _selectedFunds = {}; // Track selected funds

  @override
  void initState() {
    super.initState();
    _horseAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _horseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _horseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _horseAnimationController.dispose();
    super.dispose();
  }

  final List<ExploreGoal> exploreGoals = [
    ExploreGoal(
      name: 'Buying a Home',
      icon: Icons.home,
      description: 'Own your dream house',
      color: Colors.blueAccent,
      lottieAsset: 'assets/anim/sip_anim_6.json',
    ),
    ExploreGoal(
      name: 'Buying a Car',
      icon: Icons.directions_car,
      description: 'Drive your dream car',
      color: Colors.green,
      lottieAsset: 'assets/anim/sip_anim_7.json',
    ),
    ExploreGoal(
      name: 'Travel or Vacation',
      icon: Icons.flight_takeoff,
      description: 'Explore the world',
      color: Colors.pink,
      lottieAsset: 'assets/anim/sip_anim_5.json',
    ),
    ExploreGoal(
      name: 'Child’s Education',
      icon: Icons.school,
      description: 'Secure their future',
      color: Colors.indigo,
      lottieAsset: 'assets/anim/sip_anim_4.json',
    ),
    ExploreGoal(
      name: 'Wedding',
      icon: Icons.favorite,
      description: 'Plan your big day',
      color: Colors.purple,
      lottieAsset: 'assets/anim/sip_anim_2.json',
    ),
    ExploreGoal(
      name: 'Emergency Fund',
      icon: Icons.security,
      description: 'Build your safety net',
      color: Colors.red,
      lottieAsset: 'assets/anim/sip_anim_1.json',
    ),
  ];

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

  Widget _buildAnimatedHorse() {
    return AnimatedBuilder(
      animation: _horseAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 5 * (0.5 - (_horseAnimation.value - 0.5).abs())),
          child: Transform.rotate(
            angle: 0.1 * (0.5 - (_horseAnimation.value - 0.5).abs()),
            child: Container(
              width: 150,
              height: 100,
              child: Center(
                child: Image.asset(
                  'assets/images/jt1.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
            color: AppColors.surfaceColor.withOpacity(0.9),
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
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Goal: ${_selectedGoal!.name}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Monthly Amount: ₹${_monthlyAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Investment Period: $_selectedYears years',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Selected Funds:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              ..._selectedFunds.isEmpty
                  ? [
                Text(
                  'No funds selected',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
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
                      color: AppColors.secondaryText,
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
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement final SIP confirmation logic
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedGoal = null;
                        _selectedFunds.clear();
                        _selectedYears = 5; // Reset to default
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
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
                        color: AppColors.buttonText,
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _selectedGoal == null ? _buildGoalSelection() : _buildFundSelection(),
      ),
    );
  }

  Widget _buildGoalSelection() {
    return Column(
      key: ValueKey('goal_selection'),
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              _buildAnimatedHorse(),
              SizedBox(height: 16),
              Text(
                'Explore New Goals',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Discover investment opportunities',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search investment goals...',
              prefixIcon: Icon(Icons.search, color: AppColors.secondaryText),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: exploreGoals.length,
          itemBuilder: (context, index) {
            ExploreGoal goal = exploreGoals[index];
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 600 + (index * 100)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGoal = goal;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            goal.lottieAsset,
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 12),
                          Text(
                            goal.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            goal.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFundSelection() {
    return Column(
      key: ValueKey('fund_selection'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with back button
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
              onPressed: () {
                setState(() {
                  _selectedGoal = null;
                  _selectedFunds.clear();
                  _selectedYears = 5; // Reset to default
                });
              },
            ),
            Expanded(
              child: Text(
                'Choose Best Fund for ${_selectedGoal!.name}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // Investment Period Selection
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor.withOpacity(0.9),
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
                  color: AppColors.primaryColor,
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
                          color: isSelected ? AppColors.primaryGold : AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGold.withOpacity(0.8) : Colors.white.withOpacity(0.2),
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
                              color: isSelected ? AppColors.buttonText : AppColors.secondaryText,
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
        // Monthly Investment Slider
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
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
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Slider(
                value: _monthlyAmount,
                min: 1000,
                max: 50000,
                divisions: 49,
                label: '₹${_monthlyAmount.toStringAsFixed(0)}',
                activeColor: AppColors.primaryGold,
                inactiveColor: AppColors.secondaryText.withOpacity(0.3),
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
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        // Suggested Funds
        ...suggestedFunds.map((fund) {
          bool isSelected = _selectedFunds.contains(fund);
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor.withOpacity(0.9),
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
                color: AppColors.success,
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
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Risk: ${fund.risk}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
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
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.success : AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.success.withOpacity(0.8) : AppColors.primaryGold.withOpacity(0.8),
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
                            color: AppColors.buttonText,
                          ),
                        if (isSelected) SizedBox(width: 8),
                        Text(
                          isSelected ? 'Selected' : 'Choose',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonText,
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
        // Start SIP Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showSipConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
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
                color: AppColors.buttonText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Updated ExploreGoal to include lottieAsset
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