import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../themes/app_colors.dart';

// Data models (unchanged)
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

// API Service (unchanged)
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

// Main Market News Screen
class MarketNewsScreen extends StatefulWidget {
  const MarketNewsScreen({super.key});

  @override
  _MarketNewsScreenState createState() => _MarketNewsScreenState();
}

class _MarketNewsScreenState extends State<MarketNewsScreen> with TickerProviderStateMixin {
  late Future<MarketNewsResponse> _newsFuture;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _newsFuture = MarketAuxService.fetchNews();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _refreshNews() {
    setState(() {
      _newsFuture = MarketAuxService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CommonAppBar(title: 'Market News'),
      // appBar: AppBar(
      //   title: ShaderMask(
      //     shaderCallback: (bounds) => LinearGradient(
      //       colors: [
      //         AppColors.primaryColor ?? Colors.blue,
      //         AppColors.primaryGold ?? const Color(0xFFDAA520),
      //       ],
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ).createShader(bounds),
      //     child: Text(
      //       'Market News',
      //       style: TextStyle(
      //         fontSize: 20.sp,
      //         fontWeight: FontWeight.bold,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      //   backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.cardBackground,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       onPressed: _refreshNews,
      //       icon: Icon(Icons.refresh),
      //       tooltip: 'Refresh News',
      //       color: AppColors.primaryGold ?? const Color(0xFFDAA520),
      //     ),
      //   ],
      // ),
      body: Container(

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: FutureBuilder<MarketNewsResponse>(
            future: _newsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGold ?? const Color(0xFFDAA520),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading market news...',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : AppColors.secondaryText,
                          fontSize: 16.sp,
                        ),
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
                        color: AppColors.error ?? Colors.red,
                        size: 64.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Error loading news',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.primaryText,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : AppColors.secondaryText,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTapDown: (_) => setState(() {}),
                        onTapUp: (_) {
                          setState(() {});
                          _refreshNews();
                        },
                        onTapCancel: () => setState(() {}),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGold ?? const Color(0xFFDAA520),
                                AppColors.primaryColor?.withOpacity(0.8) ?? Colors.blue.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: AppColors.buttonText ?? Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                        color: isDarkMode ? Colors.white54 : AppColors.secondaryText,
                        size: 64.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No news available',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.primaryText,
                          fontSize: 18.sp,
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
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: newsResponse.data.length,
                  itemBuilder: (context, index) {
                    final news = newsResponse.data[index];
                    return NewsCard(news: news);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// News Card Widget
class NewsCard extends StatefulWidget {
  final NewsData news;

  const NewsCard({Key? key, required this.news}) : super(key: key);

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isTapped = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isTapped = true),
          onTapUp: (_) => setState(() => _isTapped = false),
          onTapCancel: () => setState(() => _isTapped = false),
          onTap: () => _launchURL(context, widget.news.url),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isTapped ? 0.95 : 1.0),
            constraints: BoxConstraints(minHeight: 300.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                  const Color(0xFF1E1E1E).withOpacity(0.9),
                  const Color(0xFF2D2D2D).withOpacity(0.7),
                ]
                    : [
                  AppColors.cardBackground?.withOpacity(0.9) ?? const Color(0xFFF5F5F5).withOpacity(0.9),
                  AppColors.cardBackground?.withOpacity(0.7) ?? const Color(0xFFF5F5F5).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _isHovered
                    ? (AppColors.primaryGold?.withOpacity(0.6) ?? const Color(0xFFDAA520).withOpacity(0.6))
                    : (AppColors.primaryGold?.withOpacity(0.2) ?? const Color(0xFFDAA520).withOpacity(0.2)),
                width: 1.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                  blurRadius: (_isHovered ? 12 : 6).r,
                  offset: Offset(0, (_isHovered ? 4 : 2).h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (widget.news.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                        child: Image.network(
                          widget.news.imageUrl!,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180.h,
                              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50.sp,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            widget.news.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor ?? Colors.blue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),


                          SizedBox(height: 8.h),

                          // Divider
                          Container(
                            height: 2.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGold ?? const Color(0xFFDAA520),
                                  (AppColors.primaryGold ?? const Color(0xFFDAA520)).withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1.r),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Description
                          Text(
                            widget.news.description,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDarkMode ? Colors.white70 : AppColors.secondaryText,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12.h),

                          // Entities
                          if (widget.news.entities.isNotEmpty)
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 4.h,
                              children: widget.news.entities.take(3).map((entity) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getSentimentColor(entity.sentimentScore, isDarkMode),
                                        _getSentimentColor(entity.sentimentScore, isDarkMode).withOpacity(0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    entity.symbol,
                                    style: TextStyle(
                                      color: AppColors.buttonText ?? Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          SizedBox(height: 12.h),

                          // Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.news.source,
                                    style: TextStyle(
                                      color: AppColors.primaryColor ?? Colors.blue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd, yyyy • HH:mm').format(widget.news.publishedAt),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : AppColors.secondaryText,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTapDown: (_) => setState(() {}),
                                onTapUp: (_) {
                                  setState(() {});
                                  _launchURL(context, widget.news.url);
                                },
                                onTapCancel: () => setState(() {}),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color:  AppColors.primaryGold,
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6.r,
                                        offset: Offset(0, 2.h),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Read More',
                                    style: TextStyle(
                                      color: AppColors.buttonText ?? Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSentimentColor(double sentiment, bool isDarkMode) {
    if (sentiment > 0.6) return AppColors.success ?? Colors.green;
    if (sentiment > 0.4) return AppColors.warning ?? Colors.amber;
    return AppColors.error ?? Colors.red;
  }

  void _launchURL(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showUrlDialog(context, url);
      }
    } catch (e) {
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
              SizedBox(height: 8.h),
              Text('URL:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4.h),
              SelectableText(
                url,
                style: TextStyle(color: AppColors.primaryColor ?? Colors.blue),
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
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      print('Failed to launch URL: $e');
    }
  }
}