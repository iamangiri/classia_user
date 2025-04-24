import 'package:classia_amc/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/trading_card.dart';

class TradingScreen extends StatefulWidget {
  @override
  _TradingScreenState createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  // Sample AMC Data (Normally, this should come from an API)
  List<Map<String, dynamic>> amcList = [
    {
      "name": "Alpha AMC",
      "logo": "https://www.shutterstock.com/image-vector/modern-letter-b-overlapping-line-vector-2184610411",
      "value": 10.0, // Positive value
    },
    {
      "name": "Beta Investments",
      "logo": "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/e8109726-9708-48ac-b7ae-68e564aa6843/df2ymaz-1ef34afe-863b-4ed4-bf64-e64a882cffad.png",
      "value": -4.2, // Negative value
    },
    {
      "name": "Gamma Capital",
      "logo": "https://www.shutterstock.com/image-vector/modern-letter-b-overlapping-line-vector-2184610411",
      "value": 8.3,
    },
    {
      "name": "Delta Funds",
      "logo": "https://www.shutterstock.com/image-vector/modern-letter-b-overlapping-line-vector-2184610411",
      "value": -7.1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Dark background for dark mode
      appBar: CustomAppBar(title: 'Jockey Trading',),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: amcList.length,
          itemBuilder: (context, index) {
            var amc = amcList[index];
            return
               TradingCard(
                  logo: amc["logo"],
                  name: amc["name"],
                  value: amc["value"],
               );
          },
        ),
      ),
    );
  }
}
