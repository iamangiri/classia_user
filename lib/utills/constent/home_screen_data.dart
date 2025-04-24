import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreenData {
  static final List<String> sliderImages = [
    'https://i.ytimg.com/vi/oU9Xq9rdRVg/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBMlvA48DeFnUOB8TEiEceFiMJHjA',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
  ];

  static final List<Map<String, String>> mutualFunds = [
    {
      'name': 'SBI Bluechip Fund',
      'logo': 'https://www.sbimf.com/Assets/images/sbi-mf-logo.svg'
    },
    {
      'name': 'HDFC Equity Fund',
      'logo': 'https://www.hdfcfund.com/images/logo.png'
    },
    {
      'name': 'ICICI Prudential Fund',
      'logo': 'https://www.icicipruamc.com/images/ipru-logo.png'
    },
    {
      'name': 'Axis Long Term Equity',
      'logo': 'https://www.axismf.com/images/logo.svg'
    },
    {
      'name': 'Kotak Standard Multicap',
      'logo': 'https://www.kotakmutual.com/images/logo.png'
    },
    {
      'name': 'Mirae Asset Emerging',
      'logo': 'https://miraeassetmf.co.in/images/mirae-asset-logo.png'
    },
    {
      'name': 'UTI Nifty Index Fund',
      'logo': 'https://www.utimf.com/Images/UTI_Mutual_Fund.svg'
    },
    {
      'name': 'DSP Tax Saver Fund',
      'logo': 'https://www.dspim.com/images/dsp-logo.svg'
    },
    {
      'name': 'Aditya Birla Sun Life',
      'logo': 'https://mutualfund.adityabirlacapital.com/images/absl-logo.png'
    },
    {
      'name': 'Tata Equity P/E Fund',
      'logo': 'https://www.tatamutualfund.com/images/tata-mf-logo.png'
    },
  ];

  static final List<Map<String, dynamic>> features = [
    {'title': 'Withdraw',     'icon': FontAwesomeIcons.wallet},
    {'title': 'Deposit',      'icon': FontAwesomeIcons.moneyBillWave},
    {'title': 'History',      'icon': FontAwesomeIcons.listAlt},
    {'title': 'Market News',  'icon': FontAwesomeIcons.newspaper},
    {'title': 'Invest',       'icon': FontAwesomeIcons.chartLine},
    {'title': 'Trending',     'icon': FontAwesomeIcons.fire},
  ];

  static final List<Map<String, String>> trendingFunds = [
    {
      'symbol': 'HDFC',
      'company': 'HDFC Equity Fund',
      'logo': 'https://www.hdfcfund.com/images/logo.png',
      'price': '124.75',
      'change': '+0.95%'
    },
    {
      'symbol': 'ICICI',
      'company': 'ICICI Prudential Fund',
      'logo': 'https://www.icicipruamc.com/images/ipru-logo.png',
      'price': '98.20',
      'change': '-0.45%'
    },
    {
      'symbol': 'AXIS',
      'company': 'Axis Long Term Equity',
      'logo': 'https://www.axismf.com/images/logo.svg',
      'price': '210.30',
      'change': '+1.15%'
    },
  ];
}
