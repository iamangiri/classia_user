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
  }

  Future<void> _authenticateUser() async {
    bool isAuthenticated = await _authService.authenticate();
    if (!isAuthenticated) {
      Navigator.pop(context);
      return;
    }
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
    if (isAuthenticating) {
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
              'assets/images/jt.png',
              width: 36,
              height: 36,
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
            Icon(Icons.fingerprint, size: 100, color: AppColors.primaryText),
            SizedBox(height: 10),
            Text(
              "Authenticating...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}