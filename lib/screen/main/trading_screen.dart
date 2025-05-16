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
      "name": "HDFC Mutual Fund",
      "logo": "https://upload.wikimedia.org/wikipedia/commons/7/70/HDFC_Bank_Logo.svg",
      "value": 6.8,
    },
    {
      "name": "SBI Mutual Fund",
      "logo": "https://www.sbimf.com/images/default-source/default-album/sbi-mutual-fund-logo.png",
      "value": 9.1,
    },
    {
      "name": "ICICI Prudential Mutual Fund",
      "logo": "https://www.icicipruamc.com/docs/default-source/default-document-library/icici-pru-logo.jpg",
      "value": 4.7,
    },
    {
      "name": "Nippon India Mutual Fund",
      "logo": "https://www.nipponindiamf.com/assets/images/niam-logo.png",
      "value": -1.6,
    },
    {
      "name": "Axis Mutual Fund",
      "logo": "https://www.axisbank.com/images/default-source/revamp_new/logo.png",
      "value": 3.2,
    },
    {
      "name": "Kotak Mahindra Mutual Fund",
      "logo": "https://www.kotak.com/etc.clientlibs/kotak/clientlibs/clientlib-base/resources/images/kotak-logo.png",
      "value": 2.5,
    },
    {
      "name": "Aditya Birla Sun Life Mutual Fund",
      "logo": "https://www.adityabirlacapital.com/abc/abslmf/images/logo.png",
      "value": 5.0,
    },
    {
      "name": "Franklin Templeton Mutual Fund",
      "logo": "https://www.franklintempleton.com/etc/designs/franklintempleton/clientlibs/clientlib-site/resources/images/logo.svg",
      "value": -0.8,
    },
    {
      "name": "UTI Mutual Fund",
      "logo": "https://www.utimf.com/content/dam/uti/images/logo.png",
      "value": 1.9,
    },
    {
      "name": "Mirae Asset Mutual Fund",
      "logo": "https://www.miraeassetmf.co.in/images/logo.png",
      "value": 4.3,
    },
    {
      "name": "Tata Mutual Fund",
      "logo": "https://www.tatamutualfund.com/images/logo.png",
      "value": 2.7,
    },
    {
      "name": "DSP Mutual Fund",
      "logo": "https://www.dspim.com/images/logo.png",
      "value": 3.6,
    },
    {
      "name": "Canara Robeco Mutual Fund",
      "logo": "https://www.canararobeco.com/images/logo.png",
      "value": 2.1,
    },
    {
      "name": "Edelweiss Mutual Fund",
      "logo": "https://www.edelweissmf.com/images/logo.png",
      "value": 1.4,
    },
    {
      "name": "Invesco Mutual Fund",
      "logo": "https://www.invescomutualfund.com/images/logo.png",
      "value": 2.9,
    },
    {
      "name": "IDBI Mutual Fund",
      "logo": "https://www.idbimutual.co.in/images/logo.png",
      "value": -1.2,
    },
    {
      "name": "LIC Mutual Fund",
      "logo": "https://www.licmf.com/images/logo.png",
      "value": 0.5,
    },
    {
      "name": "Motilal Oswal Mutual Fund",
      "logo": "https://www.motilaloswalmf.com/images/logo.png",
      "value": 3.8,
    },
    {
      "name": "Quantum Mutual Fund",
      "logo": "https://www.quantumamc.com/images/logo.png",
      "value": 1.0,
    },
    {
      "name": "Sundaram Mutual Fund",
      "logo": "https://www.sundarammutual.com/images/logo.png",
      "value": 2.6,
    },
    {
      "name": "PGIM India Mutual Fund",
      "logo": "https://www.pgimindiamf.com/images/logo.png",
      "value": 3.0,
    },
    {
      "name": "PPFAS Mutual Fund",
      "logo": "https://www.ppfas.com/images/logo.png",
      "value": 4.1,
    },
    {
      "name": "Mahindra Manulife Mutual Fund",
      "logo": "https://www.mahindramanulife.com/images/logo.png",
      "value": 1.7,
    },
    {
      "name": "Union Mutual Fund",
      "logo": "https://www.unionmf.com/images/logo.png",
      "value": 0.9,
    },
    {
      "name": "Baroda BNP Paribas Mutual Fund",
      "logo": "https://www.barodabnpparibasmf.in/images/logo.png",
      "value": 2.3,
    },
    {
      "name": "Bank of India Mutual Fund",
      "logo": "https://www.boimf.in/images/logo.png",
      "value": -0.5,
    },
    {
      "name": "Quant Mutual Fund",
      "logo": "https://www.quantmutual.com/images/logo.png",
      "value": 5.5,
    },
    {
      "name": "Groww Mutual Fund",
      "logo": "https://groww.in/images/logo.png",
      "value": 3.9,
    },
    {
      "name": "Navi Mutual Fund",
      "logo": "https://navi.com/images/logo.png",
      "value": 2.0,
    },
    {
      "name": "Samco Mutual Fund",
      "logo": "https://www.samcomf.com/images/logo.png",
      "value": 1.8,
    },
    {
      "name": "WhiteOak Capital Mutual Fund",
      "logo": "https://www.whiteoakcapitalmf.com/images/logo.png",
      "value": 2.4,
    },
    {
      "name": "Zerodha Mutual Fund",
      "logo": "https://zerodha.com/images/logo.png",
      "value": 3.3,
    },
    {
      "name": "Bajaj Finserv Mutual Fund",
      "logo": "https://www.bajajfinserv.in/images/logo.png",
      "value": 2.2,
    },
    {
      "name": "NJ Mutual Fund",
      "logo": "https://www.njmutualfund.com/images/logo.png",
      "value": 1.6,
    },
    {
      "name": "Helios Mutual Fund",
      "logo": "https://www.heliosmf.com/images/logo.png",
      "value": 2.8,
    },
    {
      "name": "Old Bridge Mutual Fund",
      "logo": "https://www.oldbridgemf.com/images/logo.png",
      "value": 1.3,
    },
    {
      "name": "Trust Mutual Fund",
      "logo": "https://www.trustmf.com/images/logo.png",
      "value": 0.7,
    },
    {
      "name": "ITI Mutual Fund",
      "logo": "https://www.itimf.com/images/logo.png",
      "value": 1.9,
    },
    {
      "name": "JM Financial Mutual Fund",
      "logo": "https://www.jmfinancialmf.com/images/logo.png",
      "value": 2.1,
    },
    {
      "name": "HSBC Mutual Fund",
      "logo": "https://www.assetmanagement.hsbc.co.in/images/logo.png",
      "value": 3.4,
    },
    {
      "name": "360 ONE Mutual Fund",
      "logo": "https://www.360onemf.com/images/logo.png",
      "value": 2.6,
    },
    {
      "name": "Bandhan Mutual Fund",
      "logo": "https://www.bandhanmutual.com/images/logo.png",
      "value": 1.5,
    },
    {
      "name": "Shriram Mutual Fund",
      "logo": "https://www.shrirammf.com/images/logo.png",
      "value": 0.6,
    },
    {
      "name": "Taurus Mutual Fund",
      "logo": "https://www.taurusmutualfund.com/images/logo.png",
      "value": -0.3,
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
