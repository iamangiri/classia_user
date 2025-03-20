import 'package:flutter/material.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // Default topics data
  final List<Map<String, dynamic>> topics = [
    {
      'title': 'Stock Market Trading',
      'progress': 0.0,
      'color': Colors.deepPurple,
      'details': {
        'difficulty': 'Intermediate',
        'description': 'Learn the fundamentals of stock market trading including technical analysis, portfolio management, and risk management.',
        'keyPoints': [
          'Technical Analysis',
          'Fundamental Analysis',
          'Risk Management',
          'Portfolio Management'
        ],
        'example': 'Example: Analyzing a company’s balance sheet to determine its investment potential.',
        'strategies': [
          'Attend webinars',
          'Practice trading on simulators',
          'Follow market news'
        ],
        'form': {
          'fields': [
            {'label': 'Folio Number', 'hint': 'Enter your folio number'},
            {'label': 'Broker Name', 'hint': 'Enter your broker name'},
            {'label': 'Trading Account ID', 'hint': 'Enter your trading account ID'},
            {'label': 'Risk Tolerance', 'hint': 'e.g., Conservative, Moderate, Aggressive'},
            {'label': 'Investment Amount', 'hint': 'Enter the amount to invest'},
            {'label': 'Preferred Market', 'hint': 'e.g., NSE, BSE, NYSE, NASDAQ'},
          ]
        }
      }
    },
    {
      'title': 'Forex Trading Basics',
      'progress': 0.2,
      'color': Colors.teal,
      'details': {
        'difficulty': 'Beginner',
        'description': 'An introduction to Forex trading covering currency pairs, pips, and leverage.',
        'keyPoints': ['Currency Pairs', 'Pips', 'Leverage'],
        'example': 'Example: Understanding the EUR/USD currency pair movements.',
        'strategies': [
          'Demo trading',
          'Monitor economic indicators',
          'Follow global news'
        ],
        'form': {
          'fields': [
            {'label': 'Trading Account ID', 'hint': 'Enter your Forex account ID'},
            {'label': 'Broker Name', 'hint': 'Enter your broker name'},
            {'label': 'Preferred Leverage', 'hint': 'e.g., 50:1, 100:1'},
            {'label': 'Investment Amount', 'hint': 'Enter the amount for Forex trading'},
          ]
        }
      }
    },
    {
      'title': 'Cryptocurrency Trading',
      'progress': 0.4,
      'color': Colors.amber,
      'details': {
        'difficulty': 'Intermediate',
        'description': 'Learn how to trade cryptocurrencies, analyze trends, and manage risks in the crypto markets.',
        'keyPoints': ['Bitcoin', 'Ethereum', 'Altcoins', 'Technical Indicators'],
        'example': 'Example: Using RSI and MACD to analyze Bitcoin price movements.',
        'strategies': [
          'Stay updated with crypto news',
          'Use demo accounts',
          'Diversify your portfolio'
        ],
        'form': {
          'fields': [
            {'label': 'Wallet Address', 'hint': 'Enter your crypto wallet address'},
            {'label': 'Exchange Name', 'hint': 'Enter your preferred crypto exchange'},
            {'label': 'Investment Amount', 'hint': 'Enter the amount for crypto trading'},
            {'label': 'Risk Tolerance', 'hint': 'e.g., Low, Medium, High'},
          ]
        }
      }
    },
  ];


  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  Map<String, bool> _bookmarks = {};
  Map<String, double> _progress = {};

  @override
  void initState() {
    super.initState();
    // Initialize progress and bookmarks for each topic using default data
    for (var topic in topics) {
      _progress[topic['title']] = topic['progress'];
      _bookmarks[topic['title']] = false;
    }
  }

  List<Map<String, dynamic>> get _filteredTopics {
    return topics.where((topic) {
      final matchesSearch = topic['title']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          topic['details']['difficulty'] == _selectedDifficulty;
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _buildSearchField(),
        actions: [_buildFilterButton()],
      ),
      body: Column(
        children: [
          _buildDifficultyFilter(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _buildProgressFab(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search topics...',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, color: Colors.grey),
          onPressed: () => setState(() => _searchQuery = ''),
        ),
      ),
      style: TextStyle(color: Colors.white),
      onChanged: (value) => setState(() => _searchQuery = value),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedDifficulty = value),
      itemBuilder: (context) => ['All', 'Beginner', 'Intermediate', 'Advanced']
          .map((level) => PopupMenuItem(
        value: level,
        child: Text(level, style: TextStyle(color: Colors.white)),
      ))
          .toList(),
      icon: Icon(Icons.filter_list, color: Colors.white),
    );
  }

  Widget _buildDifficultyFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map((level) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(level),
              selected: _selectedDifficulty == level,
              selectedColor: Colors.tealAccent,
              labelStyle: TextStyle(
                color:
                _selectedDifficulty == level ? Colors.black : Colors.black,
              ),
              onSelected: (selected) =>
                  setState(() => _selectedDifficulty = selected ? level : 'All'),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 60, color: Colors.grey[700]),
            SizedBox(height: 16),
            Text('No topics found',
                style: TextStyle(color: Colors.grey[500], fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) =>
          _buildTopicCard(_filteredTopics[index]),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
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
        onTap: () => _navigateToDetail(topic),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildProgressIndicator(topic),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(topic['title'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            _buildDifficultyBadge(topic['details']['difficulty']),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _bookmarks[topic['title']]!
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Colors.tealAccent,
                        ),
                        onPressed: () => setState(() => _bookmarks[topic['title']] =
                        !_bookmarks[topic['title']]!),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(topic['details']['description'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  SizedBox(height: 12),
                  _buildKeyPointsPreview(topic['details']['keyPoints']),
                ],
              ),
            ),
            if (_progress[topic['title']]! >= 1.0)
              Positioned(
                right: -24,
                top: -24,
                child: Icon(Icons.check_circle,
                    color: Colors.tealAccent, size: 48),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> topic) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: _progress[topic['title']],
            strokeWidth: 4,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
          ),
        ),
        Text(
          '${(_progress[topic['title']]! * 100).toInt()}%',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Beginner':
        color = Colors.green;
        break;
      case 'Intermediate':
        color = Colors.orange;
        break;
      case 'Advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(difficulty,
          style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildKeyPointsPreview(List<String> keyPoints) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: keyPoints.take(3).map((point) => Chip(
        label: Text(point,
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        backgroundColor: Colors.grey[800],
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      )).toList(),
    );
  }

  Widget _buildProgressFab() {
    final totalProgress = _progress.values
        .fold(0.0, (sum, progress) => sum + progress) / _progress.length;

    return FloatingActionButton(
      backgroundColor: Colors.tealAccent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: totalProgress,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          Text('${(totalProgress * 100).toInt()}%',
              style: TextStyle(color: Colors.black)),
        ],
      ),
      onPressed: () => _showOverallProgress(),
    );
  }

  void _showOverallProgress() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Learning Progress',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(height: 16),
            ...topics.map((topic) => ListTile(
              title: Text(topic['title'],
                  style: TextStyle(color: Colors.white)),
              subtitle: LinearProgressIndicator(
                value: _progress[topic['title']],
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(topic['color']),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> topic) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => LearnDetailsScreen(
          topic: topic,
          onProgressUpdate: (newProgress) => setState(
                  () => _progress[topic['title']] = newProgress),
          isBookmarked: _bookmarks[topic['title']]!,
          onBookmarkToggle: () => setState(
                  () => _bookmarks[topic['title']] = !_bookmarks[topic['title']]!),
        ),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class LearnDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> topic;
  final Function(double) onProgressUpdate;
  final bool isBookmarked;
  final Function() onBookmarkToggle;

  const LearnDetailsScreen({
    required this.topic,
    required this.onProgressUpdate,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  _LearnDetailsScreenState createState() => _LearnDetailsScreenState();
}

class _LearnDetailsScreenState extends State<LearnDetailsScreen> {
  late double _currentProgress;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.topic['progress'];
  }

  void _updateProgress(double newProgress) {
    setState(() => _currentProgress = newProgress.clamp(0.0, 1.0));
    widget.onProgressUpdate(newProgress);
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.topic['details'];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.topic['title'],
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.tealAccent),
            onPressed: widget.onBookmarkToggle,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressSlider(),
            _buildSection('📘 Overview', Text(details['description'], style: TextStyle(color: Colors.white))),
            _buildSection('🎯 Key Concepts', _buildKeyPoints(details['keyPoints'])),
            _buildSection('💡 Example', _buildExampleCard(details['example'])),
            _buildSection('📈 Strategies', _buildStrategies(details['strategies'])),
            _buildQuizButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSlider() {
    return Column(
      children: [
        Slider(
          value: _currentProgress,
          min: 0,
          max: 1,
          divisions: 10,
          label: '${(_currentProgress * 100).round()}%',
          activeColor: Colors.tealAccent,
          inactiveColor: Colors.grey[800],
          onChanged: _updateProgress,
        ),
        Text('Adjust your progress', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildKeyPoints(List<String> points) {
    return Column(
      children: points
          .map((point) => ListTile(
        leading: Icon(Icons.circle, size: 8, color: Colors.tealAccent),
        title: Text(point, style: TextStyle(color: Colors.white70)),
      ))
          .toList(),
    );
  }

  Widget _buildExampleCard(String example) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber, size: 40),
            SizedBox(height: 16),
            Text(example,
                style: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategies(List<String> strategies) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: strategies
          .map((strategy) => Chip(
        label: Text(strategy,
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[800],
        avatar: Icon(Icons.star, size: 18, color: Colors.tealAccent),
      ))
          .toList(),
    );
  }

  Widget _buildQuizButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(Icons.quiz, color: Colors.white),
        label: Text('Start Quiz', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: () => _startQuiz(),
      ),
    );
  }

  void _startQuiz() {
    // Implement quiz functionality
  }
}
