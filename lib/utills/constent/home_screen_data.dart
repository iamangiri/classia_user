import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreenData {
  static final List<String> sliderImages = [
    'https://i.ytimg.com/vi/oU9Xq9rdRVg/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBMlvA48DeFnUOB8TEiEceFiMJHjA',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
  ];



  static List<Map<String, String>> mutualFunds = [
    {
      'logo': 'https://via.placeholder.com/50',
      'name': 'SBI Bluechip Fund',
      'symbol': 'SBI',
      'company': 'SBI Mutual Fund',
      'price': '1800.00',
      'change': '+3.5%',
    },
    {
      'logo': 'https://via.placeholder.com/50',
      'name': 'Axis Midcap Fund',
      'symbol': 'AXIS',
      'company': 'Axis Mutual Fund',
      'price': '1400.00',
      'change': '-1.8%',
    },
    {
      'logo': 'https://via.placeholder.com/50',
      'name': 'Mirae Asset Fund',
      'symbol': 'MIRAE',
      'company': 'Mirae Asset',
      'price': '1600.00',
      'change': '+4.2%',
    },
    {
      'logo': 'https://via.placeholder.com/50',
      'name': 'Kotak Equity Fund',
      'symbol': 'KOTAK',
      'company': 'Kotak Mahindra',
      'price': '1300.00',
      'change': '-0.9%',
    },
  ];

  static final List<Map<String, dynamic>> features = [
    {'title': 'Launchpad',    'icon': FontAwesomeIcons.rocket},
    {'title': 'Market News',  'icon': FontAwesomeIcons.newspaper},
    {'title': 'Deposit',      'icon': FontAwesomeIcons.moneyBillWave},
    {'title': 'Withdraw',     'icon': FontAwesomeIcons.wallet},
    {'title': 'Learn',        'icon': FontAwesomeIcons.graduationCap},
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
