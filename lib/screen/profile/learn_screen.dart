import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  final List<Map<String, dynamic>> topics = [
    {
      'title': 'Basics of Stock Market',
      'icon': Icons.bar_chart,
      'progress': 0.8,
      'color': Colors.blue,
      'details': {
        'description': 'Understand the fundamental concepts of stock market operations.',
        'keyPoints': [
          'What are stocks and shares?',
          'Market participants explained',
          'Order types (Market, Limit, Stop)',
          'Bull vs Bear markets'
        ],
        'example': 'Example: How IPO works',
        'strategies': ['Long-term investing', 'Dollar-cost averaging'],
        'difficulty': 'Beginner'
      }
    },
    {
      'title': 'Technical Analysis',
      'icon': Icons.trending_up,
      'progress': 0.6,
      'color': Colors.green,
      'details': {
        'description': 'Master chart patterns and technical indicators.',
        'keyPoints': [
          'Candlestick patterns',
          'Support & Resistance levels',
          'Moving averages',
          'RSI and MACD indicators'
        ],
        'example': 'Identifying head & shoulders pattern',
        'strategies': ['Swing trading', 'Day trading setups'],
        'difficulty': 'Intermediate'
      }
    },
    // Add other topics similarly
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Learn Trading',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return _buildTopicCard(context, topic);
        },
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, Map<String, dynamic> topic) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[900]!, Colors.grey[850]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, topic),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
          children: [
          Icon(topic['icon'], color: topic['color'], size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(topic['title'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)
            ),
          ),

            Chip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    topic['details']['difficulty'],
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            )

          ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: topic['progress'],
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
            minHeight: 4,
          ),
          SizedBox(height: 8),
          Text(topic['details']['description'],
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ],
        ),
      ),
    ),
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> topic) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LearnDetailsScreen(topic: topic),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class LearnDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> topic;

  const LearnDetailsScreen({required this.topic});

  @override
  Widget build(BuildContext context) {
    final details = topic['details'];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(topic['title'],
            style: TextStyle(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('About this Topic'),
            Text(details['description'],
                style: TextStyle(color: Colors.white70, fontSize: 16)),

            SizedBox(height: 24),
            _buildSectionHeader('Key Concepts'),
            ...details['keyPoints'].map((point) =>
                _buildBulletPoint(point)),

            SizedBox(height: 24),
            _buildSectionHeader('Example Scenario'),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(details['example'],
                  style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
            ),

            SizedBox(height: 24),
            _buildSectionHeader('Common Strategies'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: details['strategies'].map<Widget>((strategy) =>
                  Chip(
                    label: Text(strategy,
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.grey[800],
                  )
              ).toList(),
            ),

            SizedBox(height: 24),
            _buildSectionHeader('Learning Progress'),
            LinearProgressIndicator(
              value: topic['progress'],
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
              minHeight: 8,
            ),

            SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.quiz, color: Colors.white),
                label: Text('Take Quiz',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 8, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ),
        ],
      )

    );
  }
}