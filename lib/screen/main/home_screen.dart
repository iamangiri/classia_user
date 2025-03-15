import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:classia_amc/widget/custom_heading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  final List<String> sliderImages = [
    'https://i.ytimg.com/vi/oU9Xq9rdRVg/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBMlvA48DeFnUOB8TEiEceFiMJHjA',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
  ];
  final List<Map<String, String>> mutualFunds = [
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


  final List<Map<String, dynamic>> features = [
    {'title': 'Withdraw', 'icon': FontAwesomeIcons.wallet},
    {'title': 'Deposit', 'icon': FontAwesomeIcons.moneyBillWave},
    {'title': 'History', 'icon': FontAwesomeIcons.listAlt},
    {'title': 'Market News', 'icon': FontAwesomeIcons.newspaper},
    {'title': 'Invest', 'icon': FontAwesomeIcons.chartLine}, // New

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Mode Background
      appBar: AppBar(
        backgroundColor: Colors.black, // Dark theme app bar
        title: Text(
          'Jockey Trading',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            // 🔹 Slider with Glassmorphism Effect
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                ),
                items: sliderImages.map((image) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(image, fit: BoxFit.cover),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 20),

            // 🔹 Features Section with Horizontal List & Rounded Icons
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CustomHeading(text: 'Features', lineWidth: 40),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8), // Spacing between items
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[800], // Dark background
                            shape: BoxShape.circle, // Circular shape
                            border: Border.all(color: Colors.grey[600]!),
                          ),
                          child: FaIcon(feature['icon'], size: 28, color: Colors.white), // White icon
                        ),
                        SizedBox(height: 6),
                        Text(
                          feature['title'],
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),


            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomHeading(text: 'Top Mutual Funds', lineWidth: 40),
                  TextButton(
                    onPressed: () {},
                    child: Text('View More', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: mutualFunds.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900]!.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[700]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: mutualFunds[index]['logo']!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.black,
                              child: Icon(Icons.image, color: Colors.grey, size: 30),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            mutualFunds[index]['name']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}



