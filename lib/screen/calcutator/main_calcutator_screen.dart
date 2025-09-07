import 'package:classia_amc/screen/calcutator/calcutator.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../widget/common_app_bar.dart';
import 'lumpsum_calculator.dart';


class InvestmentCalculator extends StatefulWidget {
  @override
  _InvestmentCalculatorState createState() => _InvestmentCalculatorState();
}

class _InvestmentCalculatorState extends State<InvestmentCalculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: 'Investment Calculators',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            SizedBox(height: 32),
            _buildCalculatorCards(),
            SizedBox(height: 24),
            _buildWhyInvestSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.primaryGold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'Plan & Invest',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Choose the right investment strategy for your financial goals',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Free Financial Planning Tools',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Calculator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCalculatorCard(
                title: 'SIP Calculator',
                subtitle: 'Systematic Investment Plan',
                description: '',
                icon: Icons.trending_up,
                color: AppColors.accent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SIPCalculatorScreen()),
                  );
                },

              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildCalculatorCard(
                title: 'Lumpsum Calculator',
                subtitle: 'One-time Investment',
                description: '',
                icon: Icons.account_balance_wallet,
                color: AppColors.primaryGold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LumpsumCalculator()),
                  );
                },

              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalculatorCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.3,
              ),
            ),
            SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Calculate Now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyInvestSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.accent,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Why Use Investment Calculators?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.visibility,
            title: 'Clear Financial Planning',
            description: 'Visualize your investment growth over time',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.compare_arrows,
            title: 'Compare Strategies',
            description: 'Compare SIP vs Lumpsum for your goals',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.timeline,
            title: 'Goal-Based Investing',
            description: 'Plan investments based on your financial targets',
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.security,
            title: 'Risk Assessment',
            description: 'Understand returns at different risk levels',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 16,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}