import 'package:flutter/material.dart';
import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';

class FundDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> fund;

  const FundDetailsScreen({Key? key, required this.fund}) : super(key: key);

  @override
  _FundDetailsScreenState createState() => _FundDetailsScreenState();
}

class _FundDetailsScreenState extends State<FundDetailsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Performance', 'Portfolio', 'Documents'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.fund['name'] ?? 'Fund Details',
      ),
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          // Fund Header Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.screenBackground,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(widget.fund['logo'] ?? "https://via.placeholder.com/150"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fund['name'] ?? 'Demo Fund',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headingText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.fund['category'] ?? 'Equity',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: AppColors.warning, size: 16),
                              SizedBox(width: 4),
                              Text(
                                widget.fund['rating']?.toString() ?? '0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard('Returns', widget.fund['returns'] ?? '0%', Icons.trending_up),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Min SIP', widget.fund['minSip'] ?? '₹1000', Icons.account_balance_wallet),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard('Risk', _getRiskText(widget.fund['risk'] ?? 1), Icons.assessment),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tab = entry.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == index ? AppColors.primaryGold : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: _selectedTab == index ? AppColors.buttonText : AppColors.primaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildTabContent(),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Coming soon - Invest functionality
                      _showComingSoonDialog('Invest');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Invest Now',
                      style: TextStyle(
                        color: AppColors.buttonText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Coming soon - SIP functionality
                      _showComingSoonDialog('SIP');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryGold),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Start SIP',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildPerformanceTab();
      case 2:
        return _buildPortfolioTab();
      case 3:
        return _buildDocumentsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Fund',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'This is a ${widget.fund['category']} fund that aims to provide long-term capital appreciation through a diversified portfolio of equity and equity-related securities.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryText,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Key Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 12),
          _buildFeatureItem('Minimum SIP', widget.fund['minSip'] ?? '₹1000'),
          _buildFeatureItem('Fund Category', widget.fund['category'] ?? 'Equity'),
          _buildFeatureItem('Risk Level', _getRiskText(widget.fund['risk'] ?? 1)),
          _buildFeatureItem('Current Returns', widget.fund['returns'] ?? '0%'),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'Performance Charts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart, size: 64, color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'Portfolio Holdings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'Fund Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskText(int risk) {
    switch (risk) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Moderate';
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            '$feature Feature',
            style: TextStyle(color: AppColors.headingText),
          ),
          content: Text(
            'This feature is coming soon! Stay tuned for updates.',
            style: TextStyle(color: AppColors.primaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: AppColors.primaryGold),
              ),
            ),
          ],
        );
      },
    );
  }
}