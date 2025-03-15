import 'package:flutter/material.dart';
import '../../screenutills/trade_details_screen.dart';

class InvestmentHistoryScreen extends StatefulWidget {
  @override
  _InvestmentHistoryScreenState createState() => _InvestmentHistoryScreenState();
}

class _InvestmentHistoryScreenState extends State<InvestmentHistoryScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "1 Day", "1 Week", "1 Month", "3 Months"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // Makes the back icon white
        backgroundColor: Colors.black,
        title: Text(
          "Investment History",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvestmentSummarySection(),
            SizedBox(height: 20),
            Text(
              "Investment History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              "Filter: $selectedFilter",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 8),
            Expanded(child: _buildInvestmentList(context)),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Filter",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: filters.map((filter) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFilter == filter ? Colors.blue : Colors.grey[800],
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedFilter = filter;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(filter, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvestmentSummarySection() {
    // Summary card for total invested amount
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900]!.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Total Invested",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("₹50,000",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentList(BuildContext context) {
    // Hard-coded list of investment transactions
    List<Map<String, String>> transactions = [
      {
        "name": "HDFC Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹10,000",
        "date": "2025-02-10 10:30",
        "type": "Investment"
      },
      {
        "name": "SBI Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹12,500",
        "date": "2025-02-08 12:15",
        "type": "Investment"
      },
      {
        "name": "Mirae Asset AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹15,000",
        "date": "2025-02-04 13:40",
        "type": "Investment"
      },
      {
        "name": "DSP Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹10,500",
        "date": "2025-02-02 17:10",
        "type": "Investment"
      },
    ];

    // Filter the transactions based on the selected filter
    List<Map<String, String>> filteredTransactions = transactions.where((transaction) {
      if (selectedFilter == "All") return true;

      // Convert the date string into a valid ISO format
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
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(transaction['logo']!)),
            title: Text(transaction['name']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Text(transaction['date']!, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            trailing: Text(transaction['amount']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          ),
        ),
      ),
    );
  }
}
