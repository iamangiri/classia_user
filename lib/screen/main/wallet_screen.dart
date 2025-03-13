import 'package:flutter/material.dart';
import '../../screenutills/trade_details_screen.dart';

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Wallet",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceSection(),
            SizedBox(height: 20),
            Text(
              "Investments & Withdrawals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Expanded(child: _buildInvestmentWithdrawList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBalanceCard("Total Invested", "₹50,000", Colors.green[400]!),
        SizedBox(width: 12),
        _buildBalanceCard("Total Withdrawn", "₹20,000", Colors.redAccent),
      ],
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color accentColor) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
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
                  color: Colors.white70,
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
        "date": "2024-02-10 10:30",
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
        "name": "SBI Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹12,500",
        "date": "2024-02-08 12:15",
        "type": "Investment"
      },
      {
        "name": "Axis Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹5,000",
        "date": "2024-02-07 14:00",
        "type": "Withdrawal"
      },
      {
        "name": "Nippon India AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹7,500",
        "date": "2024-02-06 11:20",
        "type": "Investment"
      },
      {
        "name": "Kotak Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹9,000",
        "date": "2024-02-05 16:50",
        "type": "Withdrawal"
      },
      {
        "name": "Mirae Asset AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹15,000",
        "date": "2024-02-04 13:40",
        "type": "Investment"
      },
      {
        "name": "Aditya Birla Sun Life AMC",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹6,000",
        "date": "2024-02-03 09:30",
        "type": "Withdrawal"
      },
      {
        "name": "DSP Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹10,500",
        "date": "2024-02-02 17:10",
        "type": "Investment"
      },
      {
        "name": "UTI Mutual Fund",
        "logo": "https://via.placeholder.com/50",
        "amount": "₹4,500",
        "date": "2024-02-01 08:45",
        "type": "Withdrawal"
      },
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(context, transactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, String> transaction) {
    bool isInvestment = transaction['type'] == "Investment";
    Color cardColor = Colors.grey[850]!;
    Color textColor = Colors.white;
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
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(2, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              backgroundImage: NetworkImage(transaction['logo']!),
            ),
            title: Text(
              transaction['name']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            subtitle: Text(
              transaction['date']!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            trailing: Text(
              transaction['amount']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isInvestment ? Colors.green[400] : Colors.red[400],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
