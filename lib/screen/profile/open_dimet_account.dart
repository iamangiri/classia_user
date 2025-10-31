import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widget/common_app_bar.dart';

class OpenDematWebView extends StatefulWidget {
  const OpenDematWebView({super.key});

  @override
  State<OpenDematWebView> createState() => _OpenDematWebViewState();
}

class _OpenDematWebViewState extends State<OpenDematWebView> {
  bool isLoading = true;

  final String url =
      "https://hniekyc.bajajfinservsecurities.in/?rmcode=qOIiwzCWx6RycXiGM1637A==";

  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(url))
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          setState(() => isLoading = false);
        },
      ),
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:   CommonAppBar(
      title: 'Open Demat Account',
    ),

      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
