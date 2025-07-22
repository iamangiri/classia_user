import 'package:classia_amc/utills/constent/mutual_fond_data.dart';
import 'package:flutter/material.dart';
import '../../screenutills/fund_card_items.dart';
import '../../themes/app_colors.dart';
import '../../widget/custom_app_bar.dart';
import '../market/all_fund_screen.dart';
import '../market/fund_deatils_screen.dart';

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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: MutualFondData.mutualFunds,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No funds available'));
                }

                final funds = snapshot.data!;
                return ListView(
                  children: [
                    _buildCategorySection('Top Performing Funds', Icons.trending_up, 'Equity', funds),
                    _buildCategorySection('Equity Funds', Icons.show_chart, 'Equity', funds),
                    _buildCategorySection('Debt Funds', Icons.assessment, 'Debt', funds),
                    _buildCategorySection('Tax Saving Funds', Icons.savings, 'Tax Saving', funds),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, IconData icon, String categoryFilter, List<Map<String, dynamic>> funds) {
    final filteredFunds = funds
        .where((fund) => _selectedFilter == 'All' || fund['category'] == _selectedFilter)
        .toList();

    final categoryFunds = funds
        .where((fund) => fund['category'] == categoryFilter)
        .take(5)
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAllFundsScreen(
                        category: category,
                        filterType: categoryFilter,
                      ),
                    ),
                  );
                },
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
          height: 210,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categoryFunds.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FundDetailsScreen(
                      fund: categoryFunds[index],
                    ),
                  ),
                );
              },
              child: FundCard(
                fund: categoryFunds[index],
                isDarkMode: false,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}