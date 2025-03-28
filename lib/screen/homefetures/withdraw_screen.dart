import 'package:flutter/material.dart';
import '../../screenutills/trade_details_screen.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "1 Day", "1 Week", "1 Month", "3 Months"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          "Withdrawals History",
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
            _buildWithdrawSummarySection(),
            SizedBox(height: 20),
            Text(
              "Withdrawal History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              "Filter: $selectedFilter",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            SizedBox(height: 8),
            Expanded(child: _buildWithdrawalList(context)),
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

  Widget _buildWithdrawSummarySection() {
    // Displaying a summary card for total withdrawn
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
                  Text("Total Withdrawn",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                  SizedBox(height: 8),
                  Text("₹20,000",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalList(BuildContext context) {
    // Hard-coded withdrawal transactions list
    List<Map<String, String>> transactions = [
      {
        "name": "ICICI Prudential AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹8,000",
        "date": "2025-02-09 15:45",
        "type": "Withdrawal"
      },
      {
        "name": "Axis Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹5,000",
        "date": "2025-02-07 14:00",
        "type": "Withdrawal"
      },
      {
        "name": "Aditya Birla Sun Life AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹6,000",
        "date": "2025-02-03 09:30",
        "type": "Withdrawal"
      },
      {
        "name": "UTI Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹4,500",
        "date": "2025-02-01 08:45",
        "type": "Withdrawal"
      },
    ];

    // Filter the transactions based on selectedFilter
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
            trailing: Text(transaction['amount']!,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ),
        ),
      ),
    );
  }
}
