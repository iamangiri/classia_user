import 'package:flutter/material.dart';
import '../../screenutills/fond_deatils_screen.dart';
import '../../utills/constent/mutual_fond_data.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Equity', 'Debt', 'Hybrid', 'Tax Saving'];



  bool get isDarkMode => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mutual Funds Market'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
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
                      onSelected: (selected) => setState(() => _selectedFilter = filter),
                      backgroundColor: isDarkMode ? Colors.grey[800]! : Color(0xFFF8F9FA),
                      selectedColor: isDarkMode ? Colors.amber : Color(0xFF2196F3),
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? Colors.black
                            : isDarkMode ? Colors.white : Color(0xFF212121),
                      ),
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
    final filteredFunds = MutualFondData.mutualFunds.where((fund) =>
    _selectedFilter == 'All' || fund['category'] == _selectedFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: isDarkMode ? Colors.blueGrey[200] : Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text(category, style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Color(0xFF212121),
              )),
              Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filteredFunds.length,
            separatorBuilder: (_, __) => SizedBox(width: 16),
            itemBuilder: (context, index) => FundCard(fund: filteredFunds[index], isDarkMode: true),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}


