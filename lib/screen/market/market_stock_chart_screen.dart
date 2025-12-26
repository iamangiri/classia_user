import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../service/apiservice/bajaj_api_service.dart';
import '../../themes/app_colors.dart';
import '../../widget/common_app_bar.dart';
import '../../widget/trade/tradingview_chart.dart';


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
  String _selectedInterval = '15'; // Default 15 minutes
  String _selectedTheme = 'light'; // Default light theme

  @override
  void initState() {
    super.initState();
    // You can set theme based on app theme if needed
    // _selectedTheme = Provider.of<ThemeProvider>(context, listen: false).isDarkMode ? 'dark' : 'light';
  }

  String _convertToTradingViewSymbol() {
    final exchange = widget.exchange.toUpperCase();
    final symbol = widget.symbol.toUpperCase();

    // Handle different exchanges
    switch (exchange) {
    // Indian Exchanges
      case 'NSE':
        return 'NSE:$symbol';
      case 'BSE':
        return 'BSE:$symbol';

    // US Exchanges
      case 'NYSE':
        return 'NYSE:$symbol';
      case 'NASDAQ':
        return 'NASDAQ:$symbol';
      case 'AMEX':
        return 'AMEX:$symbol';

    // European Exchanges
      case 'LSE':
        return 'LSE:$symbol';
      case 'FWB':
      case 'XETRA':
        return 'XETR:$symbol';
      case 'EURONEXT':
        return 'EURONEXT:$symbol';

    // Asian Exchanges
      case 'HKEX':
      case 'HKG':
        return 'HKEX:$symbol';
      case 'TSE':
      case 'TYO':
        return 'TSE:$symbol';
      case 'SSE':
        return 'SSE:$symbol';
      case 'SZSE':
        return 'SZSE:$symbol';
      case 'KRX':
        return 'KRX:$symbol';

    // Australian Exchange
      case 'ASX':
        return 'ASX:$symbol';

    // Canadian Exchange
      case 'TSX':
        return 'TSX:$symbol';

    // Default fallback
      default:
      // Try to use the exchange as-is
        return '$exchange:$symbol';
    }
  }

  void _showOrderBottomSheet(String buySell) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderBottomSheet(
        exchange: widget.exchange,
        symbol: widget.symbol,
        stockName: widget.stockName ?? widget.symbol,
        stockLogo: widget.stockLogo ?? '📈',
        buySell: buySell,
      ),
    );
  }

  void _showIntervalSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.screenBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(bottom: 16.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'Select Time Interval',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
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
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIntervalChip(String value, String label) {
    final isSelected = _selectedInterval == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGold,
      backgroundColor: AppColors.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13.sp,
      ),
      onSelected: (selected) {
        setState(() {
          _selectedInterval = value;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert exchange and symbol to TradingView format
    final String tradingViewSymbol = _convertToTradingViewSymbol();

    return Scaffold(
      appBar: CommonAppBar(
        title: "${widget.exchange} - ${widget.symbol}",
        actions: [
          // Interval selector button
          IconButton(
            icon: Icon(Icons.access_time, color: AppColors.primaryGold),
            onPressed: _showIntervalSelector,
            tooltip: 'Change Interval',
          ),
          // Theme toggle button

        ],
      ),
      body: Column(
        children: [
          // Chart using TradingViewChart widget
          Expanded(
            child: Container(
              color: AppColors.screenBackground,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  color: _selectedTheme == 'dark'
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                ),
                clipBehavior: Clip.antiAlias,
                child: TradingViewChart(
                  symbol: tradingViewSymbol,
                  interval: _selectedInterval,
                  theme: _selectedTheme,
                ),
              ),
            ),
          ),

          // Stock Info Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                if (widget.stockLogo != null) ...[
                  Text(
                    widget.stockLogo!,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.symbol,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingText,
                        ),
                      ),
                      if (widget.stockName != null)
                        Text(
                          widget.stockName!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.exchange,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Buy/Sell Buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.screenBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
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
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'BUY',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderBottomSheet('SELL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'SELL',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
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
  String _selectedOrderType = 'RL-M'; // Market Order by default
  String _selectedProduct = 'I'; // Intraday by default

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

    // Validate price for LIMIT orders (RL and SL require price)
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
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.buySell == 'BUY';
    final showPriceField = _selectedOrderType == 'RL' || _selectedOrderType == 'SL';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.screenBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            widget.stockLogo,
                            style: TextStyle(fontSize: 32.sp),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.symbol,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.headingText,
                                  ),
                                ),
                                Text(
                                  widget.stockName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isBuy
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              widget.buySell,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isBuy ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Order Details
                      Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.headingText,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Quantity Input
                      TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 14.sp),
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          labelStyle: TextStyle(fontSize: 13.sp),
                          hintText: 'Enter quantity',
                          hintStyle: TextStyle(fontSize: 13.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: AppColors.focusedBorder,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Order Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedOrderType,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
                        decoration: InputDecoration(
                          labelText: 'Order Type',
                          labelStyle: TextStyle(fontSize: 13.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: AppColors.focusedBorder,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'RL-M',
                            child: Text('Market Order', style: TextStyle(fontSize: 14.sp)),
                          ),
                          DropdownMenuItem(
                            value: 'RL',
                            child: Text('Limit Order', style: TextStyle(fontSize: 14.sp)),
                          ),
                          DropdownMenuItem(
                            value: 'SL',
                            child: Text('Stop Loss', style: TextStyle(fontSize: 14.sp)),
                          ),
                          DropdownMenuItem(
                            value: 'SL-M',
                            child: Text('Stop Loss Market', style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedOrderType = value!;
                            // Clear price field for market orders
                            if (value == 'RL-M' || value == 'SL-M') {
                              _priceController.clear();
                            }
                          });
                        },
                      ),

                      // Price field for RL and SL orders
                      if (showPriceField) ...[
                        SizedBox(height: 16.h),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            labelText: _selectedOrderType == 'RL'
                                ? 'Limit Price'
                                : 'Stop Loss Price',
                            labelStyle: TextStyle(fontSize: 13.sp),
                            hintText: 'Enter price',
                            hintStyle: TextStyle(fontSize: 13.sp),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.focusedBorder,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),

                      // Product Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedProduct,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
                        decoration: InputDecoration(
                          labelText: 'Product Type',
                          labelStyle: TextStyle(fontSize: 13.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: AppColors.focusedBorder,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'I',
                            child: Text('Intraday', style: TextStyle(fontSize: 14.sp)),
                          ),
                          DropdownMenuItem(
                            value: 'D',
                            child: Text('Delivery', style: TextStyle(fontSize: 14.sp)),
                          ),
                          DropdownMenuItem(
                            value: 'MTF',
                            child: Text('Margin Trading', style: TextStyle(fontSize: 14.sp)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedProduct = value!);
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBuy ? AppColors.success : AppColors.error,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            'Place ${widget.buySell} Order',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
}