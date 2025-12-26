import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../service/apiservice/bajaj_api_service.dart';
import '../../utills/themes/light_app_theme.dart';


class MarketStockChartScreen extends StatefulWidget {
  final String exchange;
  final String symbol;
  final String? stockName;
  final String? stockLogo;

  const MarketStockChartScreen({
    Key? key,
    required this.exchange,
    required this.symbol,
    this.stockName,
    this.stockLogo,
  }) : super(key: key);

  @override
  _MarketStockChartScreenState createState() => _MarketStockChartScreenState();
}

class _MarketStockChartScreenState extends State<MarketStockChartScreen> {
  late final WebViewController _controller;
  String _selectedInterval = '15';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChart();
  }

  void _initializeChart() {
    final tradingViewSymbol = _convertToTradingViewSymbol();
    final url = 'https://www.tradingview.com/chart/?symbol=$tradingViewSymbol&interval=$_selectedInterval';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String _convertToTradingViewSymbol() {
    final exchange = widget.exchange.toUpperCase();
    final symbol = widget.symbol.toUpperCase();

    switch (exchange) {
      case 'NSE':
        return 'NSE:$symbol';
      case 'BSE':
        return 'BSE:$symbol';
      case 'NYSE':
        return 'NYSE:$symbol';
      case 'NASDAQ':
        return 'NASDAQ:$symbol';
      case 'AMEX':
        return 'AMEX:$symbol';
      case 'LSE':
        return 'LSE:$symbol';
      case 'HKEX':
      case 'HKG':
        return 'HKEX:$symbol';
      case 'TSE':
      case 'TYO':
        return 'TSE:$symbol';
      case 'ASX':
        return 'ASX:$symbol';
      case 'TSX':
        return 'TSX:$symbol';
      default:
        return '$exchange:$symbol';
    }
  }

  void _updateInterval(String interval) {
    setState(() {
      _selectedInterval = interval;
      _isLoading = true;
    });
    _initializeChart();
  }

  void _showIntervalSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.clock,
                      size: 20.sp,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Select Time Interval',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDarkBlue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _buildIntervalChip('1', '1m'),
                  _buildIntervalChip('5', '5m'),
                  _buildIntervalChip('15', '15m'),
                  _buildIntervalChip('30', '30m'),
                  _buildIntervalChip('60', '1h'),
                  _buildIntervalChip('240', '4h'),
                  _buildIntervalChip('D', '1D'),
                  _buildIntervalChip('W', '1W'),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntervalChip(String value, String label) {
    final isSelected = _selectedInterval == value;
    return GestureDetector(
      onTap: () {
        _updateInterval(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold : AppTheme.lightBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGold : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  void _showOrderBottomSheet(String buySell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => _OrderBottomSheet(
        exchange: widget.exchange,
        symbol: widget.symbol,
        stockName: widget.stockName ?? widget.symbol,
        stockLogo: widget.stockLogo ?? '📈',
        buySell: buySell,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryDarkBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.symbol,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.stockName != null)
              Text(
                widget.stockName!,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: FaIcon(
                FontAwesomeIcons.clock,
                color: AppTheme.primaryGold,
                size: 16.sp,
              ),
            ),
            onPressed: _showIntervalSelector,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Stock Info Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.stockLogo != null) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      widget.stockLogo!,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                  SizedBox(width: 14.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.symbol,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      if (widget.stockName != null)
                        Text(
                          widget.stockName!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppTheme.primaryGold,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    widget.exchange,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chart Section
          Expanded(
            child: Container(
              margin: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryGold,
                              ),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Loading chart...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Buy/Sell Action Buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderBottomSheet('BUY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowTrendUp,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'BUY',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderBottomSheet('SELL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowTrendDown,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'SELL',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderBottomSheet extends StatefulWidget {
  final String exchange;
  final String symbol;
  final String stockName;
  final String stockLogo;
  final String buySell;

  const _OrderBottomSheet({
    required this.exchange,
    required this.symbol,
    required this.stockName,
    required this.stockLogo,
    required this.buySell,
  });

  @override
  State<_OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<_OrderBottomSheet> {
  bool _isLoading = false;
  final TextEditingController _qtyController = TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController();
  String _selectedOrderType = 'RL-M';
  String _selectedProduct = 'I';

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_qtyController.text.isEmpty || int.tryParse(_qtyController.text) == null) {
      _showSnackBar('Please enter valid quantity', isError: true);
      return;
    }

    if (_selectedOrderType == 'RL' || _selectedOrderType == 'SL') {
      if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
        _showSnackBar('Please enter valid price', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      double limitPrice = 0;
      double slPrice = 0;

      if (_selectedOrderType == 'RL') {
        limitPrice = double.parse(_priceController.text);
      } else if (_selectedOrderType == 'SL') {
        slPrice = double.parse(_priceController.text);
        limitPrice = double.parse(_priceController.text);
      }

      final response = await BajajApiService.placeOrder(
        orderType: 'place',
        qty: int.parse(_qtyController.text),
        exchange: widget.exchange,
        buySell: widget.buySell,
        orderTag: 'CLASSIA_${DateTime.now().millisecondsSinceEpoch}',
        orderTypeValue: _selectedOrderType,
        product: _selectedProduct,
        validity: 'DAY',
        symbol: widget.symbol,
        limitPrice: limitPrice,
        slPrice: slPrice,
      );

      if (response['statusCode'] == 0) {
        _showSnackBar('Order placed successfully!', isError: false);
        Navigator.pop(context);
      } else {
        _showSnackBar(response['message'] ?? 'Failed to place order', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.buySell == 'BUY';
    final showPriceField = _selectedOrderType == 'RL' || _selectedOrderType == 'SL';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              widget.stockLogo,
                              style: TextStyle(fontSize: 32.sp),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.symbol,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryDarkBlue,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  widget.stockName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isBuy
                                  ? AppTheme.successGreen.withOpacity(0.15)
                                  : AppTheme.errorRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isBuy ? AppTheme.successGreen : AppTheme.errorRed,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              widget.buySell,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isBuy ? AppTheme.successGreen : AppTheme.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDarkBlue,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildInputField(
                        controller: _qtyController,
                        label: 'Quantity',
                        hint: 'Enter quantity',
                        keyboardType: TextInputType.number,
                        icon: FontAwesomeIcons.hashtag,
                      ),
                      SizedBox(height: 16.h),
                      _buildDropdownField(
                        label: 'Order Type',
                        value: _selectedOrderType,
                        icon: FontAwesomeIcons.listCheck,
                        items: [
                          DropdownMenuItem(value: 'RL-M', child: Text('Market Order')),
                          DropdownMenuItem(value: 'RL', child: Text('Limit Order')),
                          DropdownMenuItem(value: 'SL', child: Text('Stop Loss')),
                          DropdownMenuItem(value: 'SL-M', child: Text('Stop Loss Market')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedOrderType = value!;
                            if (value == 'RL-M' || value == 'SL-M') {
                              _priceController.clear();
                            }
                          });
                        },
                      ),
                      if (showPriceField) ...[
                        SizedBox(height: 16.h),
                        _buildInputField(
                          controller: _priceController,
                          label: _selectedOrderType == 'RL' ? 'Limit Price' : 'Stop Loss Price',
                          hint: 'Enter price',
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          icon: FontAwesomeIcons.indianRupeeSign,
                        ),
                      ],
                      SizedBox(height: 16.h),
                      _buildDropdownField(
                        label: 'Product Type',
                        value: _selectedProduct,
                        icon: FontAwesomeIcons.boxOpen,
                        items: [
                          DropdownMenuItem(value: 'I', child: Text('Intraday')),
                          DropdownMenuItem(value: 'D', child: Text('Delivery')),
                          DropdownMenuItem(value: 'MTF', child: Text('Margin Trading')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedProduct = value!);
                        },
                      ),
                      SizedBox(height: 28.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBuy ? AppTheme.successGreen : AppTheme.errorRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                            height: 22.h,
                            width: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                isBuy
                                    ? FontAwesomeIcons.arrowTrendUp
                                    : FontAwesomeIcons.arrowTrendDown,
                                size: 16.sp,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Place ${widget.buySell} Order',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 14.sp, color: AppTheme.primaryGold),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDarkBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            filled: true,
            fillColor: AppTheme.lightBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(icon, size: 14.sp, color: AppTheme.primaryGold),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDarkBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppTheme.primaryGold, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}