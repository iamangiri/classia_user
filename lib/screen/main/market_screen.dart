import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../screenutills/fund_card_items.dart';
import '../../utills/constent/mutual_fond_data.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Equity', 'Debt', 'Hybrid', 'Tax Saving'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mutual Funds Market',
      ),
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) =>
                          setState(() => _selectedFilter = filter),
                      backgroundColor: AppColors.border,
                      selectedColor: AppColors.primaryGold,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? AppColors.buttonText
                            : AppColors.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Fund List
          Expanded(
            child: ListView(
              children: [
                _buildCategorySection('Top Performing Funds', Icons.trending_up),
                _buildCategorySection('Equity Funds', Icons.show_chart),
                _buildCategorySection('Debt Funds', Icons.assessment),
                _buildCategorySection('Tax Saving Funds', Icons.savings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, IconData icon) {
    final filteredFunds = MutualFondData.mutualFunds
        .where((fund) =>
    _selectedFilter == 'All' || fund['category'] == _selectedFilter)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.accent,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingText,
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.buttonText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 210, // Reduced height to match compact FundCard
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filteredFunds.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) => FundCard(
              fund: filteredFunds[index],
              isDarkMode: false,
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}