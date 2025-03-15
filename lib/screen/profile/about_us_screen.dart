import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white), // White back icon
        title: Text(
          "About Us",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Welcome to Jockey Trading",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Description Paragraph
            Text(
              "At Jockey Trading, we make trading easy. You don't need complex knowledge or advanced skills to start trading. Our platform is designed to be simple, intuitive, and user-friendly—allowing you to focus on making smart investment decisions.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            // Market Section
            Text(
              "Our Market",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "We showcase a wide range of mutual funds and trading options. Our market is curated to give you the best opportunities without the need for deep technical knowledge. Whether you're new to trading or an experienced investor, our offerings are designed with you in mind.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            // Benefits Section
            Text(
              "Why Choose Jockey Trading?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildBenefitItem(Icons.check, "Simple and intuitive platform design"),
            SizedBox(height: 8),
            _buildBenefitItem(Icons.check, "Wide range of mutual funds and trading options"),
            SizedBox(height: 8),
            _buildBenefitItem(Icons.check, "No need for complex trading knowledge"),
            SizedBox(height: 8),
            _buildBenefitItem(Icons.check, "24/7 customer support and easy access to market data"),
            SizedBox(height: 24),
            // Call-to-Action
            Center(
              child: Text(
                "Join Jockey Trading today and start your trading journey with confidence!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to registration or contact screen if needed.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.greenAccent, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
