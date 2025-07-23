import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreenData {
  static final List<String> sliderImages = [
    "assets/images/slider-1.jpeg",
    "assets/images/slider-2.jpeg",
    "assets/images/slider-3.jpeg"
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
    {
      'title': 'Launchpad',
      'icon': FontAwesomeIcons.rocket,
      'color': Color(0xFFE91E63), // pink
    },
    {
      'title': 'Learn',
      'icon': FontAwesomeIcons.graduationCap,
      'color': Color(0xFF9C27B0), // purple
    },
    {
      'title': 'Market News',
      'icon': FontAwesomeIcons.newspaper,
      'color': Color(0xFF3F51B5), // indigo
    },
    {
      'title': 'Deposit',
      'icon': FontAwesomeIcons.moneyBillWave,
      'color': Color(0xFF4CAF50), // green
    },
    {
      'title': 'Withdraw',
      'icon': FontAwesomeIcons.wallet,
      'color': Color(0xFFFF9800), // orange
    },

  ];



  static List<Map<String, String>> trendingFunds = [
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
}
