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
  List<Map<String, dynamic>> amcList = <Map<String, dynamic>>[
    {
      "logo": "https://www.quantmutual.com/images/logo.png",
      "name": "Quant",
      "fundName": "Small Cap Fund",
      "value": 51.2,
    },

    {
      "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
      "name": "Nippon India",
      "fundName": "Small Cap Fund",
      "value": 46.8,
    },

    {
      "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
      "name": "SBI",
      "fundName": "Small Cap Fund",
      "value": 41.5,
    },

    {
      "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
      "name": "ICICI Prudential",
      "fundName": "Technology Fund",
      "value": 43.1,
    },

    {
      "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
      "name": "HDFC",
      "fundName": "Mid-Cap Opportunities Fund",
      "value": 38.7,
    },

    {
      "logo": "https://www.axisbank.com/images/default-source/revamp_new/logo.png",
      "name": "Axis",
      "fundName": "Small Cap Fund",
      "value": 37.2,
    },

    {
      "logo": "https://www.motilaloswalmf.com/images/logo.png",
      "name": "Motilal Oswal",
      "fundName": "Midcap Fund",
      "value": 36.4,
    },

    {
      "logo": "https://www.kotak.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png",
      "name": "Kotak",
      "fundName": "Emerging Equity Fund",
      "value": 35.6,
    },

    {
      "logo": "https://www.ppfas.com/images/logo.png",
      "name": "Parag Parikh",
      "fundName": "Flexi Cap Fund",
      "value": 32.8,
    },

    {
      "logo": "https://www.adityabirlacapital.com/abc/abslmf/images/logo.png",
      "name": "Aditya Birla Sun Life",
      "fundName": "Small Cap Fund",
      "value": 33.5,
    },

    {
      "logo": "https://www.dspim.com/images/logo.png",
      "name": "DSP",
      "fundName": "Small Cap Fund",
      "value": 29.7,
    },

    {
      "logo": "https://www.ltfs.com/content/dam/lnt-financial-services/lnt-mutual-fund/images/logo.png",
      "name": "L&T",
      "fundName": "Emerging Businesses Fund",
      "value": 27.8,
    },

    {
      "logo": "https://www.sundarammutual.com/images/logo.png",
      "name": "Sundaram",
      "fundName": "Small Cap Fund",
      "value": 26.5,
    },

    {
      "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
      "name": "ICICI Prudential",
      "fundName": "Smallcap Fund",
      "value": 25.9,
    },

    {
      "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
      "name": "Nippon India",
      "fundName": "Growth Fund",
      "value": 24.3,
    },

    {
      "logo": "https://www.kotak.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png",
      "name": "Kotak",
      "fundName": "Small Cap Fund",
      "value": 23.7,
    },

    {
      "logo": "https://www.axisbank.com/images/default-source/revamp_new/logo.png",
      "name": "Axis",
      "fundName": "Midcap Fund",
      "value": 22.9,
    },

    {
      "logo": "https://www.miraeassetmf.co.in/images/logo.png",
      "name": "Mirae Asset",
      "fundName": "Emerging Bluechip Fund",
      "value": 21.8,
    },

    {
      "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
      "name": "HDFC",
      "fundName": "Small Cap Fund",
      "value": 20.5,
    },

    {
      "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
      "name": "SBI",
      "fundName": "Bluechip Fund",
      "value": 19.7,
    },

  ];

  @override
  void initState() {
    super.initState();
    // Sort by value in descending order
    amcList.sort((a, b) => b["value"].compareTo(a["value"]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(title: 'Jockey Trading'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: amcList.length,
          itemBuilder: (context, index) {
            var amc = amcList[index];
            return TradingCard(
              logo: amc["logo"],
              name: amc["name"],
              fundName: amc["fundName"],
              value: amc["value"],
            );
          },
        ),
      ),
    );
  }
}

