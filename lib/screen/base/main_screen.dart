import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../service/localauth/auth_service.dart';
import '../calcutator/sip_calcutator.dart';
import '../main/home_screen.dart';
import '../main/market_screen.dart';
import '../main/trading_screen.dart';
import '../main/wallet_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Default to JT tab (index 2)
  int currentPage = 2;
  bool isAuthenticating = true;
  bool authenticationFailed = false;
  String authMessage = "Authenticating...";
  final AuthFingerprintService _authService = AuthFingerprintService();

  final List<Widget> screens = [
    HomeScreen(),
    MarketScreen(),
    TradingScreen(),
    WalletScreen(),
    InvestmentCalculator(),
  ];

  @override
  void initState() {
    super.initState();
    UserConstants.loadUserData();
    _authenticateUser();
    print(UserConstants.TOKEN);
  }

  Future<void> _authenticateUser() async {
    try {
      setState(() {
        isAuthenticating = true;
        authenticationFailed = false;
        authMessage = "Checking authentication...";
      });

      // Add a small delay to show the loading screen
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if biometric is available first
      bool isBiometricAvailable = await _authService.isBiometricAvailable();

      if (!isBiometricAvailable) {
        setState(() {
          authMessage = "Biometric not available. Proceeding...";
        });
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          isAuthenticating = false;
        });
        return;
      }

      setState(() {
        authMessage = "Authenticating...";
      });

      bool isAuthenticated = await _authService.authenticate();

      if (!isAuthenticated) {
        // Check if locked out
        if (_authService.isLockedOut()) {
          setState(() {
            authenticationFailed = true;
            authMessage = "Too many failed attempts. Try again in ${_authService.getRemainingLockTime()} seconds.";
          });

          // Auto retry after lockout period
          Future.delayed(Duration(seconds: _authService.getRemainingLockTime() + 1), () {
            if (mounted) {
              _authenticateUser();
            }
          });
          return;
        } else {
          setState(() {
            authenticationFailed = true;
            authMessage = "Authentication failed. Tap to retry.";
          });
          return;
        }
      }

      setState(() {
        isAuthenticating = false;
        authenticationFailed = false;
      });

    } catch (e) {
      print("Error during authentication: $e");
      // On any error, proceed to main screen to prevent blank screen
      setState(() {
        authMessage = "Authentication error. Proceeding...";
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        isAuthenticating = false;
        authenticationFailed = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void _retryAuthentication() {
    _authService.resetAuthState();
    _authenticateUser();
  }

  void _skipAuthentication() {
    setState(() {
      isAuthenticating = false;
      authenticationFailed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isAuthenticating || authenticationFailed) {
      return _buildAuthLoadingScreen();
    }

    return Scaffold(
      body: screens[currentPage],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: AppColors.backgroundColor,
        color: Colors.grey,
        activeColor: AppColors.primaryGold,
        height: 60,
        items: [
          TabItem(icon: FaIcon(FontAwesomeIcons.house, size: 24), title: 'Home'),
          TabItem(icon: FaIcon(FontAwesomeIcons.chartLine, size: 24), title: 'Market'),
          // JT uses custom image asset
          TabItem(
            icon: Image.asset(
              'assets/images/jt-nav.png',
              width: 56,
              height: 56,
            ),
            title: 'JT',
          ),
          TabItem(icon: FaIcon(FontAwesomeIcons.wallet, size: 24), title: 'Wallet'),
          TabItem(icon: FaIcon(FontAwesomeIcons.calculator, size: 24), title: 'Calculator'),
        ],
        initialActiveIndex: currentPage,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildAuthLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!authenticationFailed) ...[
              // Loading animation
              Icon(Icons.fingerprint, size: 100, color: AppColors.primaryGold),
              const SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
              ),
              const SizedBox(height: 20),
            ] else ...[
              // Error state
              Icon(Icons.error_outline, size: 100, color: Colors.red),
              const SizedBox(height: 20),
            ],
            Text(
              authMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: authenticationFailed ? Colors.red : AppColors.primaryGold,
              ),
            ),
            if (authenticationFailed) ...[
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _retryAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Retry"),
                  ),
                  ElevatedButton(
                    onPressed: _skipAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Skip"),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}