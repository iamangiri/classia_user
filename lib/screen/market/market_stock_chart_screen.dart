import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../service/apiservice/bajaj_api_service.dart';
import '../../themes/app_colors.dart';
import '../../widget/common_app_bar.dart';

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

  @override
  void initState() {
    super.initState();

    String url = 'https://www.tradingview.com/chart/?symbol=${widget.exchange}%3A${widget.symbol}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url)).catchError((error) {
        debugPrint('Error loading WebView: $error');
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "${widget.exchange} - ${widget.symbol}",
      ),
      body: Column(
        children: [
          // Chart WebView
          Expanded(
            child: Container(
              color: Colors.white10,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: WebViewWidget(controller: _controller),
              ),
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showOrderBottomSheet('BUY'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
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
                        padding: EdgeInsets.symmetric(vertical: 16.h),
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
  String _selectedOrderType = 'MARKET';
  String _selectedProduct = 'INTRADAY';

  @override
  void initState() {
    super.initState();
    _selectedOrderType = 'MARKET';
  }

  Future<void> _placeOrder() async {
    if (_qtyController.text.isEmpty || int.tryParse(_qtyController.text) == null) {
      _showSnackBar('Please enter valid quantity', isError: true);
      return;
    }

    // Validate price for LIMIT orders
    if (_selectedOrderType == 'LIMIT' || _selectedOrderType == 'SL') {
      if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
        _showSnackBar('Please enter valid price', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      double limitPrice = 0;
      double slPrice = 0;

      if (_selectedOrderType == 'LIMIT') {
        limitPrice = double.parse(_priceController.text);
      } else if (_selectedOrderType == 'SL') {
        slPrice = double.parse(_priceController.text);
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
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.buySell == 'BUY';
    final showPriceField = _selectedOrderType == 'LIMIT' || _selectedOrderType == 'SL';

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.screenBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Enter quantity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: AppColors.focusedBorder),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Order Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedOrderType,
                        decoration: InputDecoration(
                          labelText: 'Order Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        items: ['MARKET', 'LIMIT', 'SL', 'SL-M']
                            .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedOrderType = value!;
                            if (!showPriceField) {
                              _priceController.clear();
                            }
                          });
                        },
                      ),

                      // Price field for LIMIT and SL orders
                      if (showPriceField) ...[
                        SizedBox(height: 16.h),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: _selectedOrderType == 'LIMIT' ? 'Limit Price' : 'Stop Loss Price',
                            hintText: 'Enter price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: AppColors.focusedBorder),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),

                      // Product Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedProduct,
                        decoration: InputDecoration(
                          labelText: 'Product Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        items: ['INTRADAY', 'DELIVERY', 'MTF']
                            .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
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
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
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

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}