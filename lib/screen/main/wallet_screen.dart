import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../../screenutills/trade_details_screen.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "1 Day", "1 Week", "1 Month", "3 Months"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CustomAppBar(
        title: 'Wallet',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceSection(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Investments & Withdrawals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: AppColors.accent),
                  onPressed: () => _showFilterOptions(context),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Filter: $selectedFilter",
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Expanded(child: _buildInvestmentWithdrawList(context)),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Filter",
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: filters.map((filter) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedFilter == filter
                          ? AppColors.accent
                          : AppColors.border,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: selectedFilter == filter
                            ? AppColors.buttonText
                            : AppColors.primaryText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBalanceCard("Total Invested", "₹50,000", AppColors.success),
        SizedBox(width: 12),
        _buildBalanceCard("Total Withdrawn", "₹20,000", AppColors.error),
      ],
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color accentColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),

        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 8),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestmentWithdrawList(BuildContext context) {
    List<Map<String, String>> transactions = [
      {
        "name": "HDFC Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹10,000",
        "date": "2025-02-10 10:30",
        "type": "Investment"
      },
      {
        "name": "ICICI Prudential AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹8,000",
        "date": "2024-02-09 15:45",
        "type": "Withdrawal"
      },
      {
        "name": "ICICI Prudential AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹8,000",
        "date": "2025-02-09 15:45",
        "type": "Withdrawal"
      },
      {
        "name": "ICICI Prudential AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹8,000",
        "date": "2025-02-09 15:45",
        "type": "Withdrawal"
      },
    ];

    List<Map<String, String>> filteredTransactions = transactions.where((transaction) {
      if (selectedFilter == "All") return true;

      DateTime transactionDate = DateTime.parse(transaction['date']!.replaceFirst(' ', 'T'));
      DateTime now = DateTime.now();

      if (selectedFilter == "1 Day") {
        return transactionDate.isAfter(now.subtract(Duration(days: 1)));
      } else if (selectedFilter == "1 Week") {
        return transactionDate.isAfter(now.subtract(Duration(days: 7)));
      } else if (selectedFilter == "1 Month") {
        return transactionDate.isAfter(DateTime(now.year, now.month - 1, now.day));
      } else if (selectedFilter == "3 Months") {
        return transactionDate.isAfter(DateTime(now.year, now.month - 3, now.day));
      }
      return true;
    }).toList();

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(context, filteredTransactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, String> transaction) {
    bool isInvestment = transaction['type'] == "Investment";
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TradingDetailsScreen(
              logo: transaction['logo']!,
              name: transaction['name']!,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),

          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(transaction['logo']!),
              radius: 20,
            ),
            title: Text(
              transaction['name']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            subtitle: Text(
              transaction['date']!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
            trailing: Text(
              transaction['amount']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isInvestment ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ),
      ),
    );
  }
}