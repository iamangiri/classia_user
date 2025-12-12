import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../service/apiservice/stock_market_service.dart';
import '../../utills/themes/light_app_theme.dart';
import '../main/profile_screen.dart';
import 'market_stock_chart_screen.dart';


class MarketScreen extends StatefulWidget {
  final bool showBackButton;

  const MarketScreen({
    Key? key,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketApiService _api = MarketApiService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _stocks = [];
  List<Map<String, dynamic>> _filteredStocks = [];
  Timer? _debounce;
  bool _isLoadingStocks = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadStocks();
    _searchCtrl.addListener(_filterStocks);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadStocks() async {
    setState(() => _isLoadingStocks = true);
    try {
      final stocks = await _api.fetchStocks(page: _currentPage, limit: 50);
      setState(() {
        _stocks = stocks;
        _filteredStocks = stocks;
        _isLoadingStocks = false;
      });
    } catch (e) {
      setState(() => _isLoadingStocks = false);
      _showSnackBar('Error loading stocks: $e', isError: true);
    }
  }

  void _filterStocks() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _searchCtrl.text.trim();

      if (query.isEmpty) {
        await _loadStocks();
      } else {
        setState(() => _isLoadingStocks = true);
        try {
          final stocks = await _api.fetchStocks(
            page: _currentPage,
            limit: 50,
            search: query,
          );
          setState(() {
            _stocks = stocks;
            _filteredStocks = stocks;
            _isLoadingStocks = false;
          });
        } catch (e) {
          setState(() => _isLoadingStocks = false);
          _showSnackBar('Error searching stocks: $e', isError: true);
        }
      }
    });
  }

  void _navigateToChart(Map<String, dynamic> stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketStockChartScreen(
          exchange: stock['exchange'] ?? 'NSE',
          symbol: stock['symbol'] ?? '',
          stockName: stock['fullName'] ?? stock['name'] ?? 'Unknown',
          stockLogo: stock['logo'] ?? '📈',
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: widget.showBackButton
            ? IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        )
            : IconButton(
          icon: FaIcon(FontAwesomeIcons.userCircle,
              color: Colors.white, size: 22),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        title: Text(
          "Market Stocks",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),

      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by name or symbol',
                prefixIcon:
                Icon(Icons.search, color: AppTheme.lightTheme.primaryColor),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _filterStocks();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide:
                  BorderSide(color: AppTheme.lightTheme.primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Stock List
          Expanded(
            child: _isLoadingStocks
                ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.primaryColor,
              ),
            )
                : _filteredStocks.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadStocks,
              color: AppTheme.lightTheme.primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _filteredStocks.length,
                itemBuilder: (context, index) {
                  return _buildStockCard(_filteredStocks[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80.w,
            color: AppTheme.lightTheme.primaryColor.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No stocks found',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_searchCtrl.text.isNotEmpty) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                _searchCtrl.clear();
                _filterStocks();
              },
              child: Text(
                'Clear search',
                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    final name = stock['fullName'] ?? stock['name'] ?? 'Unknown';
    final symbol = stock['symbol'] ?? '';
    final exchange = stock['exchange'] ?? 'NSE';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 2,
      shadowColor: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
      child: InkWell(
        onTap: () => _navigateToChart(stock),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              // Leading Icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: AppTheme.lightTheme.primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 16.w),

              // Stock Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          symbol,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            exchange,
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Trailing Arrow
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}