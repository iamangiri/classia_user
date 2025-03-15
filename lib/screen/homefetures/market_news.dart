import 'package:flutter/material.dart';

class MarketNewsScreen extends StatefulWidget {
  @override
  _MarketNewsScreenState createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Dummy data for Trade Market news
  final List<Map<String, String>> tradeMarketNews = [
    {
      "title": "Trade Market Hits New Highs",
      "date": "2025-03-01",
      "image": "https://via.placeholder.com/50"
    },
    {
      "title": "Global Markets Rally Amid Optimism",
      "date": "2025-02-28",
      "image": "https://via.placeholder.com/50"
    },
  ];

  // Dummy data for Mutual Fund news
  final List<Map<String, String>> mutualFundNews = [
    {
      "title": "Mutual Funds See Record Inflows",
      "date": "2025-03-02",
      "image": "https://via.placeholder.com/50"
    },
    {
      "title": "Top Mutual Fund Picks for Q1",
      "date": "2025-02-27",
      "image": "https://via.placeholder.com/50"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Widget _buildNewsList(List<Map<String, String>> newsList) {
    return ListView.builder(
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.grey[900]!.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: news["image"] != null
                  ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(news["image"]!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.article, color: Colors.white),
              ),
              title: Text(
                news["title"] ?? "No Title",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                news["date"] ?? "",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                // Navigate to detailed news article screen if needed.
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          "Market News",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: "Trade Market"),
            Tab(text: "Mutual Fund"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsList(tradeMarketNews),
          _buildNewsList(mutualFundNews),
        ],
      ),
    );
  }
}
