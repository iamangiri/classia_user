import 'package:classia_amc/themes/app_colors.dart';
import 'package:classia_amc/utills/constent/user_constant.dart';
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
  int currentPage = 0;
  bool isAuthenticating = true; // For biometric authentication state
  final AuthFingerprintService _authService = AuthFingerprintService();

  final List<Widget> screens = [
    HomeScreen(),
    MarketScreen(),
    TradingScreen(),
    WalletScreen(),
    InvestmentCalculator(), // This is the SIP calculator screen
  ];

  @override
  void initState() {
    super.initState();
    UserConstants.loadUserData();
    _authenticateUser();
  }

  /// Authenticate user before showing the screen
  Future<void> _authenticateUser() async {
    bool isAuthenticated = await _authService.authenticate();
    if (!isAuthenticated) {
      // If authentication fails, navigate back to login
      Navigator.pop(context);
      return;
    }
    // If authentication is successful, proceed to initialize the app
    setState(() {
      isAuthenticating = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show authentication screen before loading app content
    if (isAuthenticating) {
      return _buildAuthLoadingScreen();
    }

    return Scaffold(
      body: screens[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundColor, // Black background
        selectedItemColor: AppColors.primaryGold, // Golden color for selected item
        unselectedItemColor: Colors.grey, // Grey for unselected items
        selectedFontSize: 13,
        unselectedFontSize: 13,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPage,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.house,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.chartLine,
              size: 24,
            ),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.bolt,
              size: 24,
            ),
            label: 'JT',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.wallet,
              size: 24,
            ),
            label: 'Wallet',
          ),
          // Updated to represent the SIP Calculator
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.calculator,
              size: 24,
            ),
            label: 'Calculator',
          ),
        ],
      ),
    );
  }

  /// Authentication Loading Screen
  Widget _buildAuthLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 100, color: Colors.white),
            SizedBox(height: 10),
            Text(
              "Authenticating...",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}