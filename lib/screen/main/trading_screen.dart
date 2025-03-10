import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
      "logo": "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/e8109726-9708-48ac-b7ae-68e564aa6843/df2ymaz-1ef34afe-863b-4ed4-bf64-e64a882cffad.png/v1/fill/w_1177,h_679/amc_alpha_movie_channel_logo_by_zacktastic2006_df2ymaz-pre.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9NzM4IiwicGF0aCI6IlwvZlwvZTgxMDk3MjYtOTcwOC00OGFjLWI3YWUtNjhlNTY0YWE2ODQzXC9kZjJ5bWF6LTFlZjM0YWZlLTg2M2ItNGVkNC1iZjY0LWU2NGE4ODJjZmZhZC5wbmciLCJ3aWR0aCI6Ijw9MTI4MCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.y-9Z4V4zWnLT44GQZuJAqPVqt4TVe1MhtUEw9P_R8ro",
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
      backgroundColor: Colors.white, // Dark mode for a modern feel
     
        appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        title: Text(
          'Live Trading',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: amcList.length,
        itemBuilder: (context, index) {
          var amc = amcList[index];
          return TradingCard(
            logo: amc["logo"],
            name: amc["name"],
            value: amc["value"],
          );
        },
      ),
    );
  }
}


  