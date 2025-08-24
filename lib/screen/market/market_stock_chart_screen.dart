import 'package:classia_amc/widget/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MarketStockChartScreen extends StatefulWidget {
  final String exchange;
  final String symbol;

  const MarketStockChartScreen({
    Key? key,
    required this.exchange,
    required this.symbol,
  }) : super(key: key);

  @override
  _TradeChartScreenState createState() => _TradeChartScreenState();
}

class _TradeChartScreenState extends State<MarketStockChartScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:CommonAppBar(title: "${widget.exchange} - ${widget.symbol}"),
      body: Container(
        color: Colors.white10,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
