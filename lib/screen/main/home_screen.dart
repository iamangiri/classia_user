import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  final List<String> sliderImages = [
    'https://i.ytimg.com/vi/oU9Xq9rdRVg/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBMlvA48DeFnUOB8TEiEceFiMJHjA',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
    'https://www.alliedmarketresearch.com/assets/sampleimages/multiple-toe-socks-market-1691677648.png',
  ];

  final List<Map<String, String>> amcList = [
    {'name': 'BlackRock', 'logo': 'https://en.wikipedia.org/wiki/File:J_P_Morgan_Chase_Logo_2008_1.svg'},
    {'name': 'Vanguard', 'logo': 'https://en.wikipedia.org/wiki/File:J_P_Morgan_Chase_Logo_2008_1.svg'},
    {'name': 'Fidelity', 'logo': 'https://en.wikipedia.org/wiki/File:J_P_Morgan_Chase_Logo_2008_1.svg'},
    {'name': 'JP Morgan', 'logo': 'https://en.wikipedia.org/wiki/File:J_P_Morgan_Chase_Logo_2008_1.svg'},
  ];

   final List<Map<String, dynamic>> features = [
    {'title': 'Withdraw', 'icon': FontAwesomeIcons.wallet, 'color': Colors.blue},
    {'title': 'Deposit', 'icon': FontAwesomeIcons.moneyBillWave, 'color': Colors.green},
    {'title': 'History', 'icon': FontAwesomeIcons.listAlt, 'color': Colors.orange},
    {'title': 'Market News', 'icon': FontAwesomeIcons.newspaper, 'color': Colors.teal},
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A0E21),
        title: Text(
          'Jockey Trading',
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
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            // Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
              ),
              items: sliderImages.map((image) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0E21),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: features.map((feature) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: feature['color'].withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          feature['icon'],
                          size: 28,
                          color: feature['color'],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        feature['title'],
                        style: TextStyle(
                          fontSize: 14,
                          
                          color: Color(0xFF0A0E21),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // Top AMC Companies Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Top AMC Companies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:Color(0xFF0A0E21) ,
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
  child: ListView.builder(
    itemCount: amcList.length,
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemBuilder: (context, index) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white70, // Modern Gray Background
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFF0A0E21)), // Subtle Border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25,
            backgroundImage: NetworkImage(amcList[index]['logo']!),
            onBackgroundImageError: (_, __) =>
                Icon(Icons.business, color: const Color.fromARGB(255, 200, 241, 16)),
          ),
          title: Text(
            amcList[index]['name']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A0E21),
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF0A0E21)),
        ),
      );
    },
  ),
),



          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
