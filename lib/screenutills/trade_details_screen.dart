import 'package:flutter/material.dart';

class TradingDetailsScreen extends StatelessWidget {
  final String logo;
  final String name;

  TradingDetailsScreen({required this.logo, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(logo),
              radius: 18,
            ),
            SizedBox(width: 12),
            Text(name, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Status & Current Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard("Current Status", "+7.56%", Colors.green),
                SizedBox(width: 16), // Space between cards
                _buildInfoCard("Current Price (INR)", "₹864.4", Colors.blue[900]!),
              ],
            ),

            Spacer(),

            // Bottom Buttons
            Column(
              children: [
                _buildModernButton("Invest", Icons.trending_up, [Colors.orange, Colors.deepOrange]),
                SizedBox(height: 16), // Space between buttons
                _buildModernButton("Withdraw", Icons.money_off, [Colors.redAccent, Colors.red]),
              ],
            ),

            SizedBox(height: 30), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4, // Slight shadow effect
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton(String text, IconData icon, List<Color> gradientColors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () {},
      ),
    );
  }
}
