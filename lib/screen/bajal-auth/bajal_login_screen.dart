import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colors.dart';
import '../profile/open_dimet_account.dart';
import 'bajaj_auth_service.dart';

class BajalLoginScreen extends StatefulWidget {
  static const String routeName = '/bajal-login';

  final String? returnRoute;
  final Map<String, dynamic>? returnArguments;

  const BajalLoginScreen({
    Key? key,
    this.returnRoute,
    this.returnArguments,
  }) : super(key: key);

  @override
  State<BajalLoginScreen> createState() => _BajalLoginScreenState();
}

class _BajalLoginScreenState extends State<BajalLoginScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final _apiService = BajajApiService();

  static const String clientId = '54F97FA8-A45C-48FC-BC5A-F6A6AC81D1A7';
  static const String redirectUri = 'https://classiacapital.com/';
  static const String authUrl =
      'https://sso.bajajbroking.in/api/sso/oauth/authorize?response_type=code&state=1234&redirect_uri=$redirectUri&client_id=$clientId';

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    setState(() => _isLoading = true);

    try {
      final isValid = await _apiService.isTokenValid();

      if (isValid) {
        debugPrint('Token is valid. Navigating back or to main page...');
        if (mounted) {
          _navigateAfterLogin();
        }
        return;
      } else {
        debugPrint('No valid token found. Showing login screen...');
      }
    } catch (e) {
      debugPrint('Error checking token: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _startLogin() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const _OAuthWebView(authUrl: authUrl),
      ),
    );

    debugPrint('Received code from WebView: $code');

    if (code != null && mounted) {
      await _exchangeCodeForToken(code);
    } else {
      debugPrint('No code received or widget not mounted');
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Exchanging code for token: $code');
      final response = await _apiService.exchangeCodeForToken(code);

      if (response.success) {
        debugPrint('Login successful! Token saved.');

        if (mounted) {
          _navigateAfterLogin();
        }
      } else {
        debugPrint('Login failed: ${response.error}');
        if (mounted) {
          setState(() {
            _errorMessage = response.error ?? 'Login failed. Please try again.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateAfterLogin() {
    if (widget.returnRoute != null) {
      Navigator.pop(context, true);
    } else {
      context.go('/main?index=0');
    }
  }

  void _skipLogin() {
    if (mounted) {
      if (widget.returnRoute != null) {
        Navigator.pop(context, false);
      } else {
        context.go('/main?index=0');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryText,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
          tooltip: 'Go back',
        ),
        title: Text(
          'Login',
          style: TextStyle(
            color: AppColors.headingText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      )
          : SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'Classia Capital',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Your Trusted Investment Partner',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 60),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Continue with our partner',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Bajaj Broking',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Continue with Bajaj',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _skipLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                      side: BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Skip for Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_outlined, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OpenDematWebView()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Open Demat Account",
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Secure and encrypted login',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthWebView extends StatefulWidget {
  final String authUrl;

  const _OAuthWebView({
    Key? key,
    required this.authUrl,
  }) : super(key: key);

  @override
  State<_OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<_OAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasProcessedCode = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
            // Check for redirect on page start (works better on Android)
            _checkForRedirect(url);
          },
          onPageFinished: (String url) {
            debugPrint('Page finished: $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
            // CRITICAL: Also check on page finished (works better on iOS)
            _checkForRedirect(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation request: ${request.url}');
            // Also check here for extra safety
            _checkForRedirect(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _checkForRedirect(String url) {
    // Prevent multiple processing
    if (_hasProcessedCode) {
      debugPrint('Already processed code, ignoring: $url');
      return;
    }

    debugPrint('Checking URL for redirect: $url');

    // Check if this is our redirect URL
    if (url.startsWith('https://classiacapital.com/') ||
        url.startsWith('http://classiacapital.com/')) {

      try {
        final uri = Uri.parse(url);
        final code = uri.queryParameters['code'];
        final state = uri.queryParameters['state'];

        debugPrint('Redirect detected!');
        debugPrint('URL: $url');
        debugPrint('Code: $code');
        debugPrint('State: $state');

        if (code != null && code.isNotEmpty) {
          debugPrint('Valid code found: $code');

          // Mark as processed to prevent duplicate calls
          _hasProcessedCode = true;

          // Small delay to ensure WebView is stable before popping
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && Navigator.of(context).canPop()) {
              debugPrint('Popping with code: $code');
              Navigator.of(context).pop(code);
            }
          });
        } else {
          debugPrint('Code is null or empty in URL');
        }
      } catch (e) {
        debugPrint('Error parsing redirect URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint('Back button pressed in WebView');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bajaj Broking Login',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.onPrimaryColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.onPrimaryColor,
            ),
            onPressed: () {
              debugPrint('Close button pressed in WebView');
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}