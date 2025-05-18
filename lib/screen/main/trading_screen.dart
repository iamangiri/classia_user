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
      "name": "Quant Small Cap Fund",
      "logo": "https://www.quantmutual.com/images/logo.png",
      "value": 51.2,
    },
    {
      "name": "Nippon India Small Cap Fund",
      "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
      "value": 46.8,
    },
    {
      "name": "SBI Small Cap Fund",
      "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
      "value": 41.5,
    },
    {
      "name": "ICICI Prudential Technology Fund",
      "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
      "value": 43.1,
    },
    {
      "name": "HDFC Mid-Cap Opportunities Fund",
      "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
      "value": 38.7,
    },
    {
      "name": "Axis Small Cap Fund",
      "logo": "https://www.axisbank.com/images/default-source/revamp_new/logo.png",
      "value": 37.2,
    },
    {
      "name": "Motilal Oswal Midcap Fund",
      "logo": "https://www.motilaloswalmf.com/images/logo.png",
      "value": 36.4,
    },
    {
      "name": "Kotak Emerging Equity Fund",
      "logo": "https://www.kotak.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png",
      "value": 35.6,
    },
    {
      "name": "Parag Parikh Flexi Cap Fund",
      "logo": "https://www.ppfas.com/images/logo.png",
      "value": 32.8,
    },
    {
      "name": "Aditya Birla Sun Life Small Cap Fund",
      "logo": "https://www.adityabirlacapital.com/abc/abslmf/images/logo.png",
      "value": 33.5,
    },

    {
      "name": "DSP Small Cap Fund",
      "logo": "https://www.dspim.com/images/logo.png",
      "value": 29.7,
    },
    {
      "name": "L&T Emerging Businesses Fund",
      "logo": "https://www.ltfs.com/content/dam/lnt-financial-services/lnt-mutual-fund/images/logo.png",
      "value": 27.8,
    },
    {
      "name": "Sundaram Small Cap Fund",
      "logo": "https://www.sundarammutual.com/images/logo.png",
      "value": 26.5,
    },
    {
      "name": "ICICI Prudential Smallcap Fund",
      "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
      "value": 25.9,
    },
    {
      "name": "Nippon India Growth Fund",
      "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
      "value": 24.3,
    },
    {
      "name": "Kotak Small Cap Fund",
      "logo": "https://www.kotak.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png",
      "value": 23.7,
    },
    {
      "name": "Axis Midcap Fund",
      "logo": "https://www.axisbank.com/images/default-source/revamp_new/logo.png",
      "value": 22.9,
    },
    {
      "name": "Mirae Asset Emerging Bluechip Fund",
      "logo": "https://www.miraeassetmf.co.in/images/logo.png",
      "value": 21.8,
    },
    {
      "name": "HDFC Small Cap Fund",
      "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
      "value": 20.5,
    },
    {
      "name": "SBI Bluechip Fund",
      "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
      "value": 19.7,
    },
    {
      "name": "UTI Small Cap Fund",
      "logo": "https://www.utimf.com/content/dam/uti/images/logo.png",
      "value": 18.9,
    },
    {
      "name": "L&T Midcap Fund",
      "logo": "https://www.ltfs.com/content/dam/lnt-financial-services/lnt-mutual-fund/images/logo.png",
      "value": 17.6,
    },
    {
      "name": "DSP Midcap Fund",
      "logo": "https://www.dspim.com/images/logo.png",
      "value": 16.8,
    },
    {
      "name": "ICICI Prudential Midcap Fund",
      "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
      "value": 16.2,
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
