// // File: lib/bajaj_login_webview.dart
//
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'bajaj_api_service.dart';
//
// class BajajLoginWebView extends StatefulWidget {
//   const BajajLoginWebView({Key? key}) : super(key: key);
//
//   @override
//   State<BajajLoginWebView> createState() => _BajajLoginWebViewState();
// }
//
// class _BajajLoginWebViewState extends State<BajajLoginWebView> {
//   final BajajApiService _apiService = BajajApiService();
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   bool _isProcessing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//   }
//
//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() => _isLoading = true);
//             _handleNavigation(url);
//           },
//           onPageFinished: (String url) {
//             setState(() => _isLoading = false);
//           },
//           onWebResourceError: (WebResourceError error) {
//             _showErrorDialog('Failed to load page: ${error.description}');
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(_apiService.getBajajAuthUrl()));
//   }
//
//   void _handleNavigation(String url) {
//     // Check if this is the redirect URL with authorization code
//     if (url.startsWith('https://classiacapital.com/')) {
//       final uri = Uri.parse(url);
//       final code = uri.queryParameters['code'];
//
//       if (code != null && !_isProcessing) {
//         _exchangeCodeForToken(code);
//       }
//     }
//   }
//
//   Future<void> _exchangeCodeForToken(String code) async {
//     setState(() => _isProcessing = true);
//
//     try {
//       final tokenResponse = await _apiService.exchangeCodeForToken(code);
//
//       if (tokenResponse.statusCode == 0) {
//         // Success
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Login successful!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context, true); // Return true to indicate success
//         }
//       } else {
//         _showErrorDialog('Login failed: ${tokenResponse.message}');
//         setState(() => _isProcessing = false);
//       }
//     } catch (e) {
//       _showErrorDialog('Failed to authenticate: $e');
//       setState(() => _isProcessing = false);
//     }
//   }
//
//   void _showErrorDialog(String message) {
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Error'),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context, false);
//             },
//             child: const Text('Close'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _controller.loadRequest(
//                 Uri.parse(_apiService.getBajajAuthUrl()),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF6366F1),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           'Bajaj Broking Login',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context, false),
//         ),
//         actions: [
//           if (!_isProcessing)
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () {
//                 _controller.loadRequest(
//                   Uri.parse(_apiService.getBajajAuthUrl()),
//                 );
//               },
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_isLoading || _isProcessing)
//             Container(
//               color: Colors.white,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Color(0xFF6366F1),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       _isProcessing
//                           ? 'Authenticating...'
//                           : 'Loading...',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }