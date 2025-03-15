import 'package:flutter/material.dart';
import 'add_bank_screen.dart';

class BankInfoScreen extends StatelessWidget {
  // Dummy bank details list; replace with your actual data source
  final List<Map<String, String>> bankDetails = [
    {
      "bankName": "Sample Bank",
      "branch": "Mumbai",
      "accountHolder": "John Doe",
      "accountNumber": "1234567890",
      "ifsc": "SBIN0001234",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Bank Information", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (bankDetails.isEmpty)
              Expanded(
                child: Center(
                  child: Text("No bank details available.",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: bankDetails.length,
                  itemBuilder: (context, index) {
                    final bank = bankDetails[index];
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[700]!),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bank["bankName"] ?? "",
                              style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text("Branch: ${bank["branch"] ?? ""}",
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 4),
                            Text("Account Holder: ${bank["accountHolder"] ?? ""}",
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 4),
                            Text("Account Number: ${bank["accountNumber"] ?? ""}",
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 4),
                            Text("IFSC: ${bank["ifsc"] ?? ""}",
                                style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBankScreen()),
                );
              },
              icon: Icon(Icons.add, color: Colors.black),
              label: Text("Add Bank",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
