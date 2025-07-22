import 'package:flutter/material.dart';
import '../../screenutills/fund_card_items.dart';
import '../../themes/app_colors.dart';
import '../../utills/constent/mutual_fond_data.dart';
import '../../widget/custom_app_bar.dart';
import '../market/fund_deatils_screen.dart';

class ViewAllFundsScreen extends StatefulWidget {
  final String category;
  final String? filterType;

  const ViewAllFundsScreen({
    Key? key,
    required this.category,
    this.filterType,
  }) : super(key: key);

  @override
  _ViewAllFundsScreenState createState() => _ViewAllFundsScreenState();
}

class _ViewAllFundsScreenState extends State<ViewAllFundsScreen> {
  String _selectedFilter = 'All';
  String _sortBy = 'Returns';
  final List<String> _filters = ['All', 'Equity', 'Debt', 'Hybrid', 'Tax Saving'];
  final List<String> _sortOptions = ['Returns', 'Rating', 'Min SIP', 'Risk'];

  @override
  void initState() {
    super.initState();
    if (widget.filterType != null) {
      _selectedFilter = widget.filterType!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.category,
      ),
      backgroundColor: AppColors.screenBackground,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MutualFondData.mutualFunds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final filteredFunds = _getFilteredFunds(snapshot.data!);
          return Column(
            children: [
              // Filter and Sort Section
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SingleChildScrollView(
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
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '${filteredFunds.length} Funds',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.headingText,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.accent),
                              style: TextStyle(color: AppColors.primaryText),
                              dropdownColor: AppColors.cardBackground,
                              items: _sortOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    'Sort by $value',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sortBy = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Funds Grid
              Expanded(
                child: filteredFunds.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredFunds.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FundDetailsScreen(
                                fund: filteredFunds[index],
                              ),
                            ),
                          );
                        },
                        child: FundCard(
                          fund: filteredFunds[index],
                          isDarkMode: false,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFunds(List<Map<String, dynamic>> funds) {
    List<Map<String, dynamic>> filteredFunds = funds;

    if (_selectedFilter != 'All') {
      filteredFunds = filteredFunds
          .where((fund) => fund['category'] == _selectedFilter)
          .toList();
    }

    switch (_sortBy) {
      case 'Returns':
        filteredFunds.sort((a, b) {
          double returnA = double.tryParse(
              a['returns'].toString().replaceAll('%', '').replaceAll('+', '')) ??
              0;
          double returnB = double.tryParse(
              b['returns'].toString().replaceAll('%', '').replaceAll('+', '')) ??
              0;
          return returnB.compareTo(returnA);
        });
        break;
      case 'Rating':
        filteredFunds.sort((a, b) {
          double ratingA = double.tryParse(a['rating'].toString()) ?? 0;
          double ratingB = double.tryParse(b['rating'].toString()) ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'Min SIP':
        filteredFunds.sort((a, b) {
          int sipA = int.tryParse(
              a['minSip'].toString().replaceAll('₹', '').replaceAll(',', '')) ??
              0;
          int sipB = int.tryParse(
              b['minSip'].toString().replaceAll('₹', '').replaceAll(',', '')) ??
              0;
          return sipA.compareTo(sipB);
        });
        break;
      case 'Risk':
        filteredFunds.sort((a, b) {
          int riskA = a['risk'] ?? 0;
          int riskB = b['risk'] ?? 0;
          return riskA.compareTo(riskB);
        });
        break;
    }

    return filteredFunds;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.accent,
          ),
          SizedBox(height: 16),
          Text(
            'No Funds Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}