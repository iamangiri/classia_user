import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Data models
class MarketNewsResponse {
  final Meta meta;
  final List<NewsData> data;

  MarketNewsResponse({required this.meta, required this.data});

  factory MarketNewsResponse.fromJson(Map<String, dynamic> json) {
    return MarketNewsResponse(
      meta: Meta.fromJson(json['meta']),
      data: (json['data'] as List)
          .map((item) => NewsData.fromJson(item))
          .toList(),
    );
  }
}

class Meta {
  final int found;
  final int returned;
  final int limit;
  final int page;

  Meta({required this.found, required this.returned, required this.limit, required this.page});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      found: json['found'],
      returned: json['returned'],
      limit: json['limit'],
      page: json['page'],
    );
  }
}

class NewsData {
  final String uuid;
  final String title;
  final String description;
  final String snippet;
  final String url;
  final String? imageUrl;
  final String language;
  final DateTime publishedAt;
  final String source;
  final List<Entity> entities;

  NewsData({
    required this.uuid,
    required this.title,
    required this.description,
    required this.snippet,
    required this.url,
    this.imageUrl,
    required this.language,
    required this.publishedAt,
    required this.source,
    required this.entities,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      uuid: json['uuid'],
      title: json['title'],
      description: json['description'],
      snippet: json['snippet'],
      url: json['url'],
      imageUrl: json['image_url'],
      language: json['language'],
      publishedAt: DateTime.parse(json['published_at']),
      source: json['source'],
      entities: (json['entities'] as List?)
          ?.map((item) => Entity.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Entity {
  final String symbol;
  final String name;
  final String? exchange;
  final String country;
  final String type;
  final String? industry;
  final double sentimentScore;

  Entity({
    required this.symbol,
    required this.name,
    this.exchange,
    required this.country,
    required this.type,
    this.industry,
    required this.sentimentScore,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      symbol: json['symbol'],
      name: json['name'],
      exchange: json['exchange'],
      country: json['country'],
      type: json['type'],
      industry: json['industry'],
      sentimentScore: (json['sentiment_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// API Service
class MarketAuxService {
  static const String baseUrl = 'https://api.marketaux.com/v1';
  static const String apiToken = 'IPPUEt7mAwb8r8EVXW1nPS5dIhYCGy7NTvcPvriT';

  static Future<MarketNewsResponse> fetchNews({
    String entityTypes = 'index,equity',
    String language = 'en',
    int limit = 10,
    int page = 1,
  }) async {
    final url = Uri.parse(
      '$baseUrl/news/all?entity_types=$entityTypes&language=$language&limit=$limit&page=$page&api_token=$apiToken',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MarketNewsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}

// Main Market Screen
class MarketNewsScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketNewsScreen> {
  late Future<MarketNewsResponse> _newsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _newsFuture = MarketAuxService.fetchNews();
  }

  void _refreshNews() {
    setState(() {
      _newsFuture = MarketAuxService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Market News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshNews,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh News',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[900]!,
              Colors.blueGrey[800]!,
              Colors.blueGrey[700]!,
            ],
          ),
        ),
        child: FutureBuilder<MarketNewsResponse>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading market news...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error loading news',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshNews,
                      child: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No news available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            final newsResponse = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _refreshNews();
              },
              child: Column(
                children: [
                  // Stats Header
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Total Found', newsResponse.meta.found),
                        _buildStatCard('Showing', newsResponse.meta.returned),
                        _buildStatCard('Page', newsResponse.meta.page),
                      ],
                    ),
                  ),

                  // News List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: newsResponse.data.length,
                      itemBuilder: (context, index) {
                        final news = newsResponse.data[index];
                        return NewsCard(news: news);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// News Card Widget
class NewsCard extends StatelessWidget {
  final NewsData news;

  const NewsCard({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (news.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  news.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Description
                  Text(
                    news.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),

                  // Entities (Stocks)
                  if (news.entities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: news.entities.take(3).map((entity) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getSentimentColor(entity.sentimentScore),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            entity.symbol,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 12),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.source,
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm').format(news.publishedAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _launchURL(context, news.url),
                        icon: Icon(
                          Icons.open_in_new,
                          color: Colors.blue[600],
                        ),
                        tooltip: 'Read full article',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSentimentColor(double sentiment) {
    if (sentiment > 0.6) return Colors.green;
    if (sentiment > 0.4) return Colors.orange;
    return Colors.red;
  }

  void _launchURL(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Show a fallback dialog if URL can't be launched
        _showUrlDialog(context, url);
      }
    } catch (e) {
      // Handle any errors and show fallback dialog
      _showUrlDialog(context, url);
    }
  }

  void _showUrlDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Open Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unable to open the link automatically.'),
              SizedBox(height: 8),
              Text('URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              SelectableText(
                url,
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try again with different launch mode
                _tryAlternativeLaunch(url);
              },
              child: Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _tryAlternativeLaunch(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      // Try different launch modes
      List<LaunchMode> modes = [
        LaunchMode.externalApplication,
        LaunchMode.platformDefault,
        LaunchMode.inAppWebView,
      ];

      for (LaunchMode mode in modes) {
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: mode);
            break;
          }
        } catch (e) {
          // Continue to next mode
          continue;
        }
      }
    } catch (e) {
      // All attempts failed
      print('Failed to launch URL: $e');
    }
  }
}